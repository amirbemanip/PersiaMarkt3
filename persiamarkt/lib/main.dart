import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persia_markt/core/config/app_router.dart';
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_event.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<MarketDataBloc>()..add(FetchMarketDataEvent())),
        BlocProvider(create: (_) => sl<LocationCubit>()..fetchLocation()),
        BlocProvider(create: (_) => sl<FavoritesCubit>()..loadLikedProducts()),
        BlocProvider(create: (_) => sl<SearchCubit>()),
        BlocProvider(create: (_) => sl<AuthCubit>()),
      ],
      child: MaterialApp.router(
        title: 'PersiaMarkt',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
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
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.system,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    // از background مستقیماً استفاده نمی‌کنیم تا اخطار deprecate نگیریم.
    final surfaceColor = isLight ? Colors.white : const Color(0xFF1E1E1E);
    final scaffoldColor = isLight ? const Color(0xFFF5F5F5) : const Color(0xFF121212);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF57C00),
      brightness: brightness,
      primary: const Color(0xFFF57C00),
      secondary: const Color(0xFFFF9800),
      surface: surfaceColor,
      onSurface: isLight ? Colors.black87 : Colors.white,
      outline: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: GoogleFonts.lalezar(
          color: colorScheme.onSurface,
          fontSize: 22,
        ),
      ),
      textTheme: GoogleFonts.vazirmatnTextTheme(baseTheme.textTheme).copyWith(
        headlineMedium:
            GoogleFonts.vazirmatn(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        titleLarge:
            GoogleFonts.vazirmatn(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.vazirmatn(fontSize: 15, color: colorScheme.onSurface),
        labelLarge: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      // ❗️CardThemeData به‌جای CardTheme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(
            // ❗️withValues(alpha: 0.5) به‌جای withOpacity(0.5)
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade500),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
        elevation: 5,
      ),
    );
  }
}
