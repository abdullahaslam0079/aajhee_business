import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_display_status.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/features/offers/presentation/helpers/offer_display_helper.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/routing/app_routes.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('offers.title'.tr()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.offerCreate),
        icon: const Icon(Icons.add),
        label: Text('offers.add'.tr()),
      ),
      body: offersAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => AppErrorWidget(
          message: 'offers.load_error'.tr(),
          onRetry: () => ref.read(offersListProvider.notifier).refresh(),
        ),
        data: (offers) {
          if (offers.isEmpty) {
            return AppEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'offers.empty_title'.tr(),
              subtitle: 'offers.empty_subtitle'.tr(),
              actionLabel: 'offers.add'.tr(),
              onAction: () => context.push(AppRoutes.offerCreate),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(offersListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              itemCount: offers.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
              itemBuilder: (context, index) {
                return _OfferCard(offer: offers[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final statusColor = switch (offer.displayStatus) {
      OfferDisplayStatus.active => context.appColors.success,
      OfferDisplayStatus.paused => context.appColors.warning,
      OfferDisplayStatus.expired => cs.error,
    };

    return AppCard(
      onTap: () => context.push(AppRoutes.offerDetail(offer.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  offer.title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm.w,
                  vertical: AppSpacing.xs.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: AppBorders.sm,
                ),
                child: Text(
                  offer.displayStatus.labelKey.tr(),
                  style: tt.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (offer.description != null) ...[
            SizedBox(height: AppSpacing.xs.h),
            Text(
              offer.description!,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: AppSpacing.sm.h),
          Text(
            OfferDisplayHelper.discountLabel(offer),
            style: tt.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Wrap(
            spacing: AppSpacing.md.w,
            runSpacing: AppSpacing.xs.h,
            children: [
              _InfoChip(
                icon: Icons.qr_code_scanner,
                label: '${formatNumber(offer.scanCount)} ${'offers.scans'.tr()}',
              ),
              _InfoChip(
                icon: Icons.check_circle_outline,
                label:
                    '${formatNumber(offer.redemptionCount)} ${'offers.redemptions'.tr()}',
              ),
              _InfoChip(
                icon: Icons.schedule,
                label: OfferDisplayHelper.usageLimitLabel(offer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: cs.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text(
          label,
          style: context.theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
