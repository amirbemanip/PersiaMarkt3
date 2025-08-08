// lib/features/profile/presentation/cubit/favorites_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_state.dart';

/// Manages the state of the user's favorite products.
/// It uses SharedPreferences for persistence.
class FavoritesCubit extends Cubit<FavoritesState> {
  final SharedPreferences _sharedPreferences;
  static const _key = 'likedProducts';

  FavoritesCubit({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const FavoritesState(productIds: []));

  /// Loads the list of liked product IDs from local storage.
  void loadLikedProducts() {
    final likedIds = _sharedPreferences.getStringList(_key) ?? [];
    emit(FavoritesState(productIds: likedIds));
  }

  /// Toggles the like status of a product and saves it to local storage.
  Future<void> toggleLike(String productId) async {
    final currentIds = List<String>.from(state.productIds);
    if (currentIds.contains(productId)) {
      currentIds.remove(productId);
    } else {
      currentIds.add(productId);
    }
    await _sharedPreferences.setStringList(_key, currentIds);
    emit(FavoritesState(productIds: currentIds));
  }
}