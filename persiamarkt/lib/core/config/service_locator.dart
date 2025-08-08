// lib/core/config/service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/core/services/location_service.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';

// نمونه GetIt
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ## External ##
  // ثبت SharedPreferences به صورت singleton و asynchronous
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ## Core ##
  // ثبت سرویس‌های اصلی برنامه
  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => LocationService());

  // ## Cubits ##
  // Cubit‌ها به صورت factory ثبت می‌شوند، یعنی با هر بار درخواست یک نمونه جدید ساخته می‌شود
  sl.registerFactory(() => MarketDataCubit(apiService: sl()));
  sl.registerFactory(() => LocationCubit(locationService: sl()));
  sl.registerFactory(() => FavoritesCubit(sharedPreferences: sl()));
  sl.registerFactory(() => SearchCubit());
}