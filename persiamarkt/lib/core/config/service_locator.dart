import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/core/services/location_service.dart';
import 'package:persia_markt/features/auth/data/services/auth_service.dart'; // <-- ۱. سرویس جدید اضافه شد
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart'; // <-- ۲. کیوبیت جدید اضافه شد
import 'package:persia_markt/features/home/data/repositories/market_repository_impl.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  // Services
  sl.registerLazySingleton(() => ApiService(client: sl()));
  sl.registerLazySingleton(() => LocationService());
  // ۳. سرویس احراز هویت ثبت شد
  sl.registerLazySingleton(() => AuthService(client: sl(), prefs: sl()));

  // Repositories
  sl.registerLazySingleton<MarketRepository>(() => MarketRepositoryImpl(apiService: sl()));

  // Blocs / Cubits
  sl.registerFactory(() => MarketDataBloc(marketRepository: sl()));
  sl.registerFactory(() => LocationCubit(locationService: sl()));
  sl.registerFactory(() => FavoritesCubit(sharedPreferences: sl()));
  sl.registerFactory(() => SearchCubit());
  // ۴. کیوبیت احراز هویت ثبت شد
  sl.registerFactory(() => AuthCubit(authService: sl()));
}
