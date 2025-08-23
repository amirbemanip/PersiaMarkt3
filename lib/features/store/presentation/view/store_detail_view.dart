// lib/features/store/presentation/view/store_detail_view.dart
import 'dart:async';
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

class _StoreDetailViewState extends State<StoreDetailView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  TabController? _tabController;

  final Map<String, GlobalKey> _categoryKeys = {};
  bool _isTabSwitching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _setupTabController(int categoryCount) {
    if (_tabController == null || _tabController!.length != categoryCount) {
      _tabController?.dispose();
      _tabController = TabController(length: categoryCount, vsync: this);
    }
  }

  void _onScroll() {
    if (_isTabSwitching) return;

    for (var i = 0; i < _categoryKeys.values.length; i++) {
      final key = _categoryKeys.values.elementAt(i);
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        if (position.dy >= 0 && position.dy < 150) {
          if (_tabController!.index != i) {
            _tabController!.animateTo(i);
          }
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _scrollToCategory(String categoryId) {
    final key = _categoryKeys[categoryId];
    if (key != null && key.currentContext != null) {
      setState(() {
        _isTabSwitching = true;
      });
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      ).whenComplete(() {
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _isTabSwitching = false;
          });
        });
      });
    }
  }

  void _scrollToInitialProduct() {
    final marketState = context.read<MarketDataBloc>().state;
    if (marketState is MarketDataLoaded) {
      final product = marketState.marketData.products.firstWhere(
        (p) => p.id == widget.initialProductId,
        orElse: () => marketState.marketData.products.first,
      );
      Future.delayed(const Duration(milliseconds: 200), () {
        _scrollToCategory(product.categoryID);
      });
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.white, size: 48),
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
    return Scaffold(
      body: BlocBuilder<MarketDataBloc, MarketDataState>(
        builder: (context, state) {
          if (state is! MarketDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final store = state.marketData.stores.firstWhere(
              (s) => s.storeID == widget.storeId,
              orElse: () => Store.empty());
          if (store.storeID.isEmpty) {
            return const Center(child: Text('Store not found.'));
          }

          final allProductsInStore = state.marketData.products
              .where((p) => p.storeID == widget.storeId)
              .toList();
          final categoryIdsInStore =
              allProductsInStore.map((p) => p.categoryID).toSet();
          final categories = state.marketData.categories
              .where((c) => categoryIdsInStore.contains(c.id))
              .toList();

          for (var cat in categories) {
            _categoryKeys.putIfAbsent(cat.id, () => GlobalKey());
          }

          _setupTabController(categories.length);

          return DefaultTabController(
            length: categories.length,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildSliverAppBar(context, store),
                // <<< ویجت جدید برای نمایش مشخصات فروشگاه
                _buildStoreInfoSliver(context, store),
                _buildSliverPersistentHeader(context, categories),
                ...categories.expand((category) {
                  final productsInCategory = allProductsInStore
                      .where((p) => p.categoryID == category.id)
                      .toList();
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        key: _categoryKeys[category.id],
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          category.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = productsInCategory[index];
                          return ProductListItemView(
                            product: product,
                            store: store,
                            onImageTap: () => _showImageDialog(
                                context, product.primaryImageUrl),
                          );
                        },
                        childCount: productsInCategory.length,
                      ),
                    ),
                  ];
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Store store) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(store.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              shadows: [Shadow(blurRadius: 4.0)],
            )),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              store.storeImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/supermarket.png',
                      fit: BoxFit.cover),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // <<< ویجت کاملاً جدید برای نمایش مشخصات فروشگاه
  Widget _buildStoreInfoSliver(BuildContext context, Store store) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(store.address,
                        style: Theme.of(context).textTheme.bodyLarge)),
                IconButton(
                  icon: Icon(Icons.map_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'نمایش در نقشه',
                  onPressed: () => context.go(
                    '/map?lat=${store.latitude}&lng=${store.longitude}&focus=${store.storeID}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star_border,
                    size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text('امتیاز: ${store.rating}',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverPersistentHeader _buildSliverPersistentHeader(
      BuildContext context, List<CategoryItem> categories) {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs:
              categories.map((category) => Tab(text: category.name)).toList(),
          onTap: (index) => _scrollToCategory(categories[index].id),
        ),
      ),
      pinned: true,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}