import 'package:goluto_business/src/features/auth/presentation/providers/session_provider.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final user = ref.watch(sessionProvider).user;
    final statsAsync = ref.watch(dashboardStatsProvider);
    final maxContentWidth = context.isDesktop ? 960.w : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard.title'.tr()),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(dashboardStatsProvider.notifier).refresh(),
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(AppSpacing.lg.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboard.welcome'.tr(),
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'dashboard.subtitle'.tr(),
                    style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (user?.name != null) ...[
                    SizedBox(height: AppSpacing.lg.h),
                    Text(user!.name!, style: tt.titleLarge),
                  ],
                  SizedBox(height: AppSpacing.xxxl.h),
                  statsAsync.when(
                    loading: () => const Center(child: AppLoading()),
                    error: (_, __) => AppErrorWidget(
                      message: 'dashboard.load_error'.tr(),
                      onRetry: () => ref
                          .read(dashboardStatsProvider.notifier)
                          .refresh(),
                    ),
                    data: (stats) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatsGrid(stats: stats),
                        SizedBox(height: AppSpacing.xxxl.h),
                        if (stats.topBranch != null) ...[
                          Text(
                            'dashboard.top_branch'.tr(),
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md.h),
                          _TopBranchCard(branch: stats.topBranch!),
                          SizedBox(height: AppSpacing.xxxl.h),
                        ],
                        if (stats.branchPerformance.length > 1) ...[
                          Text(
                            'dashboard.branch_performance'.tr(),
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.md.h),
                          ...stats.branchPerformance.map(
                            (b) => Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                              child: _BranchPerformanceRow(
                                branch: b,
                                maxUsers: stats.topBranch?.uniqueUsers ?? 1,
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxxl.h),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    'dashboard.quick_actions'.tr(),
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.md.h),
                  Wrap(
                    spacing: AppSpacing.md.w,
                    runSpacing: AppSpacing.md.h,
                    children: [
                      _DashboardCard(
                        icon: Icons.storefront_outlined,
                        label: 'dashboard.stores'.tr(),
                        subtitle: 'dashboard.stores_subtitle'.tr(),
                        onTap: () => context.push(AppRoutes.branches),
                      ),
                      _DashboardCard(
                        icon: Icons.local_offer_outlined,
                        label: 'dashboard.offers'.tr(),
                        subtitle: 'dashboard.offers_subtitle'.tr(),
                        onTap: () => context.push(AppRoutes.offers),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.store,
        label: 'dashboard.stat_branches'.tr(),
        value: formatNumber(stats.totalBranches),
        color: context.theme.colorScheme.primary,
      ),
      _StatItem(
        icon: Icons.local_offer,
        label: 'dashboard.stat_offers'.tr(),
        value: formatNumber(stats.totalOffers),
        subtitle: 'dashboard.stat_active'.tr(
          namedArgs: {'count': '${stats.activeOffers}'},
        ),
        color: context.appColors.success,
      ),
      _StatItem(
        icon: Icons.qr_code_scanner,
        label: 'dashboard.stat_scans'.tr(),
        value: formatNumber(stats.totalScans),
        color: context.appColors.info,
      ),
      _StatItem(
        icon: Icons.people,
        label: 'dashboard.stat_users'.tr(),
        value: formatNumber(stats.uniqueUsers),
        subtitle: 'dashboard.stat_redemptions'.tr(
          namedArgs: {'count': formatNumber(stats.totalRedemptions)},
        ),
        color: context.appColors.warning,
      ),
    ];

    return Wrap(
      spacing: AppSpacing.md.w,
      runSpacing: AppSpacing.md.h,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final cardWidth = context.isMobile ? double.infinity : 220.w;

    return SizedBox(
      width: cardWidth,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 28.sp, color: item.color),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              item.value,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(item.label, style: tt.bodyMedium),
            if (item.subtitle != null) ...[
              SizedBox(height: AppSpacing.xs.h),
              Text(
                item.subtitle!,
                style: tt.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBranchCard extends StatelessWidget {
  const _TopBranchCard({required this.branch});

  final BranchPerformance branch;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return AppCard(
      color: cs.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: AppBorders.sm,
            ),
            child: Icon(Icons.emoji_events, color: cs.onPrimary),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.branchName,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Text(
                  'dashboard.top_branch_subtitle'.tr(
                    namedArgs: {
                      'users': formatNumber(branch.uniqueUsers),
                      'scans': formatNumber(branch.scanCount),
                    },
                  ),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchPerformanceRow extends StatelessWidget {
  const _BranchPerformanceRow({
    required this.branch,
    required this.maxUsers,
  });

  final BranchPerformance branch;
  final int maxUsers;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final progress = maxUsers > 0 ? branch.uniqueUsers / maxUsers : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  branch.branchName,
                  style: context.theme.textTheme.titleSmall,
                ),
              ),
              Text(
                formatNumber(branch.uniqueUsers),
                style: context.theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          ClipRRect(
            borderRadius: AppBorders.full,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xs.h),
          Text(
            'dashboard.branch_stats'.tr(
              namedArgs: {
                'scans': formatNumber(branch.scanCount),
                'redemptions': formatNumber(branch.redemptionCount),
              },
            ),
            style: context.theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final cardWidth = context.isMobile ? double.infinity : 280.w;

    return SizedBox(
      width: cardWidth,
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 32.sp, color: cs.primary),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    subtitle,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
