// lib/features/order_history/presentation/view/order_history_view.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:persia_markt/core/models/order.dart';
import 'package:persia_markt/features/order_history/presentation/cubit/order_history_cubit.dart';
import 'package:persia_markt/features/order_history/presentation/cubit/order_history_state.dart';
import 'package:persia_markt/l10n/app_localizations.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  void initState() {
    super.initState();
    // <<< حالا این متد فقط زمانی از سرور دیتا می‌گیرد که لازم باشد
    context.read<OrderHistoryCubit>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderHistory),
      ),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) {
          if (state is OrderHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderHistoryError) {
            return Center(child: Text(state.message));
          }
          if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Text('شما تاکنون سفارشی ثبت نکرده‌اید.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: state.orders[index]);
              },
            );
          }
          // <<< حالت اولیه را هم پوشش می‌دهیم
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  (String, Color) _getStatusInfo(String status, BuildContext context) {
    switch (status) {
      case 'PROCESSING':
        return ('در حال پردازش', Colors.orange.shade700);
      case 'SHIPPED':
        return ('ارسال شده', Colors.blue.shade700);
      case 'DELIVERED':
        return ('تحویل شده', Colors.green.shade700);
      case 'CANCELLED':
        return ('لغو شده', Colors.red.shade700);
      default:
        return (status, Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(order.status, context);
    final formattedDate = DateFormat('yyyy/MM/dd – kk:mm').format(order.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('سفارش #${order.id} - ${order.seller['store_name']}'),
        subtitle: Text(formattedDate),
        trailing: Chip(
          label: Text(statusInfo.$1),
          backgroundColor: statusInfo.$2.withOpacity(0.2),
          labelStyle: TextStyle(color: statusInfo.$2, fontWeight: FontWeight.bold),
        ),
        children: order.items.map((item) {
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.productImageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
            title: Text(item.productName),
            trailing: Text('x ${item.quantity}'),
          );
        }).toList(),
      ),
    );
  }
}