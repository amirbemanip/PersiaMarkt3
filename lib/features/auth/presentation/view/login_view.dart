import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/app_routes.dart';
// ==================== کد اصلاح شده اینجاست ====================
import 'package:persia_markt/core/cubit/locale_cubit.dart';
// ==========================================================
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoadingUi = false;
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
      context.read<AuthCubit>().loginUser(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      setState(() => _isLoadingUi = true);
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text(l10n.selectLanguage),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().changeLocale('fa');
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.persian),
            ),
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().changeLocale('en');
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.english),
            ),
            SimpleDialogOption(
              onPressed: () {
                context.read<LocaleCubit>().changeLocale('de');
                Navigator.pop(dialogContext);
              },
              child: Text(l10n.german),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isRtl = l10n.localeName == 'fa';

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.go(AppRoutes.home);
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

            return Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 50),
                          Image.asset('assets/images/appLogo.png', height: 80),
                          const SizedBox(height: 16),
                          Text(
                            l10n.loginToYourAccount,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.gladToSeeYouAgain,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 32),
                          _buildTextFormField(
                            controller: _emailController,
                            labelText: l10n.email,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return l10n.enterYourEmail;
                              if (!value.contains('@') || !value.contains('.')) return l10n.invalidEmail;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                            controller: _passwordController,
                            labelText: l10n.password,
                            icon: Icons.lock_outline,
                            obscureText: _obscureText,
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                              onPressed: _togglePasswordVisibility,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return l10n.enterYourPassword;
                              if (value.length < 6) return l10n.passwordTooShort(6);
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
                                  child: Text(l10n.login),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.register),
                            child: Text(l10n.noAccount),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: isRtl ? null : 16,
                  right: isRtl ? 16 : null,
                  child: TextButton.icon(
                    icon: const Icon(Icons.storefront_outlined, size: 20),
                    label: Text(l10n.sellerLogin),
                    onPressed: () => context.push(AppRoutes.sellerPanel),
                    style: _buttonStyle(theme),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: isRtl ? null : 16,
                  left: isRtl ? 16 : null,
                  child: TextButton.icon(
                    icon: const Icon(Icons.language, size: 20),
                    label: Text(l10n.language),
                    onPressed: () => _showLanguageDialog(context),
                    style: _buttonStyle(theme),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(ThemeData theme) {
    return TextButton.styleFrom(
      foregroundColor: theme.colorScheme.primary,
      // ==================== کد اصلاح شده اینجاست ====================
      backgroundColor: theme.colorScheme.surface.withAlpha((255 * 0.9).round()),
      // ==========================================================
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

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
