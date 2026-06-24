import 'package:goluto_business/src/features/auth/presentation/widgets/auth_page_layout.dart';
import 'package:goluto_business/src/imports/core_imports.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/routing/app_navigation.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // if (!(_formKey.currentState?.validate() ?? false)) {
    //   return;
    // }

    // ref.read(authControllerProvider.notifier).signUp(
    //       context: context,
    //       name: _businessNameController.text.trim(),
    //       email: _emailController.text.trim(),
    //       password: _passwordController.text,
    //     );
    navigateAfterAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    const isLoading = false;
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return AuthPageLayout(
      title: 'auth.business_register'.tr(),
      subtitle: 'auth.business_register_subtitle'.tr(),
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _businessNameController,
              enabled: !isLoading,
              label: 'auth.business_name'.tr(),
              prefixIcon: const Icon(Icons.store_outlined),
              // validator: (v) =>
              //     AppUtils.isBlank(v) ? 'auth.business_name_required'.tr() : null,
            ),
            SizedBox(height: AppSpacing.md.h),
            AppTextField(
              controller: _emailController,
              enabled: !isLoading,
              keyboardType: TextInputType.emailAddress,
              label: 'auth.email'.tr(),
              prefixIcon: const Icon(Icons.email_outlined),
              // validator: (v) {
              //   if (AppUtils.isBlank(v)) {
              //     return 'auth.email_required'.tr();
              //   }
              //   if (!AppUtils.isValidEmail(v!)) {
              //     return 'auth.email_invalid'.tr();
              //   }
              //   return null;
              // },
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
              // validator: (v) {
              //   if (AppUtils.isBlank(v)) {
              //     return 'auth.password_required'.tr();
              //   }
              //   if (v!.length < 6) {
              //     return 'auth.password_too_short'.tr();
              //   }
              //   return null;
              // },
            ),
            SizedBox(height: AppSpacing.md.h),
            AppTextField(
              controller: _confirmPasswordController,
              enabled: !isLoading,
              label: 'auth.confirm_password'.tr(),
              obscureText: _obscureConfirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
              // validator: (v) {
              //   if (AppUtils.isBlank(v)) {
              //     return 'auth.confirm_password_required'.tr();
              //   }
              //   if (v != _passwordController.text) {
              //     return 'auth.passwords_do_not_match'.tr();
              //   }
              //   return null;
              // },
            ),
            SizedBox(height: AppSpacing.lg.h),
            AppButton(
              label: 'auth.create_business_account'.tr(),
              isLoading: isLoading,
              onPressed: isLoading ? null : _handleRegister,
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
        onTap: isLoading ? null : () => context.pop(),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'auth.already_have_business_account'.tr(),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            children: [
              TextSpan(
                text: 'auth.sign_in'.tr(),
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
