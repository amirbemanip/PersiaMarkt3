// lib/core/config/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/home/presentation/view/home_view.dart';
import 'package:persia_markt/features/search/presentation/view/search_view.dart';
import 'package:persia_markt/features/profile/presentation/view/favorites_view.dart';
import 'package:persia_markt/features/home/presentation/view/main_tab_bar_view.dart';
// import سایر صفحات مانند StoreDetailView, CategoryView و ...

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // این مسیر اصلی برنامه است که شامل BottomNavigationBar می‌باشد
      GoRoute(
        path: '/',
        builder: (context, state) => const MainTabBarView(),
      ),
      // این یک مسیر جداگانه برای جستجو است که به صورت تمام صفحه باز می‌شود
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchView(),
      ),
      // می‌توانید مسیرهای دیگر مانند جزئیات فروشگاه را نیز به همین شکل اضافه کنید
      // GoRoute(
      //   path: '/store/:storeId',
      //   builder: (context, state) {
      //     final storeId = state.pathParameters['storeId']!;
      //     // منطق پیدا کردن فروشگاه و ارسال به ویجت
      //     return StoreDetailView(storeId: storeId);
      //   },
      // ),
    ],
  );
}