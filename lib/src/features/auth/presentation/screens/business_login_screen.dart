import 'package:aajhee_business/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:aajhee_business/src/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:aajhee_business/src/imports/core_imports.dart';
import 'package:aajhee_business/src/imports/packages_imports.dart';

class BusinessLoginScreen extends ConsumerStatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  ConsumerState<BusinessLoginScreen> createState() =>
      _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends ConsumerState<BusinessLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref.read(authControllerProvider.notifier).login(
          context: context,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return AuthPageLayout(
      title: 'auth.business_login'.tr(),
      subtitle: 'auth.business_login_subtitle'.tr(),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _emailController,
              enabled: !isLoading,
              label: 'auth.email'.tr(),
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'auth.email_required'.tr();
                }
                if (!AppUtils.isValidEmail(v!)) {
                  return 'auth.email_invalid'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md.h),
            AppTextField(
              controller: _passwordController,
              enabled: !isLoading,
              label: 'auth.password'.tr(),
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'auth.password_required'.tr();
                }
                if (v!.length < 6) {
                  return 'auth.password_too_short'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.sm.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 5.w,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() => _rememberMe = value ?? false);
                              },
                      ),
                    ),
                    Text(
                      'auth.remember_me'.tr(),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: isLoading ? null : () {},
                  child: Text(
                    'auth.forgot_password'.tr(),
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              label: 'auth.sign_in'.tr(),
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleLogin,
              width: ButtonSize.large,
              isFullWidth: true,
            ),
            SizedBox(height: AppSpacing.xxxl.h),
            Text(
              'auth.or_continue_with'.tr(),
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.md.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20.w,
              children: [
                _SocialButton(
                  color: const Color(0xFFEA4335).withValues(alpha: 0.8),
                  icon: AppAssets.googleIcon,
                ),
                _SocialButton(
                  color: const Color(0xFF4285F4),
                  icon: AppAssets.facebookIcon,
                ),
                _SocialButton(
                  color: const Color(0xFF000000),
                  icon: AppAssets.appleIcon,
                ),
              ],
            ),
          ],
        ),
      ),
      footer: InkWell(
        onTap: isLoading ? null : () => context.push(AppRoutes.register),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'auth.dont_have_business_account'.tr(),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            children: [
              TextSpan(
                text: 'auth.register_business'.tr(),
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.color, required this.icon});

  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      height: 50.w,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          shape: const RoundedRectangleBorder(borderRadius: AppBorders.button),
        ),
        child: SvgPicture.asset(icon),
      ),
    );
  }
}
