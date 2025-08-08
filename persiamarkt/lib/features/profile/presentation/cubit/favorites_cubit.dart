// lib/features/profile/presentation/cubit/favorites_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';

// State for Favorites
class FavoritesState extends Equatable {
  final List<String> productIds;
  const FavoritesState({required this.productIds});

  @override
  List<Object> get props => [productIds];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final SharedPreferences _sharedPreferences;
  static const _key = 'likedProducts';

  FavoritesCubit({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const FavoritesState(productIds: []));

  void loadLikedProducts() {
    final likedIds = _sharedPreferences.getStringList(_key) ?? [];
    emit(FavoritesState(productIds: likedIds));
  }

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