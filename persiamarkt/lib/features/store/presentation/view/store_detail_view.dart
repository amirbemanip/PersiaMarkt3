import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/models/category_item.dart';
import 'package:persia_markt/core/models/product.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/product_list_item_view.dart';
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
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }
  }

  void _scrollToInitialProduct() {
    final marketState = context.read<MarketDataBloc>().state;
    if (marketState is MarketDataLoaded) {
      final product = marketState.marketData.products.firstWhere(
        (p) => p.id == widget.initialProductId,
        orElse: () => marketState.marketData.products.first,
      );
      _scrollToCategory(product.categoryID);
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white, size: 48),
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
        if (state is! MarketDataLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final store = state.marketData.stores
            .firstWhere((s) => s.storeID == widget.storeId, orElse: () => Store.empty());
        if (store.storeID.isEmpty) {
          return const Scaffold(body: Center(child: Text('Store not found.')));
        }

        final allProducts = state.marketData.products
            .where((p) => p.storeID == store.storeID)
            .toList();

        // فقط دسته‌هایی که در این فروشگاه محصول دارند
        final Set<String> categoryIdsInStore =
            allProducts.map((p) => p.categoryID).toSet();
        final categories = state.marketData.categories
            .where((c) => categoryIdsInStore.contains(c.id))
            .toList();

        // کلیدها را قبل از ساخت ویجت‌ها تضمین می‌کنیم
        for (final c in categories) {
          _categoryKeys.putIfAbsent(c.id, () => GlobalKey());
        }

        return Scaffold(
          body: CustomScrollView(
            controller: _pageScrollController,
            slivers: [
              // هدر فروشگاه
              SliverAppBar(
                pinned: true,
                expandedHeight: 140,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 12, end: 16),
                  title: Text(store.name, overflow: TextOverflow.ellipsis),
                ),
              ),

              SliverToBoxAdapter(child: _buildStoreHeader(context, store)),

              // نوار دسته‌بندی افقی (پین‌شونده)
              _buildCategoryHeader(context, categories),

              // لیست محصولات گروه‌بندی‌شده بر اساس دسته
              ..._buildProductSlivers(categories, allProducts, store),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreHeader(BuildContext context, Store store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(child: Text(store.address, style: const TextStyle(fontSize: 16))),
              IconButton(
                icon: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
                tooltip: 'نمایش در نقشه',
                // به‌جای فقط focus، lat/lng را هم پاس می‌دهیم تا حتماً فوکوس شود
                onPressed: () => context.go(
                  '/map?lat=${store.latitude}&lng=${store.longitude}&focus=${store.storeID}',
                ),
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
                onPressed: () => _scrollToCategory(categories[index].id),
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
      final productsInCategory =
          allProducts.where((p) => p.categoryID == category.id).toList();

      return SliverList(
        delegate: SliverChildListDelegate([
          // سکشن‌هدری که کلید روی آن ست می‌شود تا ensureVisible کار کند
          Container(
            key: _categoryKeys[category.id],
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          ...productsInCategory.map(
            (product) => ProductListItemView(
              product: product,
              store: store,
              onImageTap: () => _showImageDialog(context, product.primaryImageUrl),
            ),
          ),
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
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
