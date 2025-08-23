import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'search_state.dart';

/// Manages the business logic for the search feature.
class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

  /// Performs a search based on a query against all products and stores.
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

    final lowerCaseQuery = query.toLowerCase();

    // Filter products based on name and description.
    final productResults = allProducts
        .where((p) =>
            p.name.toLowerCase().contains(lowerCaseQuery) ||
            p.description.toLowerCase().contains(lowerCaseQuery))
        .toList();

    // Filter stores based on name, address, and city.
    final storeResults = allStores
        .where((s) {
          final nameMatch = s.name.toLowerCase().contains(lowerCaseQuery);
          final addressMatch = s.address.toLowerCase().contains(lowerCaseQuery);
          // FIXED: Safely handle nullable city by using a null-aware check.
          final cityMatch = s.city?.toLowerCase().contains(lowerCaseQuery) ?? false;
          return nameMatch || addressMatch || cityMatch;
        })
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
