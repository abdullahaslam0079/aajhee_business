import 'package:flutter/material.dart';
import 'package:aajhee_business/src/features/business/data/services/commerce_api_service.dart';
import 'package:aajhee_business/src/services/dio_service.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _basePrice = TextEditingController();
  final _salePrice = TextEditingController();
  final _discountPercent = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  int? _categoryId;
  bool _loading = true;
  bool _saving = false;

  bool get _isEdit => widget.productId != null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final cats = await _api.getCategories();
    cats.fold((_) {}, (items) => _categories = items);
    if (_isEdit) {
      final products = await _api.getProducts();
      products.fold((_) {}, (items) {
        final match = items.cast<Map<String, dynamic>?>().firstWhere(
              (p) => '${p?['id']}' == widget.productId,
              orElse: () => null,
            );
        if (match != null) {
          _name.text = match['name']?.toString() ?? '';
          _description.text = match['description']?.toString() ?? '';
          _basePrice.text = match['base_price']?.toString() ?? '';
          _salePrice.text = match['sale_price']?.toString() ?? '';
          _discountPercent.text = match['discount_percent']?.toString() ?? '';
          _categoryId = match['category_id'] as int?;
        }
      });
    } else if (_categories.isNotEmpty) {
      _categoryId = _categories.first['id'] as int?;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (_categoryId == null || _name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and category are required')),
      );
      return;
    }
    final base = double.tryParse(_basePrice.text.trim());
    if (base == null || base <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid base price')),
      );
      return;
    }
    setState(() => _saving = true);
    final payload = <String, dynamic>{
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'base_price': base,
      'category_id': _categoryId,
      if (_salePrice.text.trim().isNotEmpty)
        'sale_price': double.tryParse(_salePrice.text.trim()),
      if (_discountPercent.text.trim().isNotEmpty)
        'discount_percent': double.tryParse(_discountPercent.text.trim()),
    };
    final result = _isEdit
        ? await _api.updateProduct(int.parse(widget.productId!), payload)
        : await _api.createProduct(payload);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => Navigator.pop(context),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _basePrice.dispose();
    _salePrice.dispose();
    _discountPercent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit product' : 'New product'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete product?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await _api.deleteProduct(int.parse(widget.productId!));
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _categoryId,
                  items: _categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c['id'] as int,
                          child: Text(c['name']?.toString() ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _basePrice,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Base price'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _discountPercent,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount % (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _salePrice,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sale price (optional)',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Save changes' : 'Create product'),
                ),
              ],
            ),
    );
  }
}
