import 'package:equatable/equatable.dart';

// An abstract class for all authentication states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state, user is not authenticated
class AuthInitial extends AuthState {}

// State when an auth process (login/register) is in progress
class AuthLoading extends AuthState {}

// State when the user is successfully authenticated
class Authenticated extends AuthState {
  // You can add user data here later, e.g., final User user;
  const Authenticated();
}

// State when the user is not authenticated (e.g., after logout or failed login)
class Unauthenticated extends AuthState {}

// State when an error occurs during the auth process
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
