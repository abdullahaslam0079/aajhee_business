import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/routing/app_routes.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('branches.title'.tr()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.branchCreate),
        icon: const Icon(Icons.add),
        label: Text('branches.add'.tr()),
      ),
      body: branchesAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => AppErrorWidget(
          message: 'branches.load_error'.tr(),
          onRetry: () => ref.read(branchesListProvider.notifier).refresh(),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return AppEmptyState(
              icon: Icons.storefront_outlined,
              title: 'branches.empty_title'.tr(),
              subtitle: 'branches.empty_subtitle'.tr(),
              actionLabel: 'branches.add'.tr(),
              onAction: () => context.push(AppRoutes.branchCreate),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(branchesListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              itemCount: branches.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
              itemBuilder: (context, index) {
                return _BranchCard(branch: branches[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _BranchCard extends ConsumerWidget {
  const _BranchCard({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return AppCard(
      onTap: () => context.push(AppRoutes.branchEdit(branch.id)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: AppBorders.sm,
            ),
            child: Icon(Icons.store, color: cs.onPrimaryContainer),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (branch.address != null) ...[
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    [branch.address, branch.city]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(', '),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                SizedBox(height: AppSpacing.sm.h),
                Wrap(
                  spacing: AppSpacing.md.w,
                  runSpacing: AppSpacing.xs.h,
                  children: [
                    _StatChip(
                      icon: Icons.qr_code_scanner,
                      label: 'branches.scans'.tr(
                        namedArgs: {'count': formatNumber(branch.scanCount)},
                      ),
                    ),
                    _StatChip(
                      icon: Icons.people_outline,
                      label: 'branches.users'.tr(
                        namedArgs: {'count': formatNumber(branch.uniqueUsers)},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

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
