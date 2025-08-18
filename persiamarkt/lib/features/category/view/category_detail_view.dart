import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/widgets/product_card_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

class CategoryDetailView extends StatelessWidget {
  final String categoryId;
  const CategoryDetailView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, state) {
          if (state is MarketDataLoaded) {
            // FIXED: Use the new 'id' property instead of 'categoryID'.
            final category = state.marketData.categories.firstWhere(
              (c) => c.id == categoryId,
              // Provide a fallback to prevent crashing if the category is not found.
              orElse: () => state.marketData.categories.first,
            );

            // 1. Find all products in this category.
            final productsInCategory = state.marketData.products
                .where((p) => p.categoryID == categoryId)
                .toList();

            // 2. Identify the unique stores that have these products.
            final storeIds = productsInCategory.map((p) => p.storeID).toSet();
            final stores = state.marketData.stores
                .where((s) => storeIds.contains(s.storeID))
                .toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(category.name),
                  pinned: true,
                ),
                if (stores.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('محصولی در این دسته‌بندی یافت نشد.')),
                  )
                else
                  // 3. Create a vertical list of stores.
                  SliverList.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      // 4. Filter products for the horizontal list within each store.
                      final productsInStore = productsInCategory
                          .where((p) => p.storeID == store.storeID)
                          .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            // Store header information
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(store.storeImage),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(store.address),
                            ),
                            // Horizontal list of products for this store
                            SizedBox(
                              height: 250, // Height for ProductCardView
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productsInStore.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, productIndex) {
                                  return ProductCardView(
                                    product: productsInStore[productIndex],
                                    store: store,
                                  );
                                },
                              ),
                            ),
                            // Button to navigate to the store's detail page
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton.icon(
                                  onPressed: () => context.go('/store/${store.storeID}'),
                                  icon: const Icon(Icons.storefront_outlined),
                                  label: const Text('مشاهده فروشگاه'),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ],
            );
          }
          // Show a loading indicator while data is being fetched.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
