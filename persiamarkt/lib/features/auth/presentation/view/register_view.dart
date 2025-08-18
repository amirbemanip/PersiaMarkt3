import 'package:flutter/material.dart'; // <-- FIXED
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().registerUser(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            city: _cityController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is Unauthenticated) {
              // This state is emitted after successful registration
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ثبت‌نام با موفقیت انجام شد! لطفاً وارد شوید.')),
              );
              context.go('/login');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
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
                        'ساخت حساب کاربری',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'به پرشیا مارکت خوش آمدید!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      _buildTextFormField(
                        controller: _nameController,
                        labelText: 'نام و نام خانوادگی',
                        icon: Icons.person_outline,
                        validator: (value) => (value?.isEmpty ?? true) ? 'لطفاً نام خود را وارد کنید' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _emailController,
                        labelText: 'ایمیل',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'لطفاً ایمیل خود را وارد کنید';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) return 'ایمیل معتبر نیست';
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
                          icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: _togglePasswordVisibility,
                        ),
                        validator: (value) => (value?.length ?? 0) < 8 ? 'رمز عبور باید حداقل ۸ کاراکتر باشد' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        controller: _cityController,
                        labelText: 'شهر (اختیاری)',
                        icon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 24),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('ثبت نام'),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('حساب کاربری دارید؟'),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('وارد شوید'),
                          ),
                        ],
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

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
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
