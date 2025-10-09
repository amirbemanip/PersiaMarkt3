// lib/core/config/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/cubit/locale_cubit.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/core/services/location_service.dart';
import 'package:persia_markt/features/auth/data/services/auth_service.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/checkout/data/services/checkout_service.dart';
import 'package:persia_markt/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:persia_markt/features/home/data/repositories/market_repository_impl.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/order_history/data/services/order_history_service.dart';
import 'package:persia_markt/features/order_history/presentation/cubit/order_history_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // Core Cubits
  sl.registerLazySingleton(() => LocaleCubit());

  // Services
  sl.registerLazySingleton(() => ApiService(client: sl()));
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => AuthService(client: sl(), prefs: sl()));
  sl.registerLazySingleton(() => CheckoutService(client: sl(), authService: sl()));
  sl.registerLazySingleton(() => OrderHistoryService(client: sl(), authService: sl()));

  // Repositories
  sl.registerLazySingleton<MarketRepository>(
      () => MarketRepositoryImpl(apiService: sl()));

  // Feature Cubits & Blocs
  sl.registerFactory(() => MarketDataBloc(marketRepository: sl()));
  sl.registerFactory(() => LocationCubit(locationService: sl()));
  // Cubits should be singletons to maintain state across the app.
  sl.registerLazySingleton(() => CartCubit(sharedPreferences: sl()));
  sl.registerLazySingleton(() => FavoritesCubit(sharedPreferences: sl()));
  sl.registerLazySingleton(() => OrderHistoryCubit(orderHistoryService: sl()));

  // AuthCubit now depends on other cubits to reset them on logout.
  sl.registerLazySingleton(() => AuthCubit(
        authService: sl(),
        cartCubit: sl(),
        favoritesCubit: sl(),
        orderHistoryCubit: sl(),
      ));

  sl.registerFactory(() => SearchCubit());
  sl.registerFactory(() =>
      CheckoutCubit(checkoutService: sl(), cartCubit: sl(), orderHistoryCubit: sl()));
}