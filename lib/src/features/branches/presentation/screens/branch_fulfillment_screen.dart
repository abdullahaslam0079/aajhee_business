import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aajhee_business/src/features/business/data/services/commerce_api_service.dart';
import 'package:aajhee_business/src/services/dio_service.dart';

class BranchFulfillmentScreen extends ConsumerStatefulWidget {
  const BranchFulfillmentScreen({super.key, required this.branchId});

  final String branchId;

  @override
  ConsumerState<BranchFulfillmentScreen> createState() =>
      _BranchFulfillmentScreenState();
}

class _BranchFulfillmentScreenState
    extends ConsumerState<BranchFulfillmentScreen> {
  final _api = CommerceApiService(DioService.instance);
  final _localFee = TextEditingController();
  final _nationwideFee = TextEditingController();
  final _localHours = TextEditingController();
  final _nationwideHours = TextEditingController();
  final _cancelMinutes = TextEditingController();
  final _pickupRadius = TextEditingController();
  final _bankInstructions = TextEditingController();
  final _whatsapp = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  bool _pickup = true;
  bool _local = true;
  bool _nationwide = false;
  bool _bankTransfer = false;
  bool _cashPickup = true;
  bool _cashDelivery = true;
  String _cancelPolicy = 'window_minutes';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.parse(widget.branchId);
    final fulfillment = await _api.getFulfillment(id);
    fulfillment.fold((_) {}, (data) {
      _pickup = data['pickup_enabled'] == true;
      _local = data['local_same_day_enabled'] == true;
      _nationwide = data['nationwide_enabled'] == true;
      _bankTransfer = data['bank_transfer_enabled'] == true;
      _cashPickup = data['cash_on_pickup_enabled'] == true;
      _cashDelivery = data['cash_on_delivery_enabled'] == true;
      _cancelPolicy = data['customer_cancel_policy']?.toString() ?? 'window_minutes';
      _localFee.text = data['local_delivery_fee']?.toString() ?? '0';
      _nationwideFee.text = data['nationwide_delivery_fee']?.toString() ?? '0';
      _localHours.text = data['local_max_delivery_hours']?.toString() ?? '24';
      _nationwideHours.text =
          data['nationwide_max_delivery_hours']?.toString() ?? '72';
      _cancelMinutes.text =
          data['customer_cancel_window_minutes']?.toString() ?? '30';
      _pickupRadius.text = data['pickup_radius_km']?.toString() ?? '15';
      _bankInstructions.text =
          data['bank_transfer_instructions']?.toString() ?? '';
    });
    final contacts = await _api.getContacts(id);
    contacts.fold((_) {}, (items) {
      for (final c in items) {
        switch (c['contact_type']) {
          case 'whatsapp':
            _whatsapp.text = c['value']?.toString() ?? '';
          case 'phone':
            _phone.text = c['value']?.toString() ?? '';
          case 'email':
            _email.text = c['value']?.toString() ?? '';
        }
      }
    });
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final id = int.parse(widget.branchId);
    final contacts = <Map<String, dynamic>>[];
    if (_whatsapp.text.trim().isNotEmpty) {
      contacts.add({
        'contact_type': 'whatsapp',
        'value': _whatsapp.text.trim(),
        'is_primary': true,
      });
    }
    if (_phone.text.trim().isNotEmpty) {
      contacts.add({
        'contact_type': 'phone',
        'value': _phone.text.trim(),
        'is_primary': contacts.isEmpty,
      });
    }
    if (_email.text.trim().isNotEmpty) {
      contacts.add({
        'contact_type': 'email',
        'value': _email.text.trim(),
        'is_primary': contacts.isEmpty,
      });
    }
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one contact (WhatsApp, phone, or email)'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    await _api.saveContacts(id, contacts);
    final result = await _api.updateFulfillment(id, {
      'pickup_enabled': _pickup,
      'local_same_day_enabled': _local,
      'nationwide_enabled': _nationwide,
      'local_delivery_fee': _localFee.text.trim(),
      'nationwide_delivery_fee': _nationwideFee.text.trim(),
      'local_max_delivery_hours': int.tryParse(_localHours.text.trim()) ?? 24,
      'nationwide_max_delivery_hours':
          int.tryParse(_nationwideHours.text.trim()) ?? 72,
      'customer_cancel_policy': _cancelPolicy,
      'customer_cancel_window_minutes':
          int.tryParse(_cancelMinutes.text.trim()) ?? 30,
      'pickup_radius_km': _pickupRadius.text.trim(),
      'bank_transfer_enabled': _bankTransfer,
      'bank_transfer_instructions': _bankInstructions.text.trim(),
      'cash_on_pickup_enabled': _cashPickup,
      'cash_on_delivery_enabled': _cashDelivery,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(f.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      ),
    );
  }

  @override
  void dispose() {
    _localFee.dispose();
    _nationwideFee.dispose();
    _localHours.dispose();
    _nationwideHours.dispose();
    _cancelMinutes.dispose();
    _pickupRadius.dispose();
    _bankInstructions.dispose();
    _whatsapp.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery & contact')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Contact', style: Theme.of(context).textTheme.titleMedium),
                TextField(
                  controller: _whatsapp,
                  decoration: const InputDecoration(labelText: 'WhatsApp'),
                ),
                TextField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fulfillment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SwitchListTile(
                  title: const Text('Pickup'),
                  value: _pickup,
                  onChanged: (v) => setState(() => _pickup = v),
                ),
                SwitchListTile(
                  title: const Text('Local / same-day delivery'),
                  value: _local,
                  onChanged: (v) => setState(() => _local = v),
                ),
                SwitchListTile(
                  title: const Text('Nationwide delivery'),
                  value: _nationwide,
                  onChanged: (v) => setState(() => _nationwide = v),
                ),
                TextField(
                  controller: _pickupRadius,
                  decoration: const InputDecoration(
                    labelText: 'Pickup radius (km)',
                  ),
                ),
                TextField(
                  controller: _localFee,
                  decoration: const InputDecoration(labelText: 'Local fee'),
                ),
                TextField(
                  controller: _localHours,
                  decoration: const InputDecoration(
                    labelText: 'Local max hours',
                  ),
                ),
                TextField(
                  controller: _nationwideFee,
                  decoration: const InputDecoration(labelText: 'Nationwide fee'),
                ),
                TextField(
                  controller: _nationwideHours,
                  decoration: const InputDecoration(
                    labelText: 'Nationwide max hours',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _cancelPolicy,
                  items: const [
                    DropdownMenuItem(
                      value: 'window_minutes',
                      child: Text('Customer cancel within window'),
                    ),
                    DropdownMenuItem(
                      value: 'disabled',
                      child: Text('Only business can cancel'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _cancelPolicy = v ?? 'window_minutes'),
                  decoration: const InputDecoration(labelText: 'Cancel policy'),
                ),
                if (_cancelPolicy == 'window_minutes')
                  TextField(
                    controller: _cancelMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Cancel window (minutes)',
                    ),
                  ),
                SwitchListTile(
                  title: const Text('Cash on pickup'),
                  value: _cashPickup,
                  onChanged: (v) => setState(() => _cashPickup = v),
                ),
                SwitchListTile(
                  title: const Text('Cash on delivery'),
                  value: _cashDelivery,
                  onChanged: (v) => setState(() => _cashDelivery = v),
                ),
                SwitchListTile(
                  title: const Text('Bank transfer + receipt'),
                  value: _bankTransfer,
                  onChanged: (v) => setState(() => _bankTransfer = v),
                ),
                if (_bankTransfer)
                  TextField(
                    controller: _bankInstructions,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bank transfer instructions',
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save settings'),
                ),
              ],
            ),
    );
  }
}
