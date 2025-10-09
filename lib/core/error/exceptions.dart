/// Represents a generic server error.
/// [message] contains the error message from the server response.
/// [statusCode] contains the HTTP status code.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status Code: $statusCode)';
}

/// Represents an error when there is no internet connectivity.
class NetworkException implements Exception {
  final String message = 'No internet connection. Please check your network.';

  @override
  String toString() => message;
}

/// Represents an error when a request to the server times out.
class TimeoutException implements Exception {
  final String message = 'The connection to the server timed out.';

  @override
  String toString() => message;
}


/// Represents an error during data parsing (e.g., malformed JSON).
class ParsingException implements Exception {
  final String message = 'Error parsing data from the server.';

  @override
  String toString() => message;
}

/// Represents an error related to local cache operations.
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'A cache error occurred.'});

   @override
  String toString() => message;
}