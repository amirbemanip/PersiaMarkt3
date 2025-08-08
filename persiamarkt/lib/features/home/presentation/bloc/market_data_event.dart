// lib/features/home/presentation/bloc/market_data_event.dart
import 'package:equatable/equatable.dart';

abstract class MarketDataEvent extends Equatable {
  const MarketDataEvent();
  @override
  List<Object> get props => [];
}

/// Event to trigger fetching market data from the repository.
class FetchMarketDataEvent extends MarketDataEvent {}