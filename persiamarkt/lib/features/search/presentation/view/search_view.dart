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
import 'package:persia_markt/l10n/app_localizations.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final TabController _tabController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onChanged(String text, MarketDataState marketState) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (marketState is MarketDataLoaded) {
        context.read<SearchCubit>().performSearch(
              query: text,
              allProducts: marketState.marketData.products,
              allStores: marketState.marketData.stores,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<MarketDataBloc, MarketDataState>(
      builder: (context, marketState) {
        return Scaffold(
          appBar: AppBar(
            // ۶. افزودن دکمه انصراف
            // این دکمه به صورت خودکار در سمت چپ یا راست (بسته به زبان) قرار می‌گیرد
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.cancel,
              onPressed: () {
                // پاک کردن نتایج جستجو قبل از خروج
                context.read<SearchCubit>().clearSearch();
                // بازگشت به صفحه قبلی
                context.pop();
              },
            ),
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                border: InputBorder.none,
              ),
              onChanged: (t) => _onChanged(t, marketState),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.allProducts),
                Tab(text: l10n.stores),
              ],
            ),
          ),
          body: BlocBuilder<SearchCubit, SearchState>(
            builder: (context, searchState) {
              if (searchState is SearchInitial) {
                return Center(
                    child: Text('لطفاً عبارت مورد نظر را وارد کنید.'));
              }
              if (searchState is SearchLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (searchState is SearchLoaded) {
                if (searchState.filteredProducts.isEmpty &&
                    searchState.filteredStores.isEmpty) {
                  return const Center(child: Text('نتیجه‌ای یافت نشد.'));
                }

                final Map<String, List<Product>> groupedProducts = {};
                for (var product in searchState.filteredProducts) {
                  groupedProducts.putIfAbsent(product.storeID, () => []).add(product);
                }
                final storeIds = groupedProducts.keys.toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // محصولات
                    ListView.builder(
                      itemCount: storeIds.length,
                      itemBuilder: (context, index) {
                        if (marketState is! MarketDataLoaded) {
                          return const SizedBox.shrink();
                        }

                        final storeId = storeIds[index];
                        final productsInStore = groupedProducts[storeId]!;
                        final store = marketState.marketData.stores
                            .firstWhere((s) => s.storeID == storeId);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(store.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                              ),
                              const Divider(height: 1, indent: 12, endIndent: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: productsInStore.length,
                                itemBuilder: (context, productIndex) {
                                  final product = productsInStore[productIndex];
                                  return ProductListItemView(
                                      product: product, store: store);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // فروشگاه‌ها
                    ListView.builder(
                      itemCount: searchState.filteredStores.length,
                      itemBuilder: (context, index) {
                        final store = searchState.filteredStores[index];
                        return StoreListItemView(store: store);
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
