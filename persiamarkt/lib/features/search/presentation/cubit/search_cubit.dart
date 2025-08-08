// lib/features/search/presentation/cubit/search_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());

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

    final productResults = allProducts
        .where((p) =>
            p.name.toLowerCase().contains(lowerCaseQuery) ||
            p.description.toLowerCase().contains(lowerCaseQuery))
        .toList();

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

  void clearSearch() {
    emit(SearchInitial());
  }
}