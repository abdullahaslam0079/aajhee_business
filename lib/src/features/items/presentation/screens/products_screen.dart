import 'package:flutter/material.dart';
import 'package:aajhee_business/src/features/business/data/services/commerce_api_service.dart';
import 'package:aajhee_business/src/routing/app_routes.dart';
import 'package:aajhee_business/src/services/dio_service.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _api = CommerceApiService(DioService.instance);
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final result = await _api.getProducts();
    return result.fold((f) => throw Exception(f.message), (items) => items);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _bulkDiscount() async {
    final controller = TextEditingController(text: '10');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply discount to all'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Discount %',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final percent = double.tryParse(controller.text.trim());
    if (percent == null) return;
    final result = await _api.bulkDiscount(
      discountPercent: percent,
      allProducts: true,
    );
    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${data['updated']} products')),
        );
        _refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            tooltip: 'Bulk discount',
            onPressed: _bulkDiscount,
            icon: const Icon(Icons.percent),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.productCreate);
          _refresh();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                    child: Text('Failed to load: ${snapshot.error}'),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No products yet. Add your first item.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = items[index];
                final hasDiscount = p['has_discount'] == true;
                final price = p['effective_price']?.toString() ?? p['base_price'];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                    ),
                  ),
                  title: Text(p['name']?.toString() ?? 'Product'),
                  subtitle: Text(
                    hasDiscount
                        ? 'Rs $price · ${p['effective_discount_percent']}% off'
                        : 'Rs $price · ${p['category_name'] ?? ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push(AppRoutes.productEdit('${p['id']}'));
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
