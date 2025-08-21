import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:persia_markt/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class UserSupportView extends StatefulWidget {
  const UserSupportView({super.key});

  @override
  State<UserSupportView> createState() => _UserSupportViewState();
}

class _UserSupportViewState extends State<UserSupportView> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ==================== اصلاح اصلی اینجاست ====================
  Future<void> _submitTicket() async {
    // ۱. ابتدا فرم را اعتبارسنجی می‌کنیم
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ۲. توکن احراز هویت کاربر را از AuthCubit می‌گیریم
      final authCubit = context.read<AuthCubit>();
      final token = authCubit.authService.getToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      // ۳. درخواست HTTP POST را به اندپوینت صحیح در بک‌اند ارسال می‌کنیم
      final response = await http.post(
        Uri.parse('https://persia-market-panel.onrender.com/support/user/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // توکن را در هدر قرار می‌دهیم
        },
        body: json.encode({
          'subject': _subjectController.text,
          'message': _messageController.text,
        }),
      );

      // ۴. پاسخ سرور را بررسی می‌کنیم
      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پیام شما با موفقیت ارسال شد.')),
        );
        // ۵. از دستور صحیح context.pop() برای بازگشت استفاده می‌کنیم
        if (mounted) context.pop();
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ارسال پیام: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.support),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ارتباط با پشتیبانی',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'مشکل یا پیشنهاد خود را برای ما ارسال کنید. ما در اسرع وقت پاسخ خواهیم داد.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'موضوع',
                  prefixIcon: Icon(Icons.subject_outlined),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'موضوع نمی‌تواند خالی باشد' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'متن پیام',
                  prefixIcon: Icon(Icons.message_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'متن پیام را وارد کنید' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitTicket,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ارسال پیام'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
