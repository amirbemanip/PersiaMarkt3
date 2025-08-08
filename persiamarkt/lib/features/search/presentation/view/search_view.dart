// lib/features/search/presentation/view/search_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_state.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_state.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
import 'package:persia_markt/core/widgets/store_list_item_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // برای دسترسی به لیست کامل محصولات و فروشگاه‌ها
    final marketState = context.watch<MarketDataCubit>().state;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'جستجوی محصول یا فروشگاه...',
              border: InputBorder.none,
            ),
            onChanged: (query) {
              if (marketState is MarketDataLoaded) {
                context.read<SearchCubit>().performSearch(
                      query: query,
                      allProducts: marketState.marketData.products,
                      allStores: marketState.marketData.stores,
                    );
              }
            },
          ),
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
                        // Results for Products
                        ListView.builder(
                          itemCount: searchState.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = searchState.filteredProducts[index];
                            final store = (marketState as MarketDataLoaded)
                                .marketData
                                .stores
                                .firstWhere((s) => s.storeID == product.storeID);
                            return ProductListItemView(product: product, store: store);
                          },
                        ),
                        // Results for Stores
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
            return Container();
          },
        ),
      ),
    );
  }
}