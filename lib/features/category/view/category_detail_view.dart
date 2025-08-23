// lib/features/category/view/category_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class CategoryDetailView extends StatelessWidget {
  final String categoryId;
  const CategoryDetailView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection:
          l10n.localeName == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, state) {
            if (state is! MarketDataLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final categoriesFound = state.marketData.categories
                .where((c) => c.id == categoryId)
                .toList();
            
            if (categoriesFound.isEmpty) {
              return Center(
                  child: Text('Category with ID $categoryId not found.'));
            }
            final category = categoriesFound.first;

            final productsInCategory = state.marketData.products
                .where((p) => p.categoryID == categoryId)
                .toList();

            final Map<String, List<Product>> productsByStore = {};
            for (var product in productsInCategory) {
              productsByStore.putIfAbsent(product.storeID, () => []).add(product);
            }
            final stores = state.marketData.stores
                .where((s) => productsByStore.keys.contains(s.storeID))
                .toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(category.name),
                  pinned: true,
                  floating: true,
                ),
                if (productsInCategory.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text(l10n.noProductsInCategory)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final store = stores[index];
                          final productsInStore = productsByStore[store.storeID]!;
                          return _StoreProductsCard(
                              store: store, products: productsInStore);
                        },
                        childCount: stores.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// <<< ویجت جدید و زیبا برای نمایش کارت هر فروشگاه با لیست افقی محصولات
class _StoreProductsCard extends StatelessWidget {
  const _StoreProductsCard({
    required this.store,
    required this.products,
  });

  final Store store;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                store.storeImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(store.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(store.address),
            trailing: TextButton(
              onPressed: () => context.go('/store/${store.storeID}'),
              child: Text(l10n.viewStore),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          SizedBox(
            height: 260, // ارتفاع مناسب برای ProductCardView
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, productIndex) {
                return ProductCardView(
                  product: products[productIndex],
                  store: store,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}