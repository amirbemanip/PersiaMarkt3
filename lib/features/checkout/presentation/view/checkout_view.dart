// lib/features/checkout/presentation/view/checkout_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/widgets/address_form.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:persia_markt/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = AddressFormController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = {
        'street': _addressController.streetController.text,
        'houseNumber': _addressController.houseNumberController.text,
        'postalCode': _addressController.postalCodeController.text,
        'city': _addressController.cityController.text,
      };
      context.read<CheckoutCubit>().submitOrder(address: address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تکمیل خرید'),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            // پس از موفقیت، سبد خرید را خالی کرده و به صفحه اصلی برمی‌گردیم
            context.read<CartCubit>().loadCartProducts(); // Resets the cart
            context.go('/');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('سفارش شما با موفقیت ثبت شد!')),
            );
          }
          if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CheckoutLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('آدرس تحویل', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  AddressForm(controller: _addressController),
                  const Divider(height: 48),
                  // Here you could add a summary of the order
                  ElevatedButton(
                    onPressed: _submitOrder,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    child: const Text('ثبت نهایی سفارش'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}