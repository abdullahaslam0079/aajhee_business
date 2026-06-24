import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

class OfferItemSelector extends StatefulWidget {
  const OfferItemSelector({
    super.key,
    required this.items,
    required this.itemDiscounts,
    required this.onChanged,
    this.onAddItem,
  });

  final List<BusinessItem> items;
  final Map<String, double> itemDiscounts;
  final ValueChanged<Map<String, double>> onChanged;
  final VoidCallback? onAddItem;

  @override
  State<OfferItemSelector> createState() => _OfferItemSelectorState();
}

class _OfferItemSelectorState extends State<OfferItemSelector> {
  final _discountControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _discountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String itemId, double discount) {
    return _discountControllers.putIfAbsent(
      itemId,
      () => TextEditingController(text: discount.toStringAsFixed(0)),
    );
  }

  void _toggleItem(BusinessItem item, bool selected) {
    final updated = Map<String, double>.from(widget.itemDiscounts);
    if (selected) {
      updated[item.id] = updated[item.id] ?? 10;
      _controllerFor(item.id, updated[item.id]!);
    } else {
      updated.remove(item.id);
      _discountControllers[item.id]?.dispose();
      _discountControllers.remove(item.id);
    }
    widget.onChanged(updated);
  }

  void _updateDiscount(String itemId, String value) {
    final discount = double.tryParse(value);
    if (discount == null || discount <= 0 || discount > 100) return;
    final updated = Map<String, double>.from(widget.itemDiscounts);
    updated[itemId] = discount;
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    if (widget.items.isEmpty) {
      return AppCard(
        color: cs.surfaceContainerHighest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'offers.no_items'.tr(),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            if (widget.onAddItem != null) ...[
              SizedBox(height: AppSpacing.md.h),
              AppButton(
                label: 'items.add'.tr(),
                variant: ButtonVariant.secondary,
                onPressed: widget.onAddItem,
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.items.map((item) {
          final selected = widget.itemDiscounts.containsKey(item.id);
          final discount = widget.itemDiscounts[item.id] ?? 10;

          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
            child: AppCard(
              color: selected
                  ? cs.primaryContainer.withValues(alpha: 0.3)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    value: selected,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      item.name,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (item.category != null) item.category!,
                        '€${item.price.toStringAsFixed(2)}',
                      ].join(' · '),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    onChanged: (v) => _toggleItem(item, v ?? false),
                  ),
                  if (selected) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.md.w,
                        right: AppSpacing.md.w,
                        bottom: AppSpacing.sm.h,
                      ),
                      child: AppTextField(
                        label: 'offers.item_discount'.tr(),
                        controller: _controllerFor(item.id, discount),
                        keyboardType: TextInputType.number,
                        suffixIcon: Text('%', style: tt.bodyLarge),
                        onChanged: (v) => _updateDiscount(item.id, v),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        if (widget.onAddItem != null)
          TextButton.icon(
            onPressed: widget.onAddItem,
            icon: const Icon(Icons.add),
            label: Text('items.add_more'.tr()),
          ),
      ],
    );
  }
}
