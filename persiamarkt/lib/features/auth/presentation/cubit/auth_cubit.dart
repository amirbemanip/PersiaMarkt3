import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/auth/data/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  // FIXED: Made authService public by removing the underscore.
  final AuthService authService;

  AuthCubit({required this.authService}) : super(AuthInitial()) {
    checkAuthentication();
  }

  // Checks if a token exists locally to determine initial auth state.
  void checkAuthentication() {
    if (authService.isLoggedIn()) {
      emit(const Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    String? city,
  }) async {
    emit(AuthLoading());
    try {
      await authService.register(
        name: name,
        email: email,
        password: password,
        city: city,
      );
      // After successful registration, move to Unauthenticated to prompt login
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await authService.login(email: email, password: password);
      emit(const Authenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logoutUser() async {
    await authService.logout();
    emit(Unauthenticated());
  }
}
