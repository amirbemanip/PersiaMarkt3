// lib/features/home/presentation/cubit/market_data_state.dart
import 'package:equatable/equatable.dart';
import 'package:persia_markt/core/models/market_data.dart';

// کلاس پایه برای وضعیت‌ها
abstract class MarketDataState extends Equatable {
  const MarketDataState();

  @override
  List<Object> get props => [];
}

// وضعیت اولیه یا در حال بارگذاری
class MarketDataLoading extends MarketDataState {}

// وضعیت موفقیت آمیز بودن دریافت داده‌ها
class MarketDataLoaded extends MarketDataState {
  final MarketData marketData;

  const MarketDataLoaded({required this.marketData});

  @override
  List<Object> get props => [marketData];
}

// وضعیت بروز خطا
class MarketDataError extends MarketDataState {
  final String message;

  const MarketDataError({required this.message});

  @override
  List<Object> get props => [message];
}