import 'package:flutter/material.dart';
import 'package:persia_markt/core/models/store.dart';
import 'package:persia_markt/core/widgets/store_list_item_view.dart';

class StoresByCitySection extends StatelessWidget {
  final List<Store> stores;
  const StoresByCitySection({super.key, required this.stores});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Store>> storesByCity = {};
    for (var store in stores) {
      if (store.city != null && store.city!.isNotEmpty) {
        storesByCity.putIfAbsent(store.city!, () => []).add(store);
      }
    }

    if (storesByCity.isEmpty) return const SizedBox.shrink();

    // استفاده از LayoutBuilder برای تشخیص اندازه صفحه
    return LayoutBuilder(
      builder: (context, constraints) {
        // اگر عرض صفحه بیشتر از ۶۰۰ پیکسل باشد، از گرید استفاده کن
        final bool isWideScreen = constraints.maxWidth > 600;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: storesByCity.keys.length,
          itemBuilder: (context, index) {
            final city = storesByCity.keys.elementAt(index);
            final cityStores = storesByCity[city]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(city, style: Theme.of(context).textTheme.headlineSmall),
                ),
                // بر اساس عرض صفحه، ویجت مناسب را نمایش بده
                isWideScreen
                    ? _buildStoresGrid(cityStores)
                    : _buildStoresList(cityStores),
              ],
            );
          },
        );
      },
    );
  }

  // ویجت برای نمایش لیست عمودی (موبایل)
  Widget _buildStoresList(List<Store> stores) {
    return Column(
      children: stores.map((store) => StoreListItemView(store: store)).toList(),
    );
  }

  // ویجت جدید برای نمایش گرید (تبلت)
  Widget _buildStoresGrid(List<Store> stores) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // دو ستون
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5, // نسبت عرض به ارتفاع هر آیتم
      ),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        // در گرید، margin آیتم‌ها را حذف می‌کنیم تا بهتر نمایش داده شوند
        return StoreListItemView(
          store: stores[index],
          // Note: To make this work perfectly, you might need to adjust StoreListItemView 
          // to accept an optional margin parameter and set it to EdgeInsets.zero here.
        );
      },
    );
  }
}