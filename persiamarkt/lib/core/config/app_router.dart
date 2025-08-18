// مسیر: lib/core/config/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart'; // <<< مشکل اصلی اینجا بود و برطرف شد
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';
import 'package:persia_markt/features/auth/presentation/view/login_view.dart';
import 'package:persia_markt/features/auth/presentation/view/register_view.dart';
import 'package:persia_markt/features/category/view/category_detail_view.dart';
import 'package:persia_markt/features/home/presentation/view/home_view.dart';
import 'package:persia_markt/features/home/presentation/view/main_tab_bar_view.dart';
import 'package:persia_markt/features/map/view/map_view.dart';
import 'package:persia_markt/features/profile/presentation/view/favorites_view.dart';
import 'package:persia_markt/features/profile/presentation/view/profile_view.dart';
import 'package:persia_markt/features/search/presentation/view/search_view.dart';
import 'package:persia_markt/features/seller_panel/view/seller_panel_view.dart';
import 'package:persia_markt/features/store/presentation/view/store_detail_view.dart';
import 'app_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'shellMap');
final _shellNavigatorFavoritesKey = GlobalKey<NavigatorState>(debugLabel: 'shellFavorites');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.home,
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is Authenticated;
      
      final authRelatedRoutes = [AppRoutes.login, AppRoutes.register, AppRoutes.sellerPanel];
      final onAuthRoutes = authRelatedRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !onAuthRoutes) {
        return AppRoutes.login;
      }
      if (isLoggedIn && onAuthRoutes) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabBarView(navigationShell: navigationShell);
        },
        branches: [
          _buildBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => _buildPageWithTransition(
                  key: state.pageKey,
                  child: const HomeView(),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.storeDetail,
                    pageBuilder: (context, state) {
                      final storeId = state.pathParameters['storeId']!;
                      final initialProductId = state.uri.queryParameters['productId'];
                      return _buildPageWithTransition(
                        key: state.pageKey,
                        child: StoreDetailView(
                          storeId: storeId,
                          initialProductId: initialProductId,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: AppRoutes.categoryDetail,
                    pageBuilder: (context, state) {
                      final categoryId = state.pathParameters['categoryId']!;
                      return _buildPageWithTransition(
                        key: state.pageKey,
                        child: CategoryDetailView(categoryId: categoryId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          _buildBranch(
            navigatorKey: _shellNavigatorMapKey,
            routes: [
              GoRoute(
                path: AppRoutes.map,
                pageBuilder: (context, state) {
                  final lat = state.uri.queryParameters['lat'];
                  final lng = state.uri.queryParameters['lng'];
                  final focus = state.uri.queryParameters['focus'];
                  return _buildPageWithTransition(
                    key: state.pageKey,
                    child: MapView(lat: lat, lng: lng, focus: focus),
                  );
                },
              ),
            ],
          ),
          _buildBranch(
            navigatorKey: _shellNavigatorFavoritesKey,
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                pageBuilder: (context, state) => _buildPageWithTransition(
                  key: state.pageKey,
                  child: const FavoritesView(),
                ),
              ),
            ],
          ),
          _buildBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => _buildPageWithTransition(
                  key: state.pageKey,
                  child: const ProfileView(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SearchView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const RegisterView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerPanel,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: SellerPanelView(),
        ),
      ),
    ],
  );

  static StatefulShellBranch _buildBranch({
    required GlobalKey<NavigatorState> navigatorKey,
    required List<RouteBase> routes,
  }) {
    return StatefulShellBranch(
      navigatorKey: navigatorKey,
      routes: routes,
    );
  }

  static CustomTransitionPage _buildPageWithTransition<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}