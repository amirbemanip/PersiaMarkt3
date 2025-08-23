// lib/features/profile/presentation/view/profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:persia_markt/core/config/app_routes.dart';
import 'package:persia_markt/core/cubit/locale_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: l10n.logout,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(l10n.logoutFromAccount),
                        content: Text(l10n.logoutConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<AuthCubit>().logoutUser();
                            },
                            child: Text(l10n.logout),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildProfileInfo(context);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.loginToSeeProfile),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(l10n.login),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Map<String, dynamic> userInfo = {};

    final token = context.read<AuthCubit>().authService.getToken();

    if (token != null) {
      try {
        userInfo = JwtDecoder.decode(token);
      } catch (e) {
        print("Error decoding JWT: $e");
      }
    }

    final String name = userInfo['name'] ?? l10n.guestUser;
    final String email = userInfo['email'] ?? l10n.unknownEmail;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            email,
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ),
        const Divider(height: 40),
        ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: Text(l10n.favoritesTitle),
          onTap: () {
            context.push(AppRoutes.favorites);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: Text(l10n.orderHistory),
          onTap: () {
            context.push(AppRoutes.orderHistory);
          },
        ),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.changeLanguage),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.accountSettings),
          onTap: () {
            context.push(AppRoutes.settings);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.support_agent_outlined),
          title: Text(l10n.support),
          onTap: () {
            context.push(AppRoutes.userSupport);
          },
        ),
      ],
    );
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
}