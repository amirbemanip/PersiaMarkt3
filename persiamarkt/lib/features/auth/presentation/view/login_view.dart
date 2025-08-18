import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoadingUi = false; // فقط برای transition اولیه، State اصلی از Bloc می‌آید
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      // به‌جای Delay، اکشن لاگینِ AuthCubit را صدا می‌زنیم
      context.read<AuthCubit>().loginUser(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      setState(() => _isLoadingUi = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              // موفقیت → خانه
              context.go('/');
            } else if (state is AuthError) {
              setState(() => _isLoadingUi = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is Unauthenticated || state is AuthInitial) {
              setState(() => _isLoadingUi = false);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading || _isLoadingUi;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/images/appLogo.png', height: 80),
                      const SizedBox(height: 16),
                      Text(
                        'ورود به حساب کاربری',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'خوشحالیم که دوباره شما را می‌بینیم!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),

                      _buildTextFormField(
                        controller: _emailController,
                        labelText: 'ایمیل',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'ایمیل را وارد کنید';
                          }
                          final v = value.trim();
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'ایمیل نامعتبر است';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextFormField(
                        controller: _passwordController,
                        labelText: 'رمز عبور',
                        icon: Icons.lock_outline,
                        obscureText: _obscureText,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رمز عبور را وارد کنید';
                          }
                          if (value.length < 6) {
                            return 'حداقل ۶ کاراکتر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('ورود'),
                            ),
                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('حساب ندارید؟ ثبت‌نام'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // همون متد کمکی قبلی برای TextFormField — بدون حذف هیچ‌چیز
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}
