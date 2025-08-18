import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/core/cubit/locale_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
                              context.read<AuthCubit>().logoutUser();
                              Navigator.of(dialogContext).pop();
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
            child: Text(l10n.loginToSeeProfile),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Map<String, dynamic> userInfo = {};

    // no token in Authenticated -> just leave it empty for now
    const String token = "";

    try {
      userInfo = JwtDecoder.decode(token);
    } catch (_) {}

    final String name = userInfo['name'] ?? l10n.guestUser;
    final String email = userInfo['email'] ?? l10n.unknownEmail;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        CircleAvatar(
          radius: 50,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: Theme.of(context).textTheme.headlineLarge,
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
        ),
        const Divider(height: 40),
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.changeLanguage),
          onTap: () => _showLanguageDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.accountSettings),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: Text(l10n.orderHistory),
          onTap: () {},
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
