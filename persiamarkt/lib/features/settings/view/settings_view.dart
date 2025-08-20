import 'package:flutter/material.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    // TODO: Implement profile update logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('اطلاعات با موفقیت به‌روزرسانی شد.')),
    );
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement password change logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز عبور با موفقیت تغییر کرد.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSettings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بخش اطلاعات کاربری
              Text(
                'اطلاعات کاربری',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'نام و نام خانوادگی',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'نام نمی‌تواند خالی باشد' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: const Text('ذخیره اطلاعات'),
              ),
              const Divider(height: 48),

              // بخش تغییر رمز عبور
              Text(
                'تغییر رمز عبور',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'رمز عبور فعلی',
                  prefixIcon: Icon(Icons.lock_open_outlined),
                ),
                obscureText: true,
                validator: (value) => (value?.isEmpty ?? true)
                    ? 'رمز عبور فعلی را وارد کنید'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'رمز عبور جدید',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) => (value?.length ?? 0) < 8
                    ? 'رمز عبور جدید باید حداقل ۸ کاراکتر باشد'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('تغییر رمز عبور'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
