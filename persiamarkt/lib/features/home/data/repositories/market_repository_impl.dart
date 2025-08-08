// lib/features/home/data/repositories/market_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import 'package:persia_markt/core/error/failures.dart';
import 'package:persia_markt/core/models/market_data.dart';
import 'package:persia_markt/core/services/api_service.dart';
import 'package:persia_markt/features/home/domain/repositories/market_repository.dart';

/// Implements the MarketRepository to provide market data.
/// It uses a provided ApiService to fetch the data.
class MarketRepositoryImpl implements MarketRepository {
  final ApiService _apiService;
  
  /// The constructor injects the ApiService dependency.
  MarketRepositoryImpl({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<Either<Failure, MarketData>> getMarketData() async {
    try {
      // The updated ApiService now returns a MarketData object directly.
      // We no longer need to call fetchMarketDataAsJson() and then MarketData.fromJson().
      final marketData = await _apiService.fetchMarketData();
      
      // The call was successful, so we wrap the MarketData object in a Right.
      return Right(marketData);
    } on Exception catch (e) {
      // If any exception occurs during the API call or data processing,
      // we catch it and return a ServerFailure wrapped in a Left.
      return Left(ServerFailure(e.toString()));
    }
  }
}
