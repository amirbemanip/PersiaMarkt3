// مسیر: lib/features/cart/view/cart_view.dart

import 'package:flutter/material.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

// نکته: این یک ویجت نمونه است. شما باید منطق مربوط به Bloc را
// برای خواندن و مدیریت آیتم‌های سبد خرید به آن اضافه کنید.

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // این متغیر باید از Bloc خوانده شود
    final bool isCartEmpty = true; // برای نمونه، فرض می‌کنیم سبد خالی است

    return Scaffold(
      appBar: AppBar(
        // ۱. عنوان صفحه ترجمه شد
        title: Text(l10n.yourShoppingCart),
      ),
      body: isCartEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    // ۲. پیام سبد خالی ترجمه شد
                    l10n.yourCartIsEmpty,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              // در اینجا منطق نمایش آیتم‌های سبد خرید قرار می‌گیرد
              itemCount: 0,
              itemBuilder: (context, index) {
                return const ListTile(title: Text('Product Item'));
              },
            ),
    );
  }
}