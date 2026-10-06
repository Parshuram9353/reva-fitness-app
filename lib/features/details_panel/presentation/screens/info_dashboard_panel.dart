import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anatomy_fitness_app_mobile/core/theme/app_colors.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/data/datasources/local_muscle_db.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/presentation/providers/selected_muscle_provider.dart';
import 'package:anatomy_fitness_app_mobile/features/anatomy/domain/entities/muscle.dart';

class InfoDashboardPanel extends ConsumerWidget {
  const InfoDashboardPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedMuscleIdProvider);
    final activeTab = ref.watch(activeTabProvider);

    final isSelected = selectedId != null && LocalMuscleDb.muscles.containsKey(selectedId);
    final muscle = isSelected ? LocalMuscleDb.muscles[selectedId] : null;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: 0,
      left: 0,
      right: 0,
      height: isSelected ? 340 : 130, // Expands upwards when a muscle is active
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              offset: const Offset(0, -5),
              blurRadius: 15,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle and Title bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.neonOrange : AppColors.textMuted,
                          boxShadow: isSelected
                              ? [const BoxShadow(color: AppColors.neonOrange, blurRadius: 8)]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        muscle?.name ?? 'SELECT A MUSCLE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isSelected 
                          ? 'BIOMECHANICAL SCAN STATUS: SECURE' 
                          : 'Tap any muscle on the model to scan anatomy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'Share Tech Mono',
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected && muscle != null) ...[
              // Tab selector headers
              Container(
                height: 38,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabButton(context, ref, 'train', 'TRAIN', activeTab),
                    _buildTabButton(context, ref, 'anatomy', 'ANATOMY', activeTab),
                    _buildTabButton(context, ref, 'mistakes', 'MISTAKES', activeTab),
                    _buildTabButton(context, ref, 'stretch', 'STRETCH', activeTab),
                    _buildTabButton(context, ref, 'nutrition', 'RECOVERY', activeTab),
                  ],
                ),
              ),

              // Tab contents
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ..._buildPanelContent(muscle, activeTab),
                  ],
                ),
              ),
            ] else
              // Muted instructions placeholder when nothing is selected
              const Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: Opacity(
                      opacity: 0.4,
                      child: Text(
                        'Select a muscle zone from the hologram above to initiate training databases.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontFamily: 'Share Tech Mono'),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, WidgetRef ref, String tabId, String label, String activeTab) {
    final isActive = tabId == activeTab;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(activeTabProvider.notifier).state = tabId,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.neonOrange : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'Share Tech Mono',
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.neonOrange : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPanelContent(Muscle muscle, String activeTab) {
    if (activeTab == 'train') {
      return muscle.exercises.map<Widget>((ex) {
        return _buildCard(ex.type, ex.title, ex.desc, AppColors.neonOrange);
      }).toList();
    } else if (activeTab == 'anatomy') {
      return [
        _buildCard('Specifications', 'Biomechanical Structure', muscle.details, AppColors.neonCyan),
        _buildCard('Core Action', 'Kinematics Function', muscle.function, AppColors.neonCyan),
      ];
    } else if (activeTab == 'mistakes') {
      return muscle.mistakes.map<Widget>((mis) {
        return _buildCard(mis.risk, mis.title, mis.desc, AppColors.neonRed);
      }).toList();
    } else if (activeTab == 'stretch') {
      return muscle.stretches.map<Widget>((st) {
        return _buildCard(st.type, st.title, st.desc, AppColors.neonCyan);
      }).toList();
    } else if (activeTab == 'nutrition') {
      return muscle.nutrition.map<Widget>((nut) {
        return _buildCard(nut.type, nut.title, nut.desc, AppColors.neonCyan);
      }).toList();
    }
    return [];
  }

  Widget _buildCard(String badge, String title, String desc, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.01),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Share Tech Mono',
                fontSize: 9,
                color: accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
