import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode { twoD, threeD }

// View Mode Provider (2D vs 3D)
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.twoD);

// Selected Muscle ID Provider (e.g., 'chest', 'quads')
final selectedMuscleIdProvider = StateProvider<String?>((ref) => null);

// Anterior/Posterior Flip State Provider
final isFrontViewProvider = StateProvider<bool>((ref) => true);

// Active Tab in Details Panel Provider
final activeTabProvider = StateProvider<String>((ref) => 'train');

// Zoom factor Provider
final zoomLevelProvider = StateProvider<double>((ref) => 1.0);

// Favorites Notifier & Provider
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggleFavorite(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});
