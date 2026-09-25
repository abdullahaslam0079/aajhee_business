import 'package:aajhee_business/src/features/business/domain/entities/branch.dart';
import 'package:aajhee_business/src/features/business/domain/entities/offer.dart';
import 'package:aajhee_business/src/features/business/utils/offer_qr_codec.dart';
import 'package:aajhee_business/src/features/offers/presentation/helpers/offer_display_helper.dart';
import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OfferQrPosterCard extends StatefulWidget {
  const OfferQrPosterCard({
    super.key,
    required this.offer,
    required this.branches,
  });

  final Offer offer;
  final List<Branch> branches;

  @override
  State<OfferQrPosterCard> createState() => _OfferQrPosterCardState();
}

class _OfferQrPosterCardState extends State<OfferQrPosterCard> {
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _selectedBranchId = _availableBranches.firstOrNull?.id;
  }

  List<Branch> get _availableBranches {
    if (widget.offer.appliesToAllBranches) return widget.branches;
    return widget.branches
        .where((branch) => widget.offer.branchIds.contains(branch.id))
        .toList();
  }

  String get _qrPayload {
    return OfferQrCodec.encode(
      widget.offer,
      branchId: _selectedBranchId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final branches = _availableBranches;

    if (widget.offer.qrCode.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.lg.w),
        child: Text(
          'offers.qr_unavailable'.tr(),
          style: context.theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (branches.length > 1) ...[
          Text(
            'offers.poster_branch_label'.tr(),
            style: context.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedBranchId,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: AppBorders.sm),
            ),
            items: branches
                .map(
                  (branch) => DropdownMenuItem(
                    value: branch.id,
                    child: Text(branch.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedBranchId = value),
          ),
          SizedBox(height: AppSpacing.lg.h),
        ],
        Container(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppBorders.md,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            children: [
              Text(
                widget.offer.title,
                style: context.theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs.h),
              Text(
                OfferDisplayHelper.discountLabel(widget.offer),
                style: context.theme.textTheme.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (_selectedBranchId != null) ...[
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  branches
                      .firstWhere((b) => b.id == _selectedBranchId)
                      .name,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.lg.h),
              QrImageView(
                data: _qrPayload,
                version: QrVersions.auto,
                size: 220.w,
                backgroundColor: Colors.white,
              ),
              SizedBox(height: AppSpacing.md.h),
              Text(
                'offers.poster_scan_hint'.tr(),
                style: context.theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),
        SelectableText(
          _qrPayload,
          style: context.theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: cs.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSpacing.lg.h),
        AppButton(
          label: 'offers.copy_qr'.tr(),
          variant: ButtonVariant.secondary,
          prefixIcon: const Icon(Icons.copy, size: 18),
          isFullWidth: true,
          onPressed: () async {
            final result = await CopyService.instance.copy(_qrPayload);
            if (!context.mounted) return;
            result.fold(
              (_) => showToast(
                context,
                message: 'offers.copy_error'.tr(),
                status: 'error',
              ),
              (_) => showToast(
                context,
                message: 'offers.copy_success'.tr(),
                status: 'success',
              ),
            );
          },
        ),
      ],
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
