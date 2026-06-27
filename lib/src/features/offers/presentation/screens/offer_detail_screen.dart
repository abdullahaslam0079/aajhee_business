import 'package:goluto_business/src/features/business/domain/enums/offer_display_status.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/features/business/utils/offer_qr_codec.dart';
import 'package:goluto_business/src/features/offers/presentation/helpers/offer_display_helper.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/routing/app_routes.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OfferDetailScreen extends ConsumerWidget {
  const OfferDetailScreen({super.key, required this.offerId});

  final String offerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(offerId));
    final branchesAsync = ref.watch(branchesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('offers.detail_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'common.edit'.tr(),
            onPressed: () => context.push(AppRoutes.offerEdit(offerId)),
          ),
        ],
      ),
      body: offerAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => AppErrorWidget(
          message: 'offers.load_error'.tr(),
          onRetry: () => ref.invalidate(offerDetailProvider(offerId)),
        ),
        data: (offer) {
          if (offer == null) {
            return AppEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'offers.not_found'.tr(),
            );
          }

          final branches = branchesAsync.whenOrNull(data: (data) => data) ?? [];
          final branchNames = offer.appliesToAllBranches
              ? ['offers.all_branches'.tr()]
              : branches
                  .where((b) => offer.branchIds.contains(b.id))
                  .map((b) => b.name)
                  .toList();

          final qrPayload = OfferQrCodec.encode(offer);

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  offer.title,
                  style: context.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (offer.description != null) ...[
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    offer.description!,
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.xl.h),
                _DetailRow(
                  label: 'offers.field_type'.tr(),
                  value: offer.type.labelKey.tr(),
                ),
                _DetailRow(
                  label: 'offers.discount'.tr(),
                  value: OfferDisplayHelper.discountLabel(offer),
                ),
                if (offer.type == OfferType.item &&
                    offer.itemName != null &&
                    offer.itemName!.isNotEmpty) ...[
                  _DetailRow(
                    label: 'offers.field_item_name'.tr(),
                    value: offer.itemName!,
                  ),
                ],
                _DetailRow(
                  label: 'offers.field_usage_limit'.tr(),
                  value: OfferDisplayHelper.usageLimitLabel(offer),
                ),
                _DetailRow(
                  label: 'offers.visible_at'.tr(),
                  value: branchNames.join(', '),
                ),
                _DetailRow(
                  label: 'offers.status'.tr(),
                  value: offer.displayStatus.labelKey.tr(),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Wrap(
                  spacing: AppSpacing.md.w,
                  runSpacing: AppSpacing.md.h,
                  children: [
                    _StatTile(
                      icon: Icons.qr_code_scanner,
                      label: 'offers.scans'.tr(),
                      value: formatNumber(offer.scanCount),
                    ),
                    _StatTile(
                      icon: Icons.check_circle_outline,
                      label: 'offers.redemptions'.tr(),
                      value: formatNumber(offer.redemptionCount),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxxl.h),
                AppCard(
                  title: 'offers.qr_title'.tr(),
                  subtitle: 'offers.qr_subtitle'.tr(),
                  child: Column(
                    children: [
                      if (offer.qrCode.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.lg.w),
                          child: Text(
                            'offers.qr_unavailable'.tr(),
                            style: context.theme.textTheme.bodyMedium,
                          ),
                        )
                      else ...[
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.lg.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppBorders.md,
                            ),
                            child: QrImageView(
                              data: qrPayload,
                              version: QrVersions.auto,
                              size: 200.w,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        SelectableText(
                          qrPayload,
                          style: context.theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        AppButton(
                          label: 'offers.copy_qr'.tr(),
                          variant: ButtonVariant.secondary,
                          prefixIcon: const Icon(Icons.copy, size: 18),
                          isFullWidth: true,
                          onPressed: () async {
                            final result =
                                await CopyService.instance.copy(qrPayload);
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return AppCard(
      child: SizedBox(
        width: context.isMobile ? double.infinity : 160.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              value,
              style: context.theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
