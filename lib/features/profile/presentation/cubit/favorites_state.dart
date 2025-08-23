// lib/features/profile/presentation/cubit/favorites_state.dart
import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<String> productIds;
  const FavoritesState({required this.productIds});

  @override
  List<Object> get props => [productIds];
}