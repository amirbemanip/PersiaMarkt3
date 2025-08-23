import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/l10n/app_localizations.dart';
// بهبود: ایمپورت ویجت فرم آدرس که در ادامه ساخته می‌شود
// import 'package:persia_markt/core/widgets/address_form.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_passwordFormKey.currentState?.validate() ?? false) {
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
        // ==================== اصلاح اصلی اینجاست ====================
        // دکمه بازگشت به صورت دستی اضافه شد تا همیشه نمایش داده شود.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // ==========================================================
        title: Text(l10n.accountSettings),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بخش اطلاعات کاربری و آدرس
            Text(
              'اطلاعات کاربری و آدرس',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // ۷. افزودن سیستم آدرس‌دهی
            // در اینجا می‌توانید ویجت فرم آدرس را قرار دهید
            // AddressForm(), // ویجت فرم آدرس در اینجا قرار می‌گیرد
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                // TODO: Implement profile and address update logic
              },
              child: const Text('ذخیره اطلاعات'),
            ),
            const Divider(height: 48),

            // بخش تغییر رمز عبور
            Text(
              'تغییر رمز عبور',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
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
                ],
              ),
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
    );
  }
}
