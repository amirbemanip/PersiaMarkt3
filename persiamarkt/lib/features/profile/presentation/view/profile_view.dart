import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/features/auth/presentation/cubit/auth_state.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل من'),
        actions: [
          // Show logout button only when authenticated
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'خروج از حساب کاربری',
                  onPressed: () {
                    // Show a confirmation dialog before logging out
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('خروج از حساب'),
                        content: const Text('آیا برای خروج مطمئن هستید؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('انصراف'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<AuthCubit>().logoutUser();
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('خروج'),
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
            // If authenticated, show user info. We need to decode the token.
            return _buildProfileInfo(context);
          }
          // If not authenticated, this view shouldn't be reachable due to router redirect.
          // But as a fallback, show a message.
          return const Center(
            child: Text('برای مشاهده پروفایل لطفاً وارد شوید.'),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context) {
    // FIXED: Access the now-public 'authService' by removing the underscore
    final token = context.read<AuthCubit>().authService.getToken();
    Map<String, dynamic> userInfo = {};
    if (token != null) {
      try {
        userInfo = JwtDecoder.decode(token);
      } catch (e) {
        // Using a logger or print for debugging is fine here.
        // In a real app, you might use a formal logging package.
        debugPrint("Error decoding token: $e");
        // Handle error, maybe logout user
        context.read<AuthCubit>().logoutUser();
      }
    }

    final String name = userInfo['name'] ?? 'کاربر مهمان';
    final String email = userInfo['email'] ?? 'ایمیل نامشخص';

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
        // You can add more profile options here
        ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: const Text('تنظیمات حساب'),
          onTap: () {
            // Navigate to account settings page
          },
        ),
        ListTile(
          leading: const Icon(Icons.history_outlined),
          title: const Text('تاریخچه سفارشات'),
          onTap: () {
            // Navigate to order history page
          },
        ),
      ],
    );
  }
}
