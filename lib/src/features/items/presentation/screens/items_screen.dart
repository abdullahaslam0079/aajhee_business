import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/presentation/providers/business_providers.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';

class ItemsScreen extends ConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('items.title'.tr()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.itemCreate),
        icon: const Icon(Icons.add),
        label: Text('items.add'.tr()),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (_, __) => AppErrorWidget(
          message: 'items.load_error'.tr(),
          onRetry: () => ref.read(itemsListProvider.notifier).refresh(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'items.empty_title'.tr(),
              subtitle: 'items.empty_subtitle'.tr(),
              actionLabel: 'items.add'.tr(),
              onAction: () => context.push(AppRoutes.itemCreate),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(itemsListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.lg.w),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.md.h),
              itemBuilder: (context, index) => _ItemCard(item: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final BusinessItem item;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return AppCard(
      onTap: () => context.push(AppRoutes.itemEdit(item.id)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.md.w),
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: AppBorders.sm,
            ),
            child: Icon(Icons.restaurant_menu, color: cs.onSecondaryContainer),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (item.category != null) ...[
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    item.category!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                if (item.description != null) ...[
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    item.description!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            '€${item.price.toStringAsFixed(2)}',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}
