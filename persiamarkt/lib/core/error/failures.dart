// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// A Failure represents an unexpected error (e.g., server error, network error).
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Represents a failure that occurs when communicating with the server.
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Represents a failure related to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}