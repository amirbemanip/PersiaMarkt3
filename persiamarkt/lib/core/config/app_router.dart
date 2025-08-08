// lib/core/config/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/category/view/category_detail_view.dart';
import 'package:persia_markt/features/home/presentation/view/home_view.dart';
// اصلاح شد: 'packagepackage:' به 'package:' تغییر یافت.
import 'package:persia_markt/features/home/presentation/view/main_tab_bar_view.dart';
import 'package:persia_markt/features/map/view/map_view.dart';
import 'package:persia_markt/features/profile/presentation/view/favorites_view.dart';
import 'package:persia_markt/features/profile/presentation/view/profile_view.dart';
import 'package:persia_markt/features/search/presentation/view/search_view.dart';
import 'package:persia_markt/features/store/presentation/view/store_detail_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'shellMap');
final _shellNavigatorFavoritesKey = GlobalKey<NavigatorState>(debugLabel: 'shellFavorites');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabBarView(navigationShell: navigationShell);
        },
        branches: [
          // Branch (شاخه) برای تب "خانه"
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeView(),
                routes: [
                  GoRoute(
                    path: 'store/:storeId',
                    builder: (context, state) {
                      final storeId = state.pathParameters['storeId']!;
                      final initialProductId = state.uri.queryParameters['productId'];
                      return StoreDetailView(
                        storeId: storeId,
                        initialProductId: initialProductId,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'category/:categoryId',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['categoryId']!;
                      return CategoryDetailView(categoryId: categoryId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch برای تب "نقشه"
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMapKey,
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) {
                  // پارامترهای lat و lng را از URL می‌خوانیم
                  final lat = state.uri.queryParameters['lat'];
                  final lng = state.uri.queryParameters['lng'];
                  return MapView(lat: lat, lng: lng);
                },
              ),
            ],
          ),
          // ... بقیه branch ها بدون تغییر
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFavoritesKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesView(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SearchView(),
      ),
    ],
  );
}