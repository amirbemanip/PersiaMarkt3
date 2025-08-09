// lib/features/search/presentation/view/search_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
import 'package:persia_markt/core/widgets/store_list_item_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_state.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<SearchCubit>().clearSearch();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final marketState = context.read<MarketDataBloc>().state;
      if (marketState is MarketDataLoaded) {
        context.read<SearchCubit>().performSearch(
              query: query,
              allProducts: marketState.marketData.products,
              allStores: marketState.marketData.stores,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketState = context.watch<MarketDataBloc>().state;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'جستجوی محصول یا فروشگاه...',
              border: InputBorder.none,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<SearchCubit>().clearSearch();
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/'); // مسیر صفحه اصلی
                }
              },
              child: const Text(
                'انصراف',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<SearchCubit, SearchState>(
          builder: (context, searchState) {
            if (searchState is SearchInitial) {
              return const Center(child: Text('لطفاً عبارت مورد نظر را وارد کنید.'));
            }
            if (searchState is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (searchState is SearchLoaded) {
              if (searchState.filteredProducts.isEmpty && searchState.filteredStores.isEmpty) {
                return const Center(child: Text('نتیجه‌ای یافت نشد.'));
              }
              
              final Map<String, List<Product>> groupedProducts = {};
              for (var product in searchState.filteredProducts) {
                groupedProducts.putIfAbsent(product.storeID, () => []).add(product);
              }
              final storeIds = groupedProducts.keys.toList();

              return Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'محصولات (${searchState.filteredProducts.length})'),
                      Tab(text: 'فروشگاه‌ها (${searchState.filteredStores.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ListView.builder(
                          itemCount: storeIds.length,
                          itemBuilder: (context, index) {
                            if (marketState is! MarketDataLoaded) return const SizedBox.shrink();
                            
                            final storeId = storeIds[index];
                            final productsInStore = groupedProducts[storeId]!;
                            final store = marketState.marketData.stores
                                .firstWhere((s) => s.storeID == storeId);

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(store.name, style: Theme.of(context).textTheme.titleLarge),
                                  ),
                                  const Divider(height: 1, indent: 12, endIndent: 12),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: productsInStore.length,
                                    itemBuilder: (context, productIndex) {
                                      final product = productsInStore[productIndex];
                                      return ProductListItemView(product: product, store: store);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ListView.builder(
                          itemCount: searchState.filteredStores.length,
                          itemBuilder: (context, index) {
                            final store = searchState.filteredStores[index];
                            return StoreListItemView(store: store);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
