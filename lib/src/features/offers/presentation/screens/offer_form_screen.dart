import 'package:aajhee_business/src/features/business/domain/entities/branch.dart';
import 'package:aajhee_business/src/features/business/domain/entities/offer.dart';
import 'package:aajhee_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:aajhee_business/src/features/business/domain/enums/offer_type.dart';
import 'package:aajhee_business/src/features/business/domain/enums/usage_limit_type.dart';
import 'package:aajhee_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

class OfferFormScreen extends ConsumerStatefulWidget {
  const OfferFormScreen({super.key, this.offerId});

  final String? offerId;

  bool get isEditing => offerId != null;

  @override
  ConsumerState<OfferFormScreen> createState() => _OfferFormScreenState();
}

class _OfferFormScreenState extends ConsumerState<OfferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController(text: '10');
  final _itemNameController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _usageCountController = TextEditingController(text: '3');
  final List<TextEditingController> _includedItemControllers = [];

  Offer? _existingOffer;
  List<Branch> _branches = [];
  bool _isLoading = true;
  bool _isSaving = false;

  OfferType _type = OfferType.percentageBill;
  OfferBranchScope _branchScope = OfferBranchScope.selectedBranches;
  UsageLimitType _usageLimit = UsageLimitType.oneTime;
  bool _isEnabled = true;
  final Set<String> _selectedBranchIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(businessRepositoryProvider);
    final branchesResult = await repo.getBranches();
    _branches = branchesResult.getOrElse((_) => []);

    if (widget.isEditing) {
      final offerResult = await repo.getOffer(widget.offerId!);
      offerResult.fold(
        (_) {},
        (offer) {
          _existingOffer = offer;
          _titleController.text = offer.title;
          _descriptionController.text = offer.description ?? '';
          _discountController.text = offer.discountPercent.toStringAsFixed(0);
          _itemNameController.text = offer.itemName ?? '';
          _originalPriceController.text =
              offer.originalPrice?.toStringAsFixed(2) ?? '';
          _discountedPriceController.text =
              offer.discountedPrice?.toStringAsFixed(2) ?? '';
          _usageCountController.text = '${offer.usageLimitCount}';
          _replaceIncludedItemControllers(offer.includedItems);
          _type = offer.type;
          _branchScope = offer.branchScope;
          _usageLimit = offer.usageLimitType;
          _isEnabled = offer.isEnabled;
          _selectedBranchIds
            ..clear()
            ..addAll(offer.branchIds);
        },
      );
    } else if (_branches.isNotEmpty) {
      _selectedBranchIds.addAll(_branches.map((branch) => branch.id));
      _branchScope = OfferBranchScope.allBranches;
    }

    if (!widget.isEditing) {
      _ensureIncludedItemControllers();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _ensureIncludedItemControllers() {
    if (_includedItemControllers.isNotEmpty) return;
    _includedItemControllers.addAll([
      TextEditingController(),
      TextEditingController(),
    ]);
  }

  void _replaceIncludedItemControllers(List<String> items) {
    for (final controller in _includedItemControllers) {
      controller.dispose();
    }
    _includedItemControllers
      ..clear()
      ..addAll(
        (items.isEmpty ? const ['', ''] : items)
            .map((item) => TextEditingController(text: item)),
      );
    if (_includedItemControllers.length < 2) {
      _includedItemControllers.add(TextEditingController());
    }
  }

  void _addIncludedItem() {
    setState(() => _includedItemControllers.add(TextEditingController()));
  }

  void _removeIncludedItem(int index) {
    if (_includedItemControllers.length <= 2) return;
    setState(() {
      _includedItemControllers.removeAt(index).dispose();
    });
  }

  List<String> get _includedItems {
    return _includedItemControllers
        .map((controller) => controller.text.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  void _onOfferTypeChanged(OfferType type) {
    setState(() {
      _type = type;
      if (type == OfferType.deal) {
        _ensureIncludedItemControllers();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _itemNameController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _usageCountController.dispose();
    for (final controller in _includedItemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Offer _buildOfferDraft() {
    final billDiscount = double.tryParse(_discountController.text.trim()) ?? 0;
    final usageCount = int.tryParse(_usageCountController.text.trim()) ?? 1;

    return Offer(
      id: _existingOffer?.id ?? '',
      businessId: _existingOffer?.businessId ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _type,
      branchScope: _branchScope,
      branchIds: _branchScope == OfferBranchScope.selectedBranches
          ? _selectedBranchIds.toList()
          : const [],
      discountPercent:
          _type == OfferType.percentageBill ? billDiscount : 0,
      usageLimitType: _usageLimit,
      usageLimitCount: _usageLimit.requiresCount ? usageCount : 1,
      itemName: _type == OfferType.item
          ? _itemNameController.text.trim()
          : null,
      includedItems: _type == OfferType.deal ? _includedItems : const [],
      originalPrice: _type.usesCompareAtPrice
          ? double.tryParse(_originalPriceController.text.trim())
          : null,
      discountedPrice: _type.usesDealPrice
          ? double.tryParse(_discountedPriceController.text.trim())
          : null,
      isEnabled: _isEnabled,
      qrCode: _existingOffer?.qrCode ?? '',
      createdAt: _existingOffer?.createdAt ?? DateTime.now(),
      branchStats: _existingOffer?.branchStats ?? const [],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_branchScope == OfferBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      showToast(
        context,
        message: 'offers.branch_required'.tr(),
        status: 'error',
      );
      return;
    }

    if (_type == OfferType.deal && _includedItems.length < 2) {
      showToast(
        context,
        message: 'offers.included_items_min'.tr(),
        status: 'error',
      );
      return;
    }

    setState(() => _isSaving = true);
    final draft = _buildOfferDraft();
    final notifier = ref.read(offersListProvider.notifier);
    if (widget.isEditing) {
      final success = await notifier.updateOffer(draft);
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (success) {
        showToast(context, message: 'offers.saved'.tr(), status: 'success');
        context.pop();
      } else {
        showToast(context, message: 'offers.save_error'.tr(), status: 'error');
      }
      return;
    }

    final created = await notifier.createOffer(draft);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (created != null) {
      showToast(context, message: 'offers.saved'.tr(), status: 'success');
      context.pop();
      context.push(AppRoutes.offerDetail(created.id));
    } else {
      showToast(context, message: 'offers.save_error'.tr(), status: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('offers.edit'.tr())),
        body: const Center(child: AppLoading()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'offers.edit'.tr() : 'offers.add'.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'offers.field_title'.tr(),
                controller: _titleController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'offers.title_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'offers.field_description'.tr(),
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.lg.h),
              Text('offers.field_type'.tr(), style: tt.titleSmall),
              SizedBox(height: AppSpacing.sm.h),
              SegmentedButton<OfferType>(
                showSelectedIcon: false,
                segments: OfferType.values
                    .map(
                      (t) => ButtonSegment(
                        value: t,
                        label: Text(t.labelKey.tr()),
                      ),
                    )
                    .toList(),
                selected: {_type},
                onSelectionChanged: (v) => _onOfferTypeChanged(v.first),
              ),
              SizedBox(height: AppSpacing.lg.h),
              if (_type == OfferType.item) ...[
                AppTextField(
                  label: 'offers.field_item_name'.tr(),
                  controller: _itemNameController,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'offers.item_name_required'.tr()
                      : null,
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppTextField(
                  label: 'offers.field_original_price'.tr(),
                  controller: _originalPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final value = double.tryParse(v ?? '');
                    if (value == null || value <= 0) {
                      return 'offers.price_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
                AppTextField(
                  label: 'offers.field_discounted_price'.tr(),
                  controller: _discountedPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final discounted = double.tryParse(v ?? '');
                    final original =
                        double.tryParse(_originalPriceController.text.trim());
                    if (discounted == null || discounted < 0) {
                      return 'offers.price_invalid'.tr();
                    }
                    if (original != null && discounted >= original) {
                      return 'offers.discounted_price_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
              if (_type == OfferType.deal) ...[
                Text('offers.included_items'.tr(), style: tt.titleSmall),
                SizedBox(height: AppSpacing.sm.h),
                ..._includedItemControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'offers.included_item_label'.tr(
                              namedArgs: {'n': '${index + 1}'},
                            ),
                            controller: entry.value,
                            validator: (value) {
                              if (_includedItems.length >= 2) return null;
                              if ((value ?? '').trim().isNotEmpty) return null;
                              return 'offers.included_item_required'.tr();
                            },
                          ),
                        ),
                        if (_includedItemControllers.length > 2)
                          IconButton(
                            onPressed: () => _removeIncludedItem(index),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addIncludedItem,
                    icon: const Icon(Icons.add),
                    label: Text('offers.add_included_item'.tr()),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                AppTextField(
                  label: 'offers.field_deal_price'.tr(),
                  controller: _discountedPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final discounted = double.tryParse(v ?? '');
                    if (discounted == null || discounted <= 0) {
                      return 'offers.price_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
              if (_type == OfferType.percentageBill) ...[
                AppTextField(
                  label: 'offers.field_discount'.tr(),
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  suffixIcon: Text('%', style: tt.bodyLarge),
                  validator: (v) {
                    final value = double.tryParse(v ?? '');
                    if (value == null || value <= 0 || value > 100) {
                      return 'offers.discount_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
              Text('offers.field_visible_branches'.tr(), style: tt.titleSmall),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                'offers.field_visible_branches_hint'.tr(),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: AppSpacing.sm.h),
              SegmentedButton<OfferBranchScope>(
                segments: OfferBranchScope.values
                    .map(
                      (s) => ButtonSegment(
                        value: s,
                        label: Text(s.labelKey.tr()),
                      ),
                    )
                    .toList(),
                selected: {_branchScope},
                onSelectionChanged: (v) =>
                    setState(() => _branchScope = v.first),
              ),
              if (_branchScope == OfferBranchScope.selectedBranches) ...[
                SizedBox(height: AppSpacing.md.h),
                if (_branches.isEmpty)
                  Text(
                    'offers.no_branches'.tr(),
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  )
                else
                  Wrap(
                    spacing: AppSpacing.sm.w,
                    runSpacing: AppSpacing.sm.h,
                    children: _branches.map((branch) {
                      final selected = _selectedBranchIds.contains(branch.id);
                      return FilterChip(
                        label: Text(branch.name),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedBranchIds.add(branch.id);
                            } else {
                              _selectedBranchIds.remove(branch.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
              ],
              SizedBox(height: AppSpacing.lg.h),
              Text('offers.field_usage_limit'.tr(), style: tt.titleSmall),
              SizedBox(height: AppSpacing.sm.h),
              ...UsageLimitType.values.map((limit) {
                return RadioListTile<UsageLimitType>(
                  value: limit,
                  groupValue: _usageLimit,
                  title: Text(limit.labelKey.tr()),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _usageLimit = v!),
                );
              }),
              if (_usageLimit.requiresCount) ...[
                AppTextField(
                  label: 'offers.field_usage_count'.tr(),
                  controller: _usageCountController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (!_usageLimit.requiresCount) return null;
                    final count = int.tryParse(v ?? '');
                    if (count == null || count < 1) {
                      return 'offers.custom_usage_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md.h),
              ],
              if (widget.isEditing) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('offers.field_enabled'.tr()),
                  subtitle: Text(
                    'offers.field_enabled_hint'.tr(),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  value: _isEnabled,
                  onChanged: (value) => setState(() => _isEnabled = value),
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
              AppCard(
                color: cs.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: cs.primary, size: 20.sp),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        'offers.qr_info'.tr(),
                        style:
                            tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xxxl.h),
              AppButton(
                label: widget.isEditing
                    ? 'common.save'.tr()
                    : 'offers.create'.tr(),
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
