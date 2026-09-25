import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

/// Responsive shell for auth screens — split layout on desktop, centered on mobile.
class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    if (context.isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(child: _BrandPanel(cs: cs, tt: tt)),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl.w,
                    vertical: AppSpacing.xl.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 480.w),
                    child: _FormContent(
                      title: title,
                      subtitle: subtitle,
                      form: form,
                      footer: footer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final maxWidth = context.isTablet ? 520.w : double.infinity;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.xl.h,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: _FormContent(
                title: title,
                subtitle: subtitle,
                form: form,
                footer: footer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.primary,
      padding: EdgeInsets.all(AppSpacing.xxxl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 48.sp, color: cs.onPrimary),
          SizedBox(height: AppSpacing.xl.h),
          Text(
            'Aajhee Business',
            style: tt.headlineLarge?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'Manage your store, offers, and orders from one place.',
            style: tt.bodyLarge?.copyWith(
              color: cs.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ).animate().fadeIn().slideY(begin: 0.2),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          subtitle,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ).animate().fadeIn().slideY(begin: 0.2),
        SizedBox(height: AppSpacing.xxxl.h),
        form,
        if (footer != null) ...[
          SizedBox(height: AppSpacing.xl.h),
          footer!,
        ],
      ],
    );
  }
}
