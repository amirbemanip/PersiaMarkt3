// lib/features/checkout/presentation/view/checkout_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persia_markt/core/config/app_routes.dart';
import 'package:persia_markt/core/widgets/address_form.dart';
import 'package:persia_markt/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:persia_markt/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:persia_markt/features/checkout/presentation/cubit/checkout_state.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_bloc.dart';
import 'package:persia_markt/features/home/presentation/bloc/market_data_state.dart';

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

      final cartState = context.read<CartCubit>().state;
      final marketState = context.read<MarketDataBloc>().state;

      if (marketState is MarketDataLoaded) {
        final productMap = {
          for (var p in marketState.marketData.products) p.id: p
        };

        final itemsToCheckout = cartState.items.entries
            .where((entry) {
              final productId = entry.key;
              final product = productMap[productId];
              return product != null &&
                  cartState.selectedStoreIds.contains(product.storeID);
            })
            .map((entry) => {
                  'storeProductId': int.parse(entry.key),
                  'quantity': entry.value
                })
            .toList();

        if (itemsToCheckout.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'لطفاً حداقل یک فروشگاه را برای نهایی کردن خرید انتخاب کنید.')),
          );
          return;
        }

        context
            .read<CheckoutCubit>()
            .submitOrder(address: address, items: itemsToCheckout);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تکمیل خرید'),
      ),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            // <<< اصلاح اصلی اینجاست
            // 1. ابتدا به صفحه اصلی برمی‌گردیم تا مسیر پاک شود
            context.go(AppRoutes.home);
            // 2. سپس صفحه تاریخچه را روی آن باز می‌کنیم تا دکمه بازگشت داشته باشد
            context.push(AppRoutes.orderHistory);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'سفارش شما با موفقیت ثبت شد! می‌توانید وضعیت آن را اینجا ببینید.')),
            );
          }
          if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
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
      ),
    );
  }
}