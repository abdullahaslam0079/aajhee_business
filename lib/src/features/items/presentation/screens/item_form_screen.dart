import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.itemId});

  final String? itemId;

  bool get isEditing => itemId != null;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  BusinessItem? _existingItem;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadItem();
  }

  Future<void> _loadItem() async {
    setState(() => _isLoading = true);
    final result =
        await ref.read(businessRepositoryProvider).getItem(widget.itemId!);
    result.fold(
      (_) {},
      (item) {
        _existingItem = item;
        _nameController.text = item.name;
        _priceController.text = item.price.toStringAsFixed(2);
        _descriptionController.text = item.description ?? '';
        _categoryController.text = item.category ?? '';
      },
    );
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final price = double.parse(_priceController.text.trim());
    final notifier = ref.read(itemsListProvider.notifier);
    final success = widget.isEditing
        ? await notifier.updateItem(
            _existingItem!.copyWith(
              name: _nameController.text.trim(),
              price: price,
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              category: _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim(),
            ),
          )
        : await notifier.createItem(
            name: _nameController.text.trim(),
            price: price,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            category: _categoryController.text.trim().isEmpty
                ? null
                : _categoryController.text.trim(),
          );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showToast(context, message: 'items.saved'.tr(), status: 'success');
      context.pop();
    } else {
      showToast(context, message: 'items.save_error'.tr(), status: 'error');
    }
  }

  Future<void> _delete() async {
    if (!widget.isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('items.delete_title'.tr()),
        content: Text('items.delete_message'.tr()),
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
    final success =
        await ref.read(itemsListProvider.notifier).deleteItem(widget.itemId!);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      showToast(context, message: 'items.deleted'.tr(), status: 'success');
      context.pop();
    } else {
      showToast(context, message: 'items.delete_error'.tr(), status: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('items.edit'.tr())),
        body: const Center(child: AppLoading()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'items.edit'.tr() : 'items.add'.tr()),
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
                label: 'items.name'.tr(),
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'items.name_required'.tr()
                    : null,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'items.price'.tr(),
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final price = double.tryParse(v ?? '');
                  if (price == null || price <= 0) {
                    return 'items.price_invalid'.tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'items.category'.tr(),
                hint: 'items.category_hint'.tr(),
                controller: _categoryController,
              ),
              SizedBox(height: AppSpacing.lg.h),
              AppTextField(
                label: 'items.description'.tr(),
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.xxxl.h),
              AppButton(
                label:
                    widget.isEditing ? 'common.save'.tr() : 'items.create'.tr(),
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
