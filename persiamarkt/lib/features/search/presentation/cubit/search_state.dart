// lib/features/search/presentation/cubit/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Product> filteredProducts;
  final List<Store> filteredStores;
  final String query;

  const SearchLoaded({
    required this.filteredProducts,
    required this.filteredStores,
    required this.query,
  });

  @override
  List<Object> get props => [filteredProducts, filteredStores, query];
}