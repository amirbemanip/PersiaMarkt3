import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/auth/data/services/auth_service.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/order_history/presentation/cubit/order_history_cubit.dart';
import 'package:persia_markt/features/profile/presentation/cubit/favorites_cubit.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService authService;
  final CartCubit cartCubit;
  final FavoritesCubit favoritesCubit;
  final OrderHistoryCubit orderHistoryCubit;

  AuthCubit({
    required this.authService,
    required this.cartCubit,
    required this.favoritesCubit,
    required this.orderHistoryCubit,
  }) : super(AuthUnknown()) {
    checkAuthentication();
  }

  // Checks if a token exists locally to determine initial auth state.
  void checkAuthentication() async {
    // A small delay to ensure the splash screen is visible for a moment.
    await Future.delayed(const Duration(milliseconds: 500));
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
    String? postalCode,
    String? address,
  }) async {
    emit(AuthLoading());
    try {
      await authService.register(
        name: name,
        email: email,
        password: password,
        city: city,
        postalCode: postalCode,
        address: address,
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

    // Reset all user-related data
    cartCubit.reset();
    favoritesCubit.reset();
    orderHistoryCubit.reset();

    emit(Unauthenticated());
  }
}
