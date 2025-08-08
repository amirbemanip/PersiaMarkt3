// lib/features/profile/presentation/view/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
// اصلاح شد: 'packagepackage:' به 'package:' تغییر یافت.
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_state.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سبد خرید شما')),
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, marketState) {
          if (marketState is MarketDataLoaded) {
            return BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, favoritesState) {
                final favoriteProducts = marketState.marketData.products
                    .where((p) => favoritesState.productIds.contains(p.productID))
                    .toList();
                
                if (favoriteProducts.isEmpty) {
                  return const Center(child: Text('سبد خرید شما خالی است.'));
                }

                // اصلاح شده: گروه‌بندی محصولات بر اساس فروشگاه
                final Map<String, List<Product>> productsByStore = {};
                for (var product in favoriteProducts) {
                  productsByStore.putIfAbsent(product.storeID, () => []).add(product);
                }
                
                final double grandTotal = favoriteProducts.fold(0, (sum, item) => sum + item.price);

                return Column(
                  children: [
                    // اصلاح شده: بنر تبلیغاتی
                    Container(
                      height: 100,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/banner4.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: productsByStore.keys.length,
                        itemBuilder: (context, index) {
                          final storeId = productsByStore.keys.elementAt(index);
                          final store = marketState.marketData.stores.firstWhere((s) => s.storeID == storeId);
                          final productsInStore = productsByStore[storeId]!;
                          final double storeSubtotal = productsInStore.fold(0, (sum, item) => sum + item.price);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(store.name, style: Theme.of(context).textTheme.titleLarge),
                                ),
                                const Divider(height: 1),
                                ...productsInStore.map((p) => ProductListItemView(product: p, store: store)),
                                // نمایش مجموع قیمت هر فروشگاه
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'جمع: €${storeSubtotal.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // نمایش مجموع کل
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'مجموع کل: €${grandTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // اصلاح شده: کادر نهایی
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: const Text(
                        'به زودی قابلیت ارسال سفارش به این اپلیکیشن اضافه خواهد شد.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}