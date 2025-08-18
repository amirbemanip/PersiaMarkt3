import 'dart:async'; // <-- Import needed for StreamSubscription
import 'package:flutter/material.dart';
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
    // Listen to AuthCubit state changes to automatically redirect users
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = context.read<AuthCubit>().state;
      final isLoggedIn = authState is Authenticated;
      
      final onAuthRoutes = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // If user is not logged in and tries to access a protected route (e.g., /profile)
      if (!isLoggedIn && !onAuthRoutes) {
        // Redirect them to the login page
        return '/login';
      }

      // If user is logged in and tries to access login/register page
      if (isLoggedIn && onAuthRoutes) {
        // Redirect them to the home page
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabBarView(navigationShell: navigationShell);
        },
        branches: [
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
          StatefulShellBranch(
            navigatorKey: _shellNavigatorMapKey,
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) {
                  final lat = state.uri.queryParameters['lat'];
                  final lng = state.uri.queryParameters['lng'];
                  final focus = state.uri.queryParameters['focus'];
                  return MapView(lat: lat, lng: lng, focus: focus);
                },
              ),
            ],
          ),
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
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterView(),
      ),
    ],
  );
}

// Helper class to make GoRouter listen to BLoC/Cubit stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  // FIXED: Changed the type from Stream to StreamSubscription
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
