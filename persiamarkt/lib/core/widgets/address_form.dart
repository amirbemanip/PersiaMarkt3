import 'package:flutter/material.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

// این کنترلرها برای مدیریت مقادیر فرم آدرس استفاده می‌شوند
class AddressFormController {
  final TextEditingController streetController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  void dispose() {
    streetController.dispose();
    houseNumberController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
  }
}

class AddressForm extends StatelessWidget {
  final AddressFormController controller;

  const AddressForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // دکمه برای انتخاب آدرس از روی نقشه
        OutlinedButton.icon(
          icon: const Icon(Icons.map_outlined),
          label: const Text('انتخاب آدرس از روی نقشه'),
          onPressed: () {
            // TODO: Implement map address picker
            // در اینجا باید یک صفحه نقشه باز شود که کاربر بتواند پین را حرکت دهد
            // و پس از تایید، فیلدهای زیر به صورت خودکار پر شوند.
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // فیلد خیابان
        TextFormField(
          controller: controller.streetController,
          decoration: const InputDecoration(
            labelText: 'خیابان',
            prefixIcon: Icon(Icons.signpost_outlined),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'نام خیابان را وارد کنید' : null,
        ),
        const SizedBox(height: 16),
        // فیلدهای شماره خانه و کد پستی در یک ردیف
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.houseNumberController,
                decoration: const InputDecoration(
                  labelText: 'شماره خانه',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'شماره را وارد کنید' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: controller.postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'کد پستی',
                  prefixIcon: Icon(Icons.local_post_office_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    (value?.isEmpty ?? true) ? 'کد پستی را وارد کنید' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // فیلد شهر
        TextFormField(
          controller: controller.cityController,
          decoration: const InputDecoration(
            labelText: 'شهر',
            prefixIcon: Icon(Icons.location_city_outlined),
          ),
          validator: (value) =>
              (value?.isEmpty ?? true) ? 'نام شهر را وارد کنید' : null,
        ),
      ],
    );
  }
}
