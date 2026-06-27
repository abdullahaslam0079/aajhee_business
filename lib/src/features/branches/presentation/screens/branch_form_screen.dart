import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

class BranchFormScreen extends ConsumerStatefulWidget {
  const BranchFormScreen({super.key, this.branchId});

  final String? branchId;

  bool get isEditing => branchId != null;

  @override
  ConsumerState<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends ConsumerState<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController(text: '52.520008');
  final _longitudeController = TextEditingController(text: '13.404954');

  Branch? _existingBranch;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadBranch();
    }
  }

  Future<void> _loadBranch() async {
    setState(() => _isLoading = true);
    final result = await ref
        .read(businessRepositoryProvider)
        .getBranch(widget.branchId!);
    result.fold(
      (_) {},
      (branch) {
        _existingBranch = branch;
        _nameController.text = branch.name;
        _streetController.text = branch.street;
        _houseNumberController.text = branch.houseNumber;
        _postalCodeController.text = branch.postalCode;
        _cityController.text = branch.city;
        _latitudeController.text = branch.latitude.toStringAsFixed(6);
        _longitudeController.text = branch.longitude.toStringAsFixed(6);
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final notifier = ref.read(branchesListProvider.notifier);
    final latitude = double.parse(_latitudeController.text.trim());
    final longitude = double.parse(_longitudeController.text.trim());

    final success = widget.isEditing
        ? await notifier.updateBranch(
            _existingBranch!.copyWith(
              name: _nameController.text.trim(),
              street: _streetController.text.trim(),
              houseNumber: _houseNumberController.text.trim(),
              postalCode: _postalCodeController.text.trim(),
              city: _cityController.text.trim(),
              latitude: latitude,
              longitude: longitude,
            ),
          )
        : await notifier.createBranch(
            name: _nameController.text.trim(),
            street: _streetController.text.trim(),
            houseNumber: _houseNumberController.text.trim(),
            postalCode: _postalCodeController.text.trim(),
            city: _cityController.text.trim(),
            latitude: latitude,
            longitude: longitude,
          );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showToast(context, message: 'branches.saved'.tr(), status: 'success');
      context.pop();
    } else {
      showToast(context, message: 'branches.save_error'.tr(), status: 'error');
    }
  }

  Future<void> _delete() async {
    if (!widget.isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('branches.delete_title'.tr()),
        content: Text('branches.delete_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    final success = await ref
        .read(branchesListProvider.notifier)
        .deleteBranch(widget.branchId!);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showToast(context, message: 'branches.deleted'.tr(), status: 'success');
      context.pop();
    } else {
      showToast(context, message: 'branches.delete_error'.tr(), status: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('branches.edit'.tr()),
        ),
        body: const Center(child: AppLoading()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'branches.edit'.tr() : 'branches.add'.tr(),
        ),
        actions: [
          if (widget.isEditing)
            IconButton(
              onPressed: _isSaving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'common.delete'.tr(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'branches.name'.tr(),
                hint: 'branches.name_hint'.tr(),
                controller: _nameController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'branches.name_required'.tr() : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.street'.tr(),
                hint: 'branches.street_hint'.tr(),
                controller: _streetController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'branches.street_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.house_number'.tr(),
                controller: _houseNumberController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'branches.house_number_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.postal_code'.tr(),
                controller: _postalCodeController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'branches.postal_code_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.city'.tr(),
                hint: 'branches.city_hint'.tr(),
                controller: _cityController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'branches.city_required'.tr() : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.latitude'.tr(),
                controller: _latitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null || value < -90 || value > 90) {
                    return 'branches.latitude_invalid'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'branches.longitude'.tr(),
                controller: _longitudeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null || value < -180 || value > 180) {
                    return 'branches.longitude_invalid'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.xxxl.h),
              AppButton(
                label: widget.isEditing ? 'common.save'.tr() : 'branches.create'.tr(),
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
