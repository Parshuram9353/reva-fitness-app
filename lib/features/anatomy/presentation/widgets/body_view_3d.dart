import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_colors.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/providers/selected_muscle_provider.dart';

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
              src: 'assets/models/ecorche_animated_interactive.glb',
              backgroundColor: const Color(0xFF07080A),
              cameraControls: true,
              disablePan: true, // Disables two-finger panning so two fingers cleanly pinch-to-zoom without jitter
              touchAction: TouchAction.none, // Bypasses Android WebView gesture interception for direct 60fps touch
              progressBarColor: Colors.transparent, // Hide default progress bar to use our own cyber overlay
              activeGestureInterceptor: false,
              autoPlay: false,
              shadowIntensity: 0,
              cameraTarget: '0m 0.88m 0m',
              cameraOrbit: '0deg 75deg 105%',
              minCameraOrbit: 'auto auto 50%',
              maxCameraOrbit: 'auto auto 150%',
              interpolationDecay: 1, // 1ms decay (> 0 required by HTMLBuilder) gives instant, zero-lag finger tracking
              relatedCss: """
                html, body {
                  margin: 0;
                  padding: 0;
                  width: 100%;
                  height: 100%;
                  overflow: hidden;
                  touch-action: none;
                  -webkit-touch-callout: none;
                  -webkit-user-select: none;
                  user-select: none;
                  overscroll-behavior: none;
                }
                model-viewer {
                  width: 100%;
                  height: 100%;
                  touch-action: none;
                }
              """,
              relatedJs: """
                const viewer = document.getElementById("muscle-model-viewer");
                let platformReady = false;
                let modelLoaded = false;

                function logDebug(msg) {
                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('jsDebuggerChannel', msg);
                  } else {
                    console.log("[JS Debug] " + msg);
                  }
                }

                function getThreeScene() {
                  if (!viewer) return null;
                  const sceneSymbol = Object.getOwnPropertySymbols(viewer).find(s => s.description === 'scene');
                  return sceneSymbol ? viewer[sceneSymbol] : null;
                }

                function cacheOriginalMaterials(threeScene) {
                  if (!threeScene || !threeScene._model) return;
                  threeScene._model.traverse(node => {
                    if (node.isMesh && node.material) {
                      const mat = node.material;
                      if (!mat.userData.__orig) {
                        mat.userData.__orig = {
                          colorHex: mat.color ? mat.color.getHex() : 0xffffff,
                          emissiveHex: mat.emissive ? mat.emissive.getHex() : 0x000000,
                          emissiveIntensity: mat.emissiveIntensity !== undefined ? mat.emissiveIntensity : 0.0,
                          opacity: mat.opacity !== undefined ? mat.opacity : 1.0,
                          transparent: !!mat.transparent,
                          vertexColors: !!mat.vertexColors,
                          roughness: mat.roughness !== undefined ? mat.roughness : 0.5,
                          metalness: mat.metalness !== undefined ? mat.metalness : 0.0
                        };
                      }
                    }
                  });
                }

                const muscleMeshes = {
                  'chest': ['Mesh_Chest_Pectorals'],
                  'abs': ['Mesh_Abs_Abdominals'],
                  'shoulders': ['Mesh_Deltoid_L', 'Mesh_Deltoid_R'],
                  'biceps': ['Mesh_Triceps_L', 'Mesh_Triceps_R'],
                  'triceps': ['Mesh_Triceps_L', 'Mesh_Triceps_R'],
                  'back': ['Mesh_Upper_Back'],
                  'glutes': ['Mesh_Lower_Back_Glutes'],
                  'quads': ['Mesh_Quadriceps_L', 'Mesh_Quadriceps_R'],
                  'hamstrings': ['Mesh_Hamstrings_L', 'Mesh_Hamstrings_R'],
                  'calves': ['Mesh_Calves_L', 'Mesh_Calves_R', 'Mesh_Feet_L', 'Mesh_Feet_R'],
                  'forearms': ['Mesh_Forearm_L', 'Mesh_Forearm_R'],
                  'neck': ['Mesh_Head_Neck']
                };

                const muscleMaterials = {
                  'Mat_Chest_Pectorals': 'chest',
                  'Mat_Abs_Abdominals': 'abs',
                  'Mat_Deltoid_L': 'shoulders',
                  'Mat_Deltoid_R': 'shoulders',
                  'Mat_Quadriceps_L': 'quads',
                  'Mat_Quadriceps_R': 'quads',
                  'Mat_Hamstrings_L': 'hamstrings',
                  'Mat_Hamstrings_R': 'hamstrings',
                  'Mat_Calves_L': 'calves',
                  'Mat_Calves_R': 'calves',
                  'Mat_Feet_L': 'calves',
                  'Mat_Feet_R': 'calves',
                  'Mat_Forearm_L': 'forearms',
                  'Mat_Forearm_R': 'forearms',
                  'Mat_Upper_Back': 'back',
                  'Mat_Head_Neck': 'neck',
                  'Mat_Lower_Back_Glutes': 'glutes',
                  'Mat_Triceps_L': 'triceps',
                  'Mat_Triceps_R': 'triceps'
                };

                window.highlightMuscle = (muscleId) => {
                  try {
                    logDebug("highlightMuscle called with: " + muscleId);
                    const threeScene = getThreeScene();
                    logDebug("threeScene: " + (!!threeScene) + " hasModel: " + (threeScene && !!threeScene._model));

                    // 1. Highlight via ModelViewer official Material API
                    if (viewer && viewer.model && viewer.model.materials) {
                      for (let mat of viewer.model.materials) {
                        const mName = mat.name || '';
                        const mappedMuscle = muscleMaterials[mName];
                        const isMatch = muscleId && (mappedMuscle === muscleId || 
                          (muscleId === 'biceps' && (mName === 'Mat_Triceps_L' || mName === 'Mat_Triceps_R')) ||
                          (muscleId === 'back' && (mName === 'Mat_Upper_Back' || mName === 'Mat_Lower_Back_Glutes')));

                        if (!mat._origBaseColor) {
                          mat._origBaseColor = [...mat.pbrMetallicRoughness.baseColorFactor];
                        }

                        if (!muscleId) {
                          // Restore
                          mat.pbrMetallicRoughness.setBaseColorFactor(mat._origBaseColor);
                          if (mat.setEmissiveFactor) mat.setEmissiveFactor([0, 0, 0]);
                        } else if (isMatch) {
                          // Vibrant Electric Neon Cyan [0, 0.9, 1.0, 1.0]
                          mat.pbrMetallicRoughness.setBaseColorFactor([0.0, 0.9, 1.0, 1.0]);
                          if (mat.setEmissiveFactor) mat.setEmissiveFactor([0.0, 0.9, 1.0]);
                        } else {
                          // Dimmed cyber dark silhouette [0.15, 0.17, 0.22, 0.5]
                          const isSkel = mName === 'material_1' || mName === 'material_2';
                          mat.pbrMetallicRoughness.setBaseColorFactor(isSkel ? [0.1, 0.1, 0.12, 0.2] : [0.18, 0.20, 0.25, 0.4]);
                          if (mat.setEmissiveFactor) mat.setEmissiveFactor([0, 0, 0]);
                        }
                      }
                    }

                    // 2. Also Highlight via Three.js Scene directly
                    if (threeScene && threeScene._model) {
                      cacheOriginalMaterials(threeScene);

                      threeScene._model.traverse(node => {
                        if (node.isMesh && node.material) {
                          const mat = node.material;
                          const mName = mat.name || '';
                          const nName = node.name || '';
                          const mappedMuscle = muscleMaterials[mName] || (muscleMeshes[muscleId] && muscleMeshes[muscleId].includes(nName) ? muscleId : null);
                          const isTarget = muscleId && (mappedMuscle === muscleId ||
                            (muscleId === 'biceps' && (mName === 'Mat_Triceps_L' || mName === 'Mat_Triceps_R')) ||
                            (muscleId === 'back' && (mName === 'Mat_Upper_Back' || mName === 'Mat_Lower_Back_Glutes')));

                          if (mat.userData && mat.userData.__orig) {
                            const orig = mat.userData.__orig;
                            if (!muscleId) {
                              mat.color.setHex(orig.colorHex);
                              mat.emissive.setHex(orig.emissiveHex);
                              mat.emissiveIntensity = orig.emissiveIntensity;
                              mat.opacity = orig.opacity;
                              mat.transparent = orig.transparent;
                              mat.vertexColors = orig.vertexColors;
                              mat.needsUpdate = true;
                            } else if (isTarget) {
                              mat.color.setHex(0x00E5FF);
                              mat.emissive.setHex(0x00E5FF);
                              mat.emissiveIntensity = 2.0;
                              mat.opacity = 1.0;
                              mat.transparent = false;
                              mat.vertexColors = false;
                              mat.needsUpdate = true;
                            } else {
                              const isSkeleton = nName === 'Mesh_Skeleton_Inner' || nName === 'Mesh_Tendons_Ligaments' || mName === 'material_1' || mName === 'material_2';
                              mat.color.setHex(isSkeleton ? 0x1A1D24 : 0x2A2E38);
                              mat.emissive.setHex(0x000000);
                              mat.emissiveIntensity = 0.0;
                              mat.opacity = isSkeleton ? 0.25 : 0.4;
                              mat.transparent = true;
                              mat.vertexColors = false;
                              mat.needsUpdate = true;
                            }
                          }
                        }
                      });
                    }

                    // Keep model completely static without playing animations
                    try {
                      viewer.pause();
                      viewer.currentTime = 0;
                    } catch (animErr) {}
                  } catch (e) {
                    logDebug("Error in highlightMuscle: " + e);
                  }
                };

                viewer.addEventListener('load', (event) => {
                  logDebug("viewer load event fired");
                  modelLoaded = true;
                  const threeScene = getThreeScene();
                  if (threeScene) {
                    cacheOriginalMaterials(threeScene);
                    try {
                      // Cap pixel ratio to 1.5 on high-DPI screens to prevent massive fillrate overload
                      if (threeScene.renderer && typeof threeScene.renderer.setPixelRatio === 'function') {
                        threeScene.renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 1.5));
                      }
                    } catch(rErr) {}
                  }

                  try {
                    viewer.pause();
                    viewer.currentTime = 0;
                  } catch (err) {}

                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                    window.flutter_inappwebview.callHandler('onModelReady');
                  }

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
                  if (event.isPrimary === false) return; // Ignore secondary touch points during pinch zoom
                  startX = event.clientX;
                  startY = event.clientY;
                  startTime = Date.now();
                });

                viewer.addEventListener('pointerup', (event) => {
                  if (event.isPrimary === false) return; // Ignore pinch zoom release
                  try {
                    const dx = event.clientX - startX;
                    const dy = event.clientY - startY;
                    const dt = Date.now() - startTime;

                    if (Math.sqrt(dx * dx + dy * dy) > 12 || dt > 400) {
                      return;
                    }

                    let detectedMuscle = null;
                    let hitPosition = null;

                    if (typeof viewer.positionAndNormalFromPoint === 'function') {
                      const hit = viewer.positionAndNormalFromPoint(event.clientX, event.clientY);
                      if (hit && hit.position) {
                        hitPosition = hit.position;
                      }
                    }

                    let matName = null;
                    if (typeof viewer.materialFromPoint === 'function') {
                      const mat = viewer.materialFromPoint(event.clientX, event.clientY);
                      if (mat && mat.name) {
                        matName = mat.name;
                      }
                    }

                    logDebug("Clicked! matName: " + matName + " pos: " + JSON.stringify(hitPosition));

                    if (matName && muscleMaterials[matName]) {
                      detectedMuscle = muscleMaterials[matName];
                      if (matName === 'Mat_Lower_Back_Glutes') {
                        if (hitPosition && hitPosition.y >= 0.95) {
                          detectedMuscle = 'back';
                        } else {
                          detectedMuscle = 'glutes';
                        }
                      } else if (matName === 'Mat_Triceps_L' || matName === 'Mat_Triceps_R') {
                        if (hitPosition && hitPosition.z >= -0.05) {
                          detectedMuscle = 'biceps';
                        } else {
                          detectedMuscle = 'triceps';
                        }
                      }
                    } else if (hitPosition) {
                      const x = hitPosition.x;
                      const y = hitPosition.y;
                      const z = hitPosition.z;

                      if (y < 0.45) {
                        detectedMuscle = 'calves';
                      } else if (y >= 0.45 && y < 0.85) {
                        detectedMuscle = z > -0.03 ? 'quads' : 'hamstrings';
                      } else if (Math.abs(x) > 0.18) {
                        if (y >= 1.22) {
                          detectedMuscle = 'shoulders';
                        } else if (y < 0.95) {
                          detectedMuscle = 'forearms';
                        } else {
                          detectedMuscle = z > -0.05 ? 'biceps' : 'triceps';
                        }
                      } else if (y >= 1.45) {
                        detectedMuscle = 'neck';
                      } else {
                        if (z > -0.02) {
                          detectedMuscle = y >= 1.12 ? 'chest' : 'abs';
                        } else {
                          detectedMuscle = y >= 1.05 ? 'back' : 'glutes';
                        }
                      }
                    }

                    logDebug("Mapped to muscle: " + detectedMuscle);

                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      window.flutter_inappwebview.callHandler('onMuscleClicked', detectedMuscle);
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
