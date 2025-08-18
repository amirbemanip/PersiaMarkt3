import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/app_routes.dart';
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
      textDirection: l10n.localeName == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: BlocBuilder<MarketDataBloc, MarketDataState>(
          builder: (context, state) {
            if (state is MarketDataLoaded) {
              final category = state.marketData.categories
                  .where((c) => c.id == categoryId)
                  .firstOrNull;

              if (category == null) {
                return Center(child: Text('Category with ID $categoryId not found.'));
              }

              // 1. Filter products using the correct property name: categoryID
              final productsInCategory = state.marketData.products
                  .where((p) => p.categoryID == categoryId)
                  .toList();

              // 2. Find unique stores using the correct property name: storeID
              final storeIds = productsInCategory.map((p) => p.storeID).toSet();
              final stores = state.marketData.stores
                  // 3. Match stores using the correct property name: storeID
                  .where((s) => storeIds.contains(s.storeID))
                  .toList();

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text(category.name),
                    pinned: true,
                    floating: true,
                  ),
                  if (stores.isEmpty)
                    SliverFillRemaining(
                      child: Center(child: Text(l10n.noProductsInCategory)),
                    )
                  else
                    SliverList.builder(
                      itemCount: stores.length,
                      itemBuilder: (context, index) {
                        final store = stores[index];
                        final productsInStore = productsInCategory
                            // 4. Filter products for the store using the correct property name: storeID
                            .where((p) => p.storeID == store.storeID)
                            .toList();

                        return _StoreProductsCard(store: store, products: productsInStore);
                      },
                    ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(store.storeImage),
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(store.address),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, productIndex) {
                return ProductCardView(
                  product: products[productIndex],
                  store: store,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                // 5. Navigate using the correct property name: storeID
                onPressed: () => context.go(AppRoutes.storeDetailPath(store.storeID)),
                icon: const Icon(Icons.storefront_outlined),
                label: Text(l10n.viewStore),
              ),
            ),
          )
        ],
      ),
    );
  }
}