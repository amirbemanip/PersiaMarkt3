// lib/features/home/presentation/bloc/market_data_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';
import 'market_data_event.dart';
import 'market_data_state.dart';

class MarketDataBloc extends Bloc<MarketDataEvent, MarketDataState> {
  final MarketRepository _marketRepository;

  MarketDataBloc({required MarketRepository marketRepository})
      : _marketRepository = marketRepository,
        super(MarketDataInitial()) {
    // Register the event handler
    on<FetchMarketDataEvent>(_onFetchMarketData);
  }

  /// Handles the FetchMarketDataEvent.
  Future<void> _onFetchMarketData(
    FetchMarketDataEvent event,
    Emitter<MarketDataState> emit,
  ) async {
    emit(MarketDataLoading());
    final failureOrMarketData = await _marketRepository.getMarketData();
    
    // Use .fold for elegant handling of the Either<Failure, Success> type.
    // The first function handles the Left (Failure) case, the second handles the Right (Success) case.
    failureOrMarketData.fold(
      (failure) => emit(MarketDataError(message: failure.message)),
      (marketData) => emit(MarketDataLoaded(marketData: marketData)),
    );
  }
}