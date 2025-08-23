// lib/features/search/presentation/cubit/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';

/// Base class for all states related to the search feature.
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object> get props => [];
}

/// The initial state before any search query is entered.
class SearchInitial extends SearchState {}

/// The state indicating that a search is in progress.
class SearchLoading extends SearchState {}

/// The state representing successfully loaded search results.
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