// lib/features/store/presentation/view/store_detail_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import های اصلاح شده
import 'package:persia_markt/core/models/category_item.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/error_view.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import 'package:persia_markt/features/map/view/map_view.dart'; // این خط در این فایل استفاده نمی‌شود و در کد اصلی شما حذف شده است

class StoreDetailView extends StatefulWidget {
  final String storeId;
  final String? initialProductId;

  const StoreDetailView({
    super.key,
    required this.storeId,
    this.initialProductId,
  });

  @override
  State<StoreDetailView> createState() => _StoreDetailViewState();
}

class _StoreDetailViewState extends State<StoreDetailView> {
  // از GlobalKey برای اسکرول به دسته‌بندی‌ها استفاده می‌کنیم
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialProductId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitialProduct());
    }
  }

  void _scrollToCategory(String categoryId) {
    final key = _categoryKeys[categoryId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToInitialProduct() {
    final marketState = context.read<MarketDataBloc>().state;
    if (marketState is MarketDataLoaded) {
      final product = marketState.marketData.products.firstWhere((p) => p.productID == widget.initialProductId);
      // با کمی تاخیر اسکرول می‌کنیم تا همه ویجت‌ها ساخته شده باشند
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToCategory(product.categoryID);
      });
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: InteractiveViewer(
                    child: Image.network(imageUrl,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.white, size: 48)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDataBloc, MarketDataState>(
      builder: (context, state) {
        if (state is MarketDataLoaded) {
          final store = state.marketData.stores.firstWhere((s) => s.storeID == widget.storeId);
          final storeProducts = state.marketData.products
              .where((p) => p.storeID == store.storeID)
              .toList();
          final categoriesInStore = state.marketData.categories
              .where((c) => storeProducts.any((p) => p.categoryID == c.categoryID))
              .toList();

          // مقداردهی کلیدها برای هر دسته‌بندی
          for (var category in categoriesInStore) {
            _categoryKeys.putIfAbsent(category.categoryID, () => GlobalKey());
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              // اصلاح شده: استفاده از CustomScrollView برای اسکرول یکپارچه
              body: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, store),
                  _buildStoreDetailsSliver(context, store),
                  _buildCategoryHeader(context, categoriesInStore),
                  // لیست محصولات به صورت مجموعه‌ای از Sliver ها به اینجا منتقل شد
                  ..._buildProductSlivers(categoriesInStore, storeProducts, store),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Store store) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(store.name, style: const TextStyle(fontSize: 16.0)),
        background: Image.network(store.storeImage,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset('assets/images/supermarket.png', fit: BoxFit.cover)),
      ),
    );
  }

  Widget _buildStoreDetailsSliver(BuildContext context, Store store) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Expanded(child: Text(store.address, style: const TextStyle(fontSize: 16))),
                IconButton(
                  icon: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
                  tooltip: 'نمایش در نقشه',
                  onPressed: () {
                    context.go('/map?lat=${store.location.lat}&lng=${store.location.lng}');
                  },
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.star_border, size: 16, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text('امتیاز: ${store.rating}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverPersistentHeader _buildCategoryHeader(
      BuildContext context, List<CategoryItem> categories) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 60.0,
        maxHeight: 60.0,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(240),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  _scrollToCategory(categories[index].categoryID);
                },
                child: Text(categories[index].name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// این متد جدید، لیست محصولات را به صورت مجموعه‌ای از Sliverها برمی‌گرداند
  List<Widget> _buildProductSlivers(
      List<CategoryItem> categories, List<Product> allProducts, Store store) {
    // از map برای تبدیل هر دسته‌بندی به یک SliverList استفاده می‌کنیم
    return categories.map((category) {
      final productsInCategory = allProducts
          .where((p) => p.categoryID == category.categoryID)
          .toList();

      return SliverList(
        delegate: SliverChildListDelegate([
          // هدر دسته‌بندی
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            // اضافه کردن کلید به هر هدر برای قابلیت اسکرول
            child: Text(category.name, key: _categoryKeys[category.categoryID], style: Theme.of(context).textTheme.headlineSmall),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          // لیست محصولات این دسته‌بندی
          ...productsInCategory.map((product) => ProductListItemView(
                product: product,
                store: store,
                onImageTap: () => _showImageDialog(context, product.imageURL),
              )),
        ]),
      );
    }).toList();
  }
}

// کلاس کمکی برای هدر چسبان
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}