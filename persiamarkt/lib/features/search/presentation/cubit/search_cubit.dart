// lib/features/search/presentation/cubit/search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart'; // اصلاح شده
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'search_state.dart';

/// Manages the business logic for the search feature.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  /// Performs a search based on a query against all products and stores.
  ///
  /// [query]: The search term entered by the user.
  /// [allProducts]: The complete list of products to filter.
  /// [allStores]: The complete list of stores to filter.
  void performSearch({
    required String query,
    required List<Product> allProducts,
    required List<Store> allStores,
  }) {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    // Normalize the query for case-insensitive search.
    final lowerCaseQuery = query.toLowerCase();

    // Filter products based on name and description.
    final productResults = allProducts
        .where((p) =>
            p.name.toLowerCase().contains(lowerCaseQuery) ||
            p.description.toLowerCase().contains(lowerCaseQuery))
        .toList();

    // Filter stores based on name, address, and city.
    final storeResults = allStores
        .where((s) =>
            s.name.toLowerCase().contains(lowerCaseQuery) ||
            s.address.toLowerCase().contains(lowerCaseQuery) ||
            s.city.toLowerCase().contains(lowerCaseQuery))
        .toList();

    emit(SearchLoaded(
      filteredProducts: productResults,
      filteredStores: storeResults,
      query: query,
    ));
  }

  /// Resets the search state to its initial value.
  void clearSearch() {
    emit(SearchInitial());
  }
}