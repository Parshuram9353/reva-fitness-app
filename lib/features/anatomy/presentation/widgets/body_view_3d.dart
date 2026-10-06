import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_colors.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/providers/selected_muscle_provider.dart';
import 'dart:convert';

// Internal/lower-level packages of the 3D controller for full WebView/JS support
import 'package:flutter_3d_controller/src/core/modules/model_viewer/model_viewer.dart';
import 'package:flutter_3d_controller/src/data/repositories/flutter_3d_repository.dart';
import 'package:flutter_3d_controller/src/data/datasources/i_flutter_3d_datasource.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class BodyView3d extends ConsumerStatefulWidget {
  const BodyView3d({super.key});

  @override
  ConsumerState<BodyView3d> createState() => _BodyView3dState();
}

class _BodyView3dState extends ConsumerState<BodyView3d> {
  final Flutter3DController _controller = Flutter3DController();
  InAppWebViewController? _webViewController;
  double _progress = 0.0;
  bool _isLoaded = false;
  bool _showOverlay = true;
  String? _error;
  List<String> _loadedMaterialNames = [];

  // Mappings are handled directly in JavaScript within the WebView

  @override
  Widget build(BuildContext context) {
    // Listen to zoom Level Provider updates and apply them to the 3D camera orbit
    ref.listen<double>(zoomLevelProvider, (previous, next) {
      debugPrint('--- 3D zoom changed: $previous -> $next (loaded: $_isLoaded)');
      if (_isLoaded) {
        final radius = 105.0 / next;
        final selectedMuscle = ref.read(selectedMuscleIdProvider);
        final isPosterior = selectedMuscle == 'glutes' ||
            selectedMuscle == 'back' ||
            selectedMuscle == 'triceps' ||
            selectedMuscle == 'hamstrings';
        final theta = isPosterior ? 180.0 : 0.0;
        debugPrint('--- 3D setCameraOrbit($theta, 75.0, $radius)');
        _controller.setCameraOrbit(theta, 75.0, radius);
      }
    });

    // Listen to selection changes and highlight the muscle on the 3D model
    ref.listen<String?>(selectedMuscleIdProvider, (previous, next) {
      if (_webViewController != null) {
        debugPrint('--- 3D highlighting muscle: $next');
        _webViewController?.evaluateJavascript(
          source: "if (window.highlightMuscle) window.highlightMuscle(${next == null ? 'null' : "'$next'"});"
        );
        if (next == null) {
          final zoom = ref.read(zoomLevelProvider);
          final radius = 105.0 / zoom;
          _controller.setCameraOrbit(0.0, 75.0, radius);
        }
      }
    });

    return Container(
      color: const Color(0xFF07080A),
      child: Stack(
        children: [
          // 1. Cyber Grid Background overlay
          const Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: GridPaper(
                color: Colors.white,
                interval: 40.0,
                subdivisions: 1,
              ),
            ),
          ),

          // 2. Interactive 3D Model Viewer
          Positioned.fill(
            child: ModelViewer(
              id: 'muscle-model-viewer',
              src: 'assets/models/ecorche_-_anatomy_study.glb',
              backgroundColor: const Color(0xFF07080A),
              cameraControls: true,
              progressBarColor: Colors.transparent, // Hide default progress bar to use our own cyber overlay
              activeGestureInterceptor: false,
              relatedJs: """
                const viewer = document.getElementById("muscle-model-viewer");
                let platformReady = false;
                let modelLoaded = false;
                let activeHighlights = [];

                function logDebug(msg) {
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('jsDebuggerChannel', msg);
                  } else {
                    console.log("[JS Debug] " + msg);
                  }
                }

                function mapComToMuscleId(meshName, com) {
                  const [x, y, z] = com;

                  if (meshName === 'Object_9' || meshName === 'Object_11') return null;

                  // Calves: lowest posterior/anterior
                  if (y < -0.008) {
                    return 'calves';
                  }

                  // Quads and Hamstrings (thighs)
                  if (y < -0.003) {
                    return z > -0.0008 ? 'quads' : 'hamstrings';
                  }

                  // Shoulders (deltoids, high up on the sides)
                  if (Math.abs(x) > 0.0022 && y >= 0.0045) {
                    return 'shoulders';
                  }

                  // Arms (biceps, triceps, forearms)
                  if (Math.abs(x) > 0.0022) {
                    if (y < 0.001) {
                      return 'forearms';
                    } else {
                      return z > -0.0008 ? 'biceps' : 'triceps';
                    }
                  }

                  // Neck / Traps / Head (highest center area)
                  if (y >= 0.0045) {
                    return z > -0.0008 ? 'neck' : 'back';
                  }

                  // Torso (Chest, Abs, Back, Glutes) - covering y from -0.003 to 0.006
                  if (z > -0.0008) {
                    // Anterior Torso: Chest or Abs
                    return y > 0.002 ? 'chest' : 'abs';
                  } else {
                    // Posterior Torso: Glutes or Back
                    return y < 0.0005 ? 'glutes' : 'back';
                  }
                }

                function clearHighlights() {
                  for (let hl of activeHighlights) {
                    if (hl.parent) {
                      hl.parent.remove(hl);
                    }
                  }
                  activeHighlights = [];
                }

                window.highlightMuscle = (muscleId) => {
                  try {
                    logDebug("highlightMuscle called with: " + muscleId);
                    clearHighlights();
                    if (!muscleId) {
                      viewer.removeAttribute('camera-target');
                      viewer.removeAttribute('camera-orbit');
                      return;
                    }

                    const sceneSymbol = Object.getOwnPropertySymbols(viewer).find(s => s.description === 'scene');
                    if (!sceneSymbol) return;
                    const threeScene = viewer[sceneSymbol];
                    if (!threeScene || !threeScene._model) return;

                    let sumX = 0, sumY = 0, sumZ = 0;
                    let count = 0;

                    threeScene._model.traverse(node => {
                      if (node.isMesh && node.material && node.geometry) {
                        if (node.name === "Object_9" || node.name === "Object_11") return; // Skip skeleton/hands/feet
                        
                        const geom = node.geometry;
                        const posAttr = geom.attributes.position;
                        const indexAttr = geom.index;
                        if (!posAttr || !indexAttr) return;

                        const numFaces = indexAttr.count / 3;
                        const highlightIndices = [];

                        // Temporary vector for coordinate conversion
                        const localV = new node.position.constructor();

                        for (let f = 0; f < numFaces; f++) {
                          const idx0 = indexAttr.getX(f * 3);
                          const idx1 = indexAttr.getX(f * 3 + 1);
                          const idx2 = indexAttr.getX(f * 3 + 2);

                          const x0 = posAttr.getX(idx0), y0 = posAttr.getY(idx0), z0 = posAttr.getZ(idx0);
                          const x1 = posAttr.getX(idx1), y1 = posAttr.getY(idx1), z1 = posAttr.getZ(idx1);
                          const x2 = posAttr.getX(idx2), y2 = posAttr.getY(idx2), z2 = posAttr.getZ(idx2);

                          // Compute face center in local coordinates
                          localV.set((x0 + x1 + x2) / 3, (y0 + y1 + y2) / 3, (z0 + z1 + z2) / 3);
                          
                          // Convert to world coordinates
                          node.localToWorld(localV);
                          // Convert back to model's root coordinate space
                          threeScene._model.worldToLocal(localV);

                          // Check if this face's center maps to the target muscleId
                          const mappedId = mapComToMuscleId(node.name, [localV.x, localV.y, localV.z]);
                          if (mappedId === muscleId) {
                            highlightIndices.push(idx0, idx1, idx2);
                            sumX += localV.x;
                            sumY += localV.y;
                            sumZ += localV.z;
                            count++;
                          }
                        }

                        // Highlight mesh rendering removed as per user preference
                      }
                    });

                    if (count > 0) {
                      const avgX = sumX / count;
                      const avgY = sumY / count;
                      const avgZ = sumZ / count;
                      
                      let targetY = avgY;
                      if (muscleId === 'neck') {
                        targetY = avgY - 0.0032;
                      }
                      
                      logDebug("Setting camera target to COM: " + avgX + ", " + targetY + ", " + avgZ);
                      
                      viewer.setAttribute('camera-target', avgX + 'm ' + targetY + 'm ' + avgZ + 'm');
                      
                      const theta = avgZ > -0.0008 ? '0deg' : '180deg';
                      const phi = '75deg';
                      const radius = '75%';
                      viewer.setAttribute('camera-orbit', theta + ' ' + phi + ' ' + radius);
                    } else {
                      viewer.removeAttribute('camera-target');
                      viewer.removeAttribute('camera-orbit');
                    }
                  } catch (e) {
                    logDebug("Error in highlightMuscle: " + e);
                  }
                };

                viewer.addEventListener('load', (event) => {
                  logDebug("viewer load event fired");
                  modelLoaded = true;

                  // Initial highlight if selection exists
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onModelReady');
                  }

                  // Forward load event to package onLoadChannel
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    const srcVal = (event && event.target && event.target.src) ? event.target.src : '/model';
                    window.flutter_inappwebview.callHandler('onLoadChannel', srcVal);
                  }
                });

                viewer.addEventListener('progress', (event) => {
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    const progressVal = (event && event.detail && event.detail.totalProgress !== undefined) 
                      ? event.detail.totalProgress 
                      : 1.0;
                    window.flutter_inappwebview.callHandler('onProgressChannel', progressVal);
                  }
                });

                viewer.addEventListener('error', (event) => {
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    const errorMsg = (event && event.detail && event.detail.error) 
                      ? event.detail.error.toString() 
                      : 'Failed to load';
                    window.flutter_inappwebview.callHandler('onErrorChannel', errorMsg);
                  }
                });

                window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                  logDebug("flutterInAppWebViewPlatformReady event fired");
                  platformReady = true;
                });

                let startX = 0;
                let startY = 0;
                let startTime = 0;

                viewer.addEventListener('pointerdown', (event) => {
                  startX = event.clientX;
                  startY = event.clientY;
                  startTime = Date.now();
                });

                viewer.addEventListener('pointerup', (event) => {
                  try {
                    const dx = event.clientX - startX;
                    const dy = event.clientY - startY;
                    const dt = Date.now() - startTime;

                    // If they dragged or held down too long, it's not a tap
                    if (Math.sqrt(dx*dx + dy*dy) > 10 || dt > 300) {
                      return;
                    }

                    // Get world position of the click
                    const hit = viewer.positionAndNormalFromPoint(event.clientX, event.clientY);
                    if (!hit) {
                      logDebug("Clicked on background.");
                      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                        window.flutter_inappwebview.callHandler('onMuscleClicked', null);
                      }
                      return;
                    }

                    const P = hit.position;
                    logDebug("Hit position: " + JSON.stringify(P));
                    
                    const muscleId = mapComToMuscleId(null, [P.x, P.y, P.z]);
                    logDebug("Clicked COM: " + JSON.stringify([P.x, P.y, P.z]) + " -> mapped to: " + muscleId);

                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      window.flutter_inappwebview.callHandler('onMuscleClicked', muscleId);
                    }
                  } catch(e) {
                    logDebug("Error in click handler: " + e);
                  }
                });
              """,
              onWebViewCreated: (InAppWebViewController webViewController) {
                _controller.init(
                  Flutter3DRepository(
                    IFlutter3DDatasource(
                      'muscle-model-viewer',
                      webViewController,
                      true,
                    ),
                  ),
                );

                // Register handler for when model is fully ready to check for initial highlight
                webViewController.addJavaScriptHandler(
                  handlerName: 'onModelReady',
                  callback: (args) {
                    final currentSelection = ref.read(selectedMuscleIdProvider);
                    if (currentSelection != null) {
                      webViewController.evaluateJavascript(
                        source: "if (window.highlightMuscle) window.highlightMuscle('$currentSelection');"
                      );
                    }
                  },
                );

                // Register handler for muscle clicks
                webViewController.addJavaScriptHandler(
                  handlerName: 'onMuscleClicked',
                  callback: (args) {
                    final String? muscleId = args.first as String?;
                    debugPrint('--- 3D Muscle Clicked: $muscleId');
                    ref.read(selectedMuscleIdProvider.notifier).state = muscleId;
                  },
                );

                // Register handler for JS debug logs
                webViewController.addJavaScriptHandler(
                  handlerName: 'jsDebuggerChannel',
                  callback: (args) {
                    debugPrint('[JS Debug] ${args.join(' ')}');
                  },
                );

                _webViewController = webViewController;
              },
              onProgress: (progress) {
                debugPrint('--- 3D Progress: $progress');
                if (mounted) {
                  setState(() {
                    _progress = progress;
                  });
                }
              },
              onLoad: (modelAddress) {
                debugPrint('--- 3D Loaded: $modelAddress');
                if (mounted) {
                  setState(() {
                    _isLoaded = true;
                    _progress = 1.0;
                  });

                  // Set initial camera zoom level immediately on load
                  final initialZoom = ref.read(zoomLevelProvider);
                  final radius = 105.0 / initialZoom;
                  
                  final selectedMuscle = ref.read(selectedMuscleIdProvider);
                  final isPosterior = selectedMuscle == 'glutes' ||
                      selectedMuscle == 'back' ||
                      selectedMuscle == 'triceps' ||
                      selectedMuscle == 'hamstrings';
                  final theta = isPosterior ? 180.0 : 0.0;
                  
                  _controller.setCameraOrbit(theta, 75.0, radius);
                }
              },
              onError: (error) {
                debugPrint('--- 3D Error: $error');
                if (mounted) {
                  setState(() {
                    _error = error;
                  });
                }
              },
            ),
          ),

          // 3. Cyber Hologram Loading Overlay (Fades out when loaded)
          if (_showOverlay)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isLoaded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                onEnd: () {
                  if (_isLoaded && mounted) {
                    setState(() {
                      _showOverlay = false;
                    });
                  }
                },
                child: Container(
                  color: const Color(0xFF07080A),
                  child: Stack(
                    children: [
                      // Re-draw grid under the loading overlay
                      const Positioned.fill(
                        child: Opacity(
                          opacity: 0.03,
                          child: GridPaper(
                            color: Colors.white,
                            interval: 40.0,
                            subdivisions: 1,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.blur_on,
                                color: AppColors.neonCyan,
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error != null ? 'SYSTEM ERROR' : 'INITIALIZING HOLOGRAM',
                                style: const TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neonCyan,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_error == null) ...[
                                LinearProgressIndicator(
                                  value: _progress,
                                  backgroundColor: AppColors.border,
                                  color: AppColors.neonCyan,
                                  minHeight: 2,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'DOWNLOADING MESH DATA: ${(_progress * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontFamily: 'Share Tech Mono',
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ] else
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Share Tech Mono',
                                    fontSize: 9,
                                    color: Colors.redAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Interaction Guidelines Hint (Fades in when loaded)
          if (_isLoaded)
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isLoaded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'TAP MUSCLES TO SELECT • DRAG TO ROTATE HOLOGRAM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontFamily: 'Share Tech Mono',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
