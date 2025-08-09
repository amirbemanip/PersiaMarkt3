// lib/features/store/presentation/view/store_detail_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/category_item.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

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
  final Map<String, GlobalKey> _categoryKeys = {};
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageScrollController.jumpTo(0.0);
      if (widget.initialProductId != null) {
        _scrollToInitialProduct();
      }
    });
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(String categoryId) {
    final key = _categoryKeys[categoryId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1, // قرارگیری کمی پایین‌تر از هدر
      );
    }
  }

  void _scrollToInitialProduct() {
    final marketState = context.read<MarketDataBloc>().state;
    if (marketState is MarketDataLoaded) {
      final product = marketState.marketData.products
          .firstWhere((p) => p.productID == widget.initialProductId, orElse: () => Product.empty());
      if (product.productID.isNotEmpty) {
        _scrollToCategory(product.categoryID);
      }
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

          // ساخت key برای هر دسته‌بندی در صورت عدم وجود
          for (var category in categoriesInStore) {
            _categoryKeys.putIfAbsent(category.categoryID, () => GlobalKey());
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CustomScrollView(
                controller: _pageScrollController,
                slivers: [
                  _buildSliverAppBar(context, store),
                  _buildStoreDetailsSliver(context, store),
                  _buildCategoryHeader(context, categoriesInStore),
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
                    context.go('/map?lat=${store.location.lat}&lng=${store.location.lng}&focus=${store.storeID}');
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
                onPressed: () => _scrollToCategory(categories[index].categoryID),
                child: Text(categories[index].name),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProductSlivers(
      List<CategoryItem> categories, List<Product> allProducts, Store store) {
    return categories.map((category) {
      final productsInCategory = allProducts
          .where((p) => p.categoryID == category.categoryID)
          .toList();

      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              category.name,
              key: _categoryKeys[category.categoryID],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          ...productsInCategory.map((product) => ListTile(
                leading: GestureDetector(
                  onTap: () => _showImageDialog(context, product.imageURL),
                  child: Image.network(product.imageURL,
                      width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image)),
                ),
                title: Text(product.name),
                subtitle: Text('${product.price} تومان'),
              )),
        ]),
      );
    }).toList();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}
