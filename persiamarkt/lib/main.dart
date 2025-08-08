// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persia_markt/core/config/app_router.dart';
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_event.dart';

void main() async {
  // Ensure Flutter binding is initialized for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup service locator for dependency injection
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider makes Blocs/Cubits available to the entire widget tree
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MarketDataBloc>()..add(FetchMarketDataEvent()),
        ),
        BlocProvider(
          create: (_) => sl<LocationCubit>()..fetchLocation(),
        ),
        BlocProvider(
          create: (_) => sl<FavoritesCubit>()..loadLikedProducts(),
        ),
        BlocProvider(
          create: (_) => sl<SearchCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PersiaMarkt',
        debugShowCheckedModeBanner: false,
        
        // Use GoRouter for advanced and centralized navigation
        routerConfig: AppRouter.router,
        
        // Localization settings for Persian language
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fa', 'IR'),
          Locale('en', ''),
        ],
        locale: const Locale('fa', 'IR'),
        
        // Application Themes
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
      ),
    );
  }

  /// A helper method to build theme data for both light and dark modes
  /// to avoid code duplication.
  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: brightness,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.light ? Colors.grey.shade50 : const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.light ? Colors.white : Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: brightness == Brightness.light ? Colors.black : Colors.white),
        titleTextStyle: GoogleFonts.lalezar(
          color: brightness == Brightness.light ? Colors.black87 : Colors.white, 
          fontSize: 22,
        ),
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(baseTheme.textTheme).apply(
        bodyColor: brightness == Brightness.light ? Colors.black87 : Colors.white,
        displayColor: brightness == Brightness.light ? Colors.black87 : Colors.white,
      ),
    );
  }
}
zz