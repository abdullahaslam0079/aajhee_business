import 'package:flutter/material.dart';
import 'package:aajhee_business/src/features/business/data/services/commerce_api_service.dart';
import 'package:aajhee_business/src/routing/app_routes.dart';
import 'package:aajhee_business/src/services/dio_service.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = CommerceApiService(DioService.instance);
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final result = await _api.getOrders();
    return result.fold((f) => throw Exception(f.message), (items) => items);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('${snapshot.error}'),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No orders yet.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final o = items[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  title: Text('${o['branch_name']} · Rs ${o['total']}'),
                  subtitle: Text(
                    '${o['status']} · ${o['fulfillment_type']} · ${o['payment_method']}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push(
                      AppRoutes.orderDetail(o['public_id'].toString()),
                    );
                    _refresh();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.publicId});

  final String publicId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _api = CommerceApiService(DioService.instance);
  Map<String, dynamic>? _order;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _api.getOrders();
    result.fold((_) {}, (items) {
      _order = items.cast<Map<String, dynamic>?>().firstWhere(
            (o) => o?['public_id']?.toString() == widget.publicId,
            orElse: () => null,
          );
    });
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setStatus(String status) async {
    final result = await _api.updateOrderStatus(widget.publicId, status);
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (order) => setState(() => _order = order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: AppBar(title: const Text('Order detail')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Order not found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Status: ${order['status']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Total: Rs ${order['total']}'),
                    Text('Fulfillment: ${order['fulfillment_type']}'),
                    Text('Payment: ${order['payment_method']}'),
                    if ((order['bank_transfer_instructions'] ?? '')
                        .toString()
                        .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Bank instructions:\n${order['bank_transfer_instructions']}',
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...((order['items'] as List?) ?? []).map((item) {
                      final i = item as Map;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('${i['product_name']}'),
                        subtitle: Text('x${i['quantity']} · Rs ${i['line_total']}'),
                      );
                    }),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (order['status'] == 'pending')
                          FilledButton(
                            onPressed: () => _setStatus('accepted'),
                            child: const Text('Accept'),
                          ),
                        if (order['status'] == 'accepted' ||
                            order['status'] == 'paid_confirmed')
                          FilledButton(
                            onPressed: () => _setStatus('preparing'),
                            child: const Text('Preparing'),
                          ),
                        if (order['status'] == 'preparing' &&
                            order['fulfillment_type'] == 'pickup')
                          FilledButton(
                            onPressed: () => _setStatus('ready_for_pickup'),
                            child: const Text('Ready for pickup'),
                          ),
                        if (order['status'] == 'preparing' &&
                            order['fulfillment_type'] != 'pickup')
                          FilledButton(
                            onPressed: () => _setStatus('out_for_delivery'),
                            child: const Text('Out for delivery'),
                          ),
                        if (order['status'] == 'ready_for_pickup' ||
                            order['status'] == 'out_for_delivery')
                          FilledButton(
                            onPressed: () => _setStatus('completed'),
                            child: const Text('Complete'),
                          ),
                        OutlinedButton(
                          onPressed: () => _setStatus('cancelled'),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...((order['payment_proofs'] as List?) ?? []).map((proof) {
                      final p = proof as Map;
                      return Card(
                        child: ListTile(
                          title: Text('Proof · ${p['review_status']}'),
                          subtitle: Text(p['note']?.toString() ?? ''),
                          trailing: p['review_status'] == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () async {
                                        final r = await _api.reviewPaymentProof(
                                          widget.publicId,
                                          p['id'] as int,
                                          reviewStatus: 'accepted',
                                        );
                                        r.fold((_) {}, (_) => _load());
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        final r = await _api.reviewPaymentProof(
                                          widget.publicId,
                                          p['id'] as int,
                                          reviewStatus: 'rejected',
                                        );
                                        r.fold((_) {}, (_) => _load());
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
