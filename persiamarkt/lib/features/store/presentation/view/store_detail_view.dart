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
// ==================== اصلاح اول اینجاست ====================
// پکیج مورد نیاز برای اسکرول قابل اطمینان وارد شد.
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// ==========================================================

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
  // ==================== اصلاح دوم اینجاست ====================
  // کنترلرهای جدید برای مدیریت اسکرول با پکیج جدید
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  // این متغیر، نقشه دسته‌بندی‌ها به ایندکس لیست را نگه می‌دارد
  final Map<String, int> _categoryIndexMap = {};
  // ==========================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProductId != null) {
        _scrollToInitialProduct();
      }
    });
  }

  // تابع جدید برای اسکرول کردن با کنترلر جدید
  void _scrollToCategory(String categoryId) {
    final index = _categoryIndexMap[categoryId];
    if (index != null && _itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
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
      // کمی تاخیر می‌دهیم تا لیست ساخته شود و سپس اسکرول می‌کنیم
      Future.delayed(const Duration(milliseconds: 100), () {
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

        final allProductsInStore = state.marketData.products
            .where((p) => p.storeID == widget.storeId)
            .toList();
        
        final categoryIdsInStore = allProductsInStore.map((p) => p.categoryID).toSet();
        final categories = state.marketData.categories
            .where((c) => categoryIdsInStore.contains(c.id))
            .toList();

        // ==================== اصلاح سوم اینجاست ====================
        // یک لیست یکپارچه از تمام آیتم‌ها (هدر، دسته‌بندی، محصولات) می‌سازیم
        final List<dynamic> items = [];
        items.add(store); // آیتم اول: اطلاعات فروشگاه برای هدر
        items.add(categories); // آیتم دوم: لیست دسته‌بندی‌ها برای نوار افقی

        int currentIndex = 2; // شمارنده ایندکس برای نقشه
        _categoryIndexMap.clear();

        for (var category in categories) {
          _categoryIndexMap[category.id] = currentIndex;
          items.add(category); // اضافه کردن خود دسته‌بندی به عنوان عنوان
          currentIndex++;
          final productsInCategory = allProductsInStore.where((p) => p.categoryID == category.id).toList();
          items.addAll(productsInCategory);
          currentIndex += productsInCategory.length;
        }
        // ==========================================================

        return Scaffold(
          // AppBar ساده برای دکمه بازگشت
          appBar: AppBar(
            title: Text(store.name),
          ),
          body: Column(
            children: [
              // نوار دسته‌بندی افقی
              _buildCategoryHeader(context, categories),
              // لیست اصلی محصولات با قابلیت اسکرول
              Expanded(
                child: ScrollablePositionedList.builder(
                  itemCount: items.length,
                  itemScrollController: _itemScrollController,
                  itemPositionsListener: _itemPositionsListener,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    if (index == 0 && item is Store) {
                      return _buildStoreHeader(context, item);
                    }
                    if (index == 1) {
                      // این آیتم توسط نوار دسته‌بندی بالا نمایش داده می‌شود، پس اینجا چیزی نمی‌سازیم
                      return const SizedBox.shrink();
                    }
                    if (item is CategoryItem) {
                      return _buildCategoryTitle(context, item);
                    }
                    if (item is Product) {
                      return ProductListItemView(
                        product: item,
                        store: store,
                        onImageTap: () => _showImageDialog(context, item.primaryImageUrl),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreHeader(BuildContext context, Store store) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Padding بالا حذف شد
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(child: Text(store.address, style: const TextStyle(fontSize: 16))),
              IconButton(
                icon: Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
                tooltip: 'نمایش در نقشه',
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
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, List<CategoryItem> categories) {
    return Container(
      height: 60.0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: () => _scrollToCategory(categories[index].id),
            child: Text(categories[index].name),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(BuildContext context, CategoryItem category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        category.name,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
