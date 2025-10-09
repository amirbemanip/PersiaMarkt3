import 'package:equatable/equatable.dart';

/// A base class for all failures in the application.
/// A Failure represents an error that is intended to be shown to the user.
abstract class Failure extends Equatable {
  /// A user-friendly message describing the failure.
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Represents a failure that occurs when communicating with the server.
/// This could be due to a 4xx or 5xx response.
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Represents a failure due to network connectivity issues (e.g., no internet).
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super(message: 'No internet connection. Please check your network and try again.');
}

/// Represents a failure when a request to the server times out.
class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super(message: 'The connection to the server timed out. Please try again later.');
}

/// Represents a failure related to local cache operations.
class CacheFailure extends Failure {
  const CacheFailure()
      : super(message: 'A local data storage error occurred.');
}

/// Represents an unexpected or unknown failure.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure()
      : super(message: 'An unexpected error occurred. Please try again.');
}