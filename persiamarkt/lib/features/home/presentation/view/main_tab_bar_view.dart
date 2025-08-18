// مسیر: lib/features/home/presentation/view/main_tab_bar_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ۱. این import برای دسترسی به ترجمه‌ها ضروری است
import 'package:persia_markt/l10n/app_localizations.dart';

class MainTabBarView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainTabBarView({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // ۲. نمونه l10n برای استفاده در ویجت ساخته می‌شود
    final l10n = AppLocalizations.of(context)!;

    // Directionality برای پشتیبانی صحیح از زبان فارسی اضافه شد
    return Directionality(
      textDirection: l10n.localeName == 'fa' ? TextDirection.rtl : TextDirection.ltr,
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
          type: BottomNavigationBarType.fixed, // برای نمایش صحیح همه لیبل‌ها
          items: [
            // ۳. تمام لیبل‌ها اکنون از l10n خوانده می‌شوند
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.home),
            BottomNavigationBarItem(
                icon: const Icon(Icons.map_outlined),
                activeIcon: const Icon(Icons.map),
                label: l10n.map),
            BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_border),
                activeIcon: const Icon(Icons.favorite),
                label: l10n.favorites),
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