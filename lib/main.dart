
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_colors.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_theme.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/data/datasources/local_muscle_db.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/providers/selected_muscle_provider.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/widgets/body_view_2d.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/widgets/body_view_3d.dart';
import 'package:anatomy_fitness_app_mobile/features/details_panel/presentation/screens/info_dashboard_panel.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AetherFitApp(),
    ),
  );
}

class AetherFitApp extends StatelessWidget {
  const AetherFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aether Fit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainExploreScreen(),
    );
  }
}

class MainExploreScreen extends ConsumerStatefulWidget {
  const MainExploreScreen({super.key});

  @override
  ConsumerState<MainExploreScreen> createState() => _MainExploreScreenState();
}

class _MainExploreScreenState extends ConsumerState<MainExploreScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _searchResults = [];
  bool _isScanning = false;
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // Trigger search logic
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final q = query.toLowerCase().trim();
    final matches = LocalMuscleDb.muscles.keys.where((key) {
      final name = LocalMuscleDb.muscles[key]!.name.toLowerCase();
      return key.contains(q) || name.contains(q);
    }).toList();

    setState(() {
      _searchResults = matches;
    });
  }

  // Simulate laser diagnostic scanning
  void _triggerDiagnosticScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
    });

    ref.read(selectedMuscleIdProvider.notifier).state = null;
    _scannerController.forward(from: 0.0).then((_) {
      setState(() {
        _isScanning = false;
      });
      
      // Select random muscle
      final keys = LocalMuscleDb.muscles.keys.toList();
      final randomKey = keys[math.Random().nextInt(keys.length)];
      ref.read(selectedMuscleIdProvider.notifier).state = randomKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedMuscleIdProvider);
    final viewMode = ref.watch(viewModeProvider);

    final canPop = selectedId == null && _searchResults.isEmpty && !_searchFocusNode.hasFocus;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
          } else if (_searchResults.isNotEmpty) {
            setState(() {
              _searchResults = [];
            });
          } else if (selectedId != null) {
            ref.read(selectedMuscleIdProvider.notifier).state = null;
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Cyber Grid Background overlay
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

              Column(
                children: [
                  // 1. App Top Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                            children: [
                              const TextSpan(
                                text: 'REVA',
                                style: TextStyle(color: AppColors.neonOrange),
                              ),
                              const TextSpan(
                                text: '.FITTNESS',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Search Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchChanged,
                            style: const TextStyle(fontSize: 12, fontFamily: 'Share Tech Mono'),
                            decoration: InputDecoration(
                              hintText: 'SEARCH MUSCLE (e.g. CHEST, ABS)...',
                              hintStyle: const TextStyle(color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                        _searchFocusNode.unfocus();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        
                        // Search suggestions dropdown overlay
                        if (_searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.borderGlow),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final key = _searchResults[index];
                                final m = LocalMuscleDb.muscles[key]!;
                                return ListTile(
                                  dense: true,
                                  title: Text(m.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  trailing: const Text('[SELECT]', style: TextStyle(fontSize: 9, fontFamily: 'Share Tech Mono', color: AppColors.neonCyan)),
                                  onTap: () {
                                    ref.read(selectedMuscleIdProvider.notifier).state = key;
                                    _searchController.text = m.name.toUpperCase();
                                    setState(() {
                                      _searchResults = [];
                                    });
                                    _searchFocusNode.unfocus();
                                  },
                                );
                              },
                            ),
                          )
                      ],
                    ),
                  ),

                  // 3. Status Ribbon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'TARGET: ',
                              style: TextStyle(fontFamily: 'Share Tech Mono', fontSize: 10, color: AppColors.textMuted),
                            ),
                            Text(
                              selectedId != null 
                                  ? LocalMuscleDb.muscles[selectedId]?.name.toUpperCase() ?? 'NONE'
                                  : 'NONE SELECT',
                              style: const TextStyle(
                                fontFamily: 'Share Tech Mono',
                                fontSize: 11,
                                color: AppColors.neonOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          viewMode == ViewMode.twoD ? 'ANTERIOR/POSTERIOR 2D' : 'INTERACTIVE 3D',
                          style: const TextStyle(
                            fontFamily: 'Share Tech Mono',
                            fontSize: 9,
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Viewport Canvas (SVG / 3D projection)
                  Expanded(
                    child: Stack(
                      children: [
                        // View Canvas (2D vs 3D real human models)
                        Positioned.fill(
                          child: viewMode == ViewMode.twoD
                              ? const BodyView2d()
                              : const BodyView3d(),
                        ),

                        // HUD Corner target bracket details
                        Positioned(
                          top: 15, left: 15,
                          child: Container(width: 12, height: 12, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.textMuted), left: BorderSide(color: AppColors.textMuted)))),
                        ),
                        Positioned(
                          top: 15, right: 15,
                          child: Container(width: 12, height: 12, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.textMuted), right: BorderSide(color: AppColors.textMuted)))),
                        ),
                        
                        // Floating HUD controls (Left side for 2D flip control)
                        if (viewMode == ViewMode.twoD)
                          Positioned(
                            left: 16,
                            top: 40,
                            child: _buildHudBtn(
                              icon: Icons.flip_camera_android,
                              label: 'FLIP',
                              onTap: () => ref.read(isFrontViewProvider.notifier).update((s) => !s),
                            ),
                          ),

                        // Floating HUD controls (Right side for zoom & reset)
                        Positioned(
                          right: 16,
                          top: 40,
                          child: Column(
                            children: [
                              _buildHudBtn(
                                icon: Icons.add,
                                onTap: () => ref.read(zoomLevelProvider.notifier).update((z) => (z + 0.15).clamp(0.65, 1.8)),
                              ),
                              const SizedBox(height: 8),
                              _buildHudBtn(
                                icon: Icons.remove,
                                onTap: () => ref.read(zoomLevelProvider.notifier).update((z) => (z - 0.15).clamp(0.65, 1.8)),
                              ),
                              const SizedBox(height: 8),
                              _buildHudBtn(
                                icon: Icons.home,
                                onTap: () {
                                  ref.read(zoomLevelProvider.notifier).state = 1.0;
                                  ref.read(isFrontViewProvider.notifier).state = true;
                                  ref.read(selectedMuscleIdProvider.notifier).state = null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Buffer to make sure Canvas elements don't get covered by details drawer in basic layout
                  const SizedBox(height: 120),
                ],
              ),

              // 5. Sliding Drawer Info sheet overlay
              const InfoDashboardPanel(),

              // 6. Laser scanner sweep animation overlay
              if (_isScanning)
                AnimatedBuilder(
                  animation: _scannerController,
                  builder: (context, child) {
                    final laserPos = _scannerController.value * MediaQuery.of(context).size.height;
                    return Positioned(
                      top: laserPos,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: AppColors.neonOrange, blurRadius: 10, spreadRadius: 1)
                          ],
                          gradient: LinearGradient(
                            colors: [Colors.transparent, AppColors.neonOrange, Colors.transparent],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        
        // Bottom App Navigation details
        bottomNavigationBar: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 'EXPLORE', Icons.bar_chart, true),

              // Central View Toggle (Merged)
              _buildBottomToggleBtn(context, ref),

              GestureDetector(
                onTap: () => _showSettingsSheet(context, ref),
                child: _buildNavItem(context, 'SETTINGS', Icons.tune, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToggleBtn(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(viewModeProvider);
    final is3d = viewMode == ViewMode.threeD;
    return InkWell(
      onTap: () {
        ref.read(viewModeProvider.notifier).state =
            is3d ? ViewMode.twoD : ViewMode.threeD;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(
            color: is3d ? AppColors.neonCyan : AppColors.neonOrange,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (is3d ? AppColors.neonCyan : AppColors.neonOrange).withValues(alpha: 0.4),
              blurRadius: 15,
            )
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                is3d ? Icons.view_in_ar : Icons.layers,
                size: 16,
                color: is3d ? AppColors.neonCyan : AppColors.neonOrange,
              ),
              const SizedBox(height: 1),
              Text(
                is3d ? '3D' : '2D',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: is3d ? AppColors.neonCyan : AppColors.neonOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHudBtn({required IconData icon, String? label, required VoidCallback onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('--- HUD Button Tapped: $label / ${icon.codePoint}');
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.textPrimary),
            if (label != null)
              Text(
                label,
                style: const TextStyle(fontSize: 7, fontFamily: 'Share Tech Mono', color: AppColors.textSecondary),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, IconData icon, bool isActive) {
    final activeColor = isActive ? AppColors.neonOrange : AppColors.textMuted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: activeColor),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'Share Tech Mono',
            color: isActive ? AppColors.textPrimary : AppColors.textMuted,
          ),
        )
      ],
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SettingsSheet(ref: ref),
    );
  }
}

// ─────────────────────────────────────────
// Settings Bottom Sheet Widget
// ─────────────────────────────────────────
class _SettingsSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _SettingsSheet({required this.ref});

  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    final isFront = ref.watch(isFrontViewProvider);
    final is3d = viewMode == ViewMode.threeD;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111317),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.borderGlow, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.neonOrange, size: 18),
              const SizedBox(width: 10),
              Text(
                'SETTINGS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Configure your REVA.FITTNESS experience',
            style: TextStyle(
              fontFamily: 'Share Tech Mono',
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),

          // ── Section: Display ──────────────────────
          _sectionLabel('DISPLAY'),
          const SizedBox(height: 10),

          _settingTile(
            icon: Icons.view_in_ar_outlined,
            label: 'Default View Mode',
            subtitle: is3d ? 'Interactive 3D Hologram' : 'Anterior / Posterior 2D',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip('2D', !is3d, () {
                  ref.read(viewModeProvider.notifier).state = ViewMode.twoD;
                }),
                const SizedBox(width: 6),
                _chip('3D', is3d, () {
                  ref.read(viewModeProvider.notifier).state = ViewMode.threeD;
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _settingTile(
            icon: Icons.swap_horiz_outlined,
            label: 'Default Body Side (2D)',
            subtitle: isFront ? 'Front view (Anterior)' : 'Back view (Posterior)',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip('FRONT', isFront, () {
                  ref.read(isFrontViewProvider.notifier).state = true;
                }),
                const SizedBox(width: 6),
                _chip('BACK', !isFront, () {
                  ref.read(isFrontViewProvider.notifier).state = false;
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Section: Controls ────────────────────
          _sectionLabel('CONTROLS'),
          const SizedBox(height: 10),

          _settingTile(
            icon: Icons.zoom_out_map_outlined,
            label: 'Reset Zoom & View',
            subtitle: 'Restore camera to default position',
            trailing: GestureDetector(
              onTap: () {
                ref.read(zoomLevelProvider.notifier).state = 1.0;
                ref.read(isFrontViewProvider.notifier).state = true;
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 10,
                    color: AppColors.neonOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          _settingTile(
            icon: Icons.highlight_off_outlined,
            label: 'Clear Selection',
            subtitle: 'Deselect the current muscle target',
            trailing: GestureDetector(
              onTap: () {
                ref.read(selectedMuscleIdProvider.notifier).state = null;
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CLEAR',
                  style: TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 10,
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Section: About ───────────────────────
          _sectionLabel('ABOUT'),
          const SizedBox(height: 10),

          // App Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/reva_logo.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(
                              text: 'REVA',
                              style: TextStyle(color: AppColors.neonOrange),
                            ),
                            const TextSpan(
                              text: ' FITTNESS',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Version 1.4.0  •  Build 2026.06',
                        style: TextStyle(
                          fontFamily: 'Share Tech Mono',
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Human Anatomy & Fitness Explorer',
                        style: TextStyle(
                          fontFamily: 'Share Tech Mono',
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Share Tech Mono',
        fontSize: 9,
        letterSpacing: 2,
        color: AppColors.neonCyan,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Share Tech Mono',
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.neonOrange.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: active ? AppColors.neonOrange : AppColors.border,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Share Tech Mono',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.neonOrange : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

