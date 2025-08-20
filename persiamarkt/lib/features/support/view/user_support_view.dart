import 'package:flutter/material.dart';
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

  void _submitTicket() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement support ticket submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پیام شما با موفقیت ارسال شد.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
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
