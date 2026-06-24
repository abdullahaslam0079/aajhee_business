import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_status.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/features/offers/presentation/widgets/offer_item_selector.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

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
  final _customUsageController = TextEditingController(text: '3');

  Offer? _existingOffer;
  List<Branch> _branches = [];
  List<BusinessItem> _items = [];
  bool _isLoading = true;
  bool _isSaving = false;

  OfferType _type = OfferType.billDiscount;
  OfferBranchScope _branchScope = OfferBranchScope.selectedBranches;
  UsageLimitType _usageLimit = UsageLimitType.oneTime;
  OfferStatus _status = OfferStatus.active;
  final Set<String> _selectedBranchIds = {};
  Map<String, double> _itemDiscounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(businessRepositoryProvider);
    final branchesResult = await repo.getBranches();
    final itemsResult = await repo.getItems();
    _branches = branchesResult.getOrElse((_) => []);
    _items = itemsResult.getOrElse((_) => []);

    if (widget.isEditing) {
      final offerResult = await repo.getOffer(widget.offerId!);
      offerResult.fold(
        (_) {},
        (offer) {
          _existingOffer = offer;
          _titleController.text = offer.title;
          _descriptionController.text = offer.description ?? '';
          _discountController.text = offer.discountPercent.toStringAsFixed(0);
          _customUsageController.text = '${offer.customUsageCount ?? 3}';
          _type = offer.type;
          _branchScope = offer.branchScope;
          _usageLimit = offer.usageLimitType;
          _status = offer.status;
          _itemDiscounts = Map<String, double>.from(offer.itemDiscounts);
          _selectedBranchIds
            ..clear()
            ..addAll(offer.branchIds);
        },
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _customUsageController.dispose();
    super.dispose();
  }

  Offer _buildOfferDraft() {
    final billDiscount = double.tryParse(_discountController.text.trim()) ?? 0;
    final customCount = int.tryParse(_customUsageController.text.trim());

    return Offer(
      id: _existingOffer?.id ?? '',
      businessId: _existingOffer?.businessId ?? 'biz_demo_001',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _type,
      status: _status,
      branchScope: _branchScope,
      branchIds: _branchScope == OfferBranchScope.selectedBranches
          ? _selectedBranchIds.toList()
          : const [],
      itemDiscounts: _type == OfferType.productDiscount
          ? Map<String, double>.from(_itemDiscounts)
          : const {},
      discountPercent:
          _type == OfferType.billDiscount ? billDiscount : 0,
      usageLimitType: _usageLimit,
      customUsageCount:
          _usageLimit == UsageLimitType.custom ? customCount : null,
      customUsagePeriod: 'month',
      qrToken: _existingOffer?.qrToken ?? '',
      createdAt: _existingOffer?.createdAt ?? DateTime.now(),
      scanCount: _existingOffer?.scanCount ?? 0,
      redemptionCount: _existingOffer?.redemptionCount ?? 0,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_type == OfferType.productDiscount && _itemDiscounts.isEmpty) {
      showToast(
        context,
        message: 'offers.items_required'.tr(),
        status: 'error',
      );
      return;
    }

    if (_branchScope == OfferBranchScope.selectedBranches &&
        _selectedBranchIds.isEmpty) {
      showToast(
        context,
        message: 'offers.branch_required'.tr(),
        status: 'error',
      );
      return;
    }

    setState(() => _isSaving = true);
    final draft = _buildOfferDraft();
    final notifier = ref.read(offersListProvider.notifier);
    final success = widget.isEditing
        ? await notifier.updateOffer(draft)
        : await notifier.createOffer(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showToast(context, message: 'offers.saved'.tr(), status: 'success');
      context.pop();
    } else {
      showToast(context, message: 'offers.save_error'.tr(), status: 'error');
    }
  }

  Future<void> _openAddItem() async {
    await context.push(AppRoutes.itemCreate);
    if (!mounted) return;
    final itemsResult = await ref.read(businessRepositoryProvider).getItems();
    setState(() {
      _items = itemsResult.getOrElse((_) => []);
    });
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
                segments: OfferType.values
                    .map(
                      (t) => ButtonSegment(
                        value: t,
                        label: Text(t.labelKey.tr()),
                      ),
                    )
                    .toList(),
                selected: {_type},
                onSelectionChanged: (v) => setState(() => _type = v.first),
              ),
              SizedBox(height: AppSpacing.lg.h),
              if (_type == OfferType.productDiscount) ...[
                Text('offers.field_items'.tr(), style: tt.titleSmall),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  'offers.field_items_hint'.tr(),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.md.h),
                OfferItemSelector(
                  items: _items,
                  itemDiscounts: _itemDiscounts,
                  onChanged: (value) => setState(() => _itemDiscounts = value),
                  onAddItem: _openAddItem,
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
              if (_type == OfferType.billDiscount) ...[
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
              if (_usageLimit == UsageLimitType.custom) ...[
                AppTextField(
                  label: 'offers.field_custom_usage'.tr(),
                  controller: _customUsageController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (_usageLimit != UsageLimitType.custom) return null;
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
                Text('offers.field_status'.tr(), style: tt.titleSmall),
                SizedBox(height: AppSpacing.sm.h),
                DropdownButtonFormField<OfferStatus>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: AppBorders.sm),
                  ),
                  items: OfferStatus.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.labelKey.tr()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
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
