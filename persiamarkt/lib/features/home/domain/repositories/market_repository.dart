// lib/features/home/domain/repositories/market_repository.dart
import 'package:fpdart/fpdart.dart';
import 'package:persia_markt/core/error/failures.dart';
import 'package:persia_markt/core/models/market_data.dart';

/// Abstract contract for the market data repository.
/// This allows the business logic layer (BLoC) to depend on an abstraction,
/// not a concrete implementation, which is crucial for testing and modularity.
///
/// It defines what the repository *must do*, but not *how* it does it.
abstract class MarketRepository {
  /// Fetches the market data.
  /// Returns [Either] a [Failure] on error or [MarketData] on success.
  /// The Either type from fpdart provides excellent, explicit error handling.
  Future<Either<Failure, MarketData>> getMarketData();
}