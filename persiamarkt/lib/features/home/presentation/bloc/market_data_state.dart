// lib/features/home/presentation/bloc/market_data_state.dart
import 'package:equatable/equatable.dart';
import 'package:persia_markt/core/models/market_data.dart';

abstract class MarketDataState extends Equatable {
  const MarketDataState();
  @override
  List<Object> get props => [];
}

class MarketDataInitial extends MarketDataState {}

class MarketDataLoading extends MarketDataState {}

class MarketDataLoaded extends MarketDataState {
  final MarketData marketData;
  const MarketDataLoaded({required this.marketData});
  @override
  List<Object> get props => [marketData];
}

class MarketDataError extends MarketDataState {
  final String message;
  const MarketDataError({required this.message});
  @override
  List<Object> get props => [message];
}