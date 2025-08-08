// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persia_markt/core/config/app_router.dart';
import 'package:persia_markt/core/config/service_locator.dart';
import 'package:persia_markt/features/search/presentation/cubit/search_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/market_data_cubit.dart';
import 'package:persia_markt/features/home/presentation/cubit/location_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';

void main() async {
  // اطمینان از راه‌اندازی کامل Flutter قبل از اجرای برنامه
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی سرویس‌ها و Cubit‌ها با GetIt
  await setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استفاده از MultiBlocProvider برای فراهم کردن تمام Cubit‌ها برای کل برنامه
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MarketDataCubit>()..fetchMarketData(),
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
        
        // استفاده از GoRouter برای مسیریابی
        routerConfig: AppRouter.router,
        
        // تنظیمات زبان و منطقه
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
        
        // تم روشن برنامه
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.orange,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
            accentColor: Colors.orangeAccent,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          brightness: Brightness.light,
        ),
        
        // تم تاریک برنامه
        darkTheme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.orange,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.orange,
            accentColor: Colors.orangeAccent,
            brightness: Brightness.dark,
          ).copyWith(
            surface: Colors.grey.shade800,
            onSurface: Colors.white,
            background: Colors.grey.shade900,
            onBackground: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.grey.shade900,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
          ),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system, // انتخاب تم بر اساس تنظیمات سیستم
      ),
    );
  }
}