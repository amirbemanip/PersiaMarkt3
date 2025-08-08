// lib/features/category/view/category_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import های اضافی حذف شدند
import 'package:persia_markt/core/widgets/product_card_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
// import 'packagepackage:persia_markt/features/home/presentation/bloc/market_data_state.dart'; -> اصلاح شد
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';

class CategoryDetailView extends StatelessWidget {
  final String categoryId;
  const CategoryDetailView({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, state) {
          if (state is MarketDataLoaded) {
            final category = state.marketData.categories.firstWhere((c) => c.categoryID == categoryId);
            
            // ۱. ابتدا تمام محصولات این دسته‌بندی را پیدا می‌کنیم
            final productsInCategory = state.marketData.products.where((p) => p.categoryID == categoryId).toList();
            
            // ۲. سپس فروشگاه‌هایی که این محصولات را دارند، شناسایی می‌کنیم
            final storeIds = productsInCategory.map((p) => p.storeID).toSet();
            final stores = state.marketData.stores.where((s) => storeIds.contains(s.storeID)).toList();

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
                  // ۳. یک لیست عمودی از فروشگاه‌ها می‌سازیم
                  SliverList.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      // ۴. محصولات هر فروشگاه را برای لیست افقی فیلتر می‌کنیم
                      final productsInStore = productsInCategory.where((p) => p.storeID == store.storeID).toList();
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            // هدر اطلاعات فروشگاه
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(store.storeImage),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(store.address),
                            ),
                            // لیست افقی محصولات این فروشگاه
                            SizedBox(
                              height: 250, // ارتفاع برای ProductCardView
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productsInStore.length,
                                padding: const EdgeInsets.all(8),
                                itemBuilder: (context, productIndex) {
                                  return ProductCardView(
                                    product: productsInStore[productIndex], 
                                    store: store
                                  );
                                },
                              ),
                            ),
                            // دکمه رفتن به صفحه فروشگاه
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
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}