// lib/features/home/presentation/view/main_tab_bar_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <<< ایمپورت جدید
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart'; // <<< ایمپورت جدید
import 'package:persia_markt/features/cart/presentation/cubit/cart_state.dart'; // <<< ایمپورت جدید
import 'package:persia_markt/l10n/app_localizations.dart';

class MainTabBarView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainTabBarView({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection:
          l10n.localeName == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.home),
            BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
                activeIcon: const Icon(Icons.map),
                label: l10n.map),
            BottomNavigationBarItem(
              // <<< ویجت جدید برای نمایش آیکون سبد خرید به همراه Badge
              icon: _CartIconWithBadge(),
              label: l10n.favorites, // l10n.favorites حالا به معنی "سبد خرید" است
            ),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l10n.profile),
          ],
        ),
      ),
    );
  }
}

// <<< ویجت کاملاً جدید و اختصاصی برای ساخت آیکون سبد خرید با نشانگر تعداد
class _CartIconWithBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        // تعداد کل آیتم‌ها را محاسبه می‌کنیم (نه فقط تعداد محصولات مختلف)
        final totalItems = state.items.values.fold(0, (sum, quantity) => sum + quantity);

        return Stack(
          clipBehavior: Clip.none, // اجازه می‌دهد Badge از کادر بیرون بزند
          children: [
            // آیکون اصلی
            const Icon(Icons.shopping_cart_outlined),
            // اگر آیتمی در سبد بود، Badge را نمایش بده
            if (totalItems > 0)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white, width: 1.5)
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}