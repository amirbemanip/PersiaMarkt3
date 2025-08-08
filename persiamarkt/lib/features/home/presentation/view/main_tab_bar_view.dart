// lib/features/home/presentation/view/main_tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/home/presentation/view/home_view.dart';
import 'package:persia_markt/features/map/map_view.dart';
import 'package:persia_markt/features/profile/presentation/view/favorites_view.dart';
import 'package:persia_markt/features/profile/presentation/view/profile_view.dart';

class MainTabBarView extends StatefulWidget {
  const MainTabBarView({Key? key}) : super(key: key);

  @override
  State<MainTabBarView> createState() => _MainTabBarViewState();
}

class _MainTabBarViewState extends State<MainTabBarView> {
  // لیست صفحات اصلی برنامه
  final List<Widget> _pages = [
    const HomeView(),
    const MapView(),
    const FavoritesView(), // جایگزین CartView
    const ProfileView(),
  ];

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // استفاده از IndexedStack برای حفظ وضعیت صفحات هنگام جابجایی بین تب‌ها
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.orange.shade700,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'نقشه'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'موردعلاقه‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'پروفایل'),
          ],
        ),
      ),
    );
  }
}