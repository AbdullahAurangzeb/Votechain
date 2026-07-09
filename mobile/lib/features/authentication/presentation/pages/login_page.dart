// Stitch: VoteChain Login (e2cca143)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_background.dart';
import '../../../../shared/widgets/votechain_form_error.dart';
import '../../../../shared/widgets/votechain_inline_link.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_password_field.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_text_field.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../data/auth_assets.dart';
import '../../../verification/presentation/verification_restore_navigation.dart';
import '../auth_routes.dart';
import '../providers/auth_controllers.dart';

/// Login screen — authenticates against the VoteChain backend API.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          VoteChainBackgroundIllustration(imageUrl: AuthAssets.loginBackground),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      CachedNetworkImage(
                        imageUrl: AuthAssets.loginLogo,
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(
                          AppIcons.shield,
                          size: 72,
                          color: AppColors.primaryDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const VoteChainPageHeader(
                        title: 'Welcome Back',
                        subtitle:
                            'Login to continue your secure voting journey.',
                        maxSubtitleWidth: double.infinity,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      VoteChainFormErrorBlock(message: state.generalError),
                      VoteChainTextField(
                        label: 'Email or CNIC',
                        hint: 'Enter your credentials',
                        icon: AppIcons.badge,
                        onChanged: controller.setIdentifier,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      VoteChainPasswordField(
                        label: 'Password',
                        hint: '••••••••',
                        onChanged: controller.setPassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          SizedBox(
                            height: AppSpacing.touchTargetMin,
                            child: Checkbox(
                              value: state.rememberMe,
                              onChanged: (v) =>
                                  controller.setRememberMe(v ?? false),
                              activeColor: AppColors.primaryDisplay,
                              side: const BorderSide(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Remember Me',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                            ),
                            onPressed: () =>
                                context.push(AuthRoutes.forgotPassword),
                            child: Text(
                              'Forgot Password?',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryDisplay,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      VoteChainPrimaryButton(
                        label: 'Login',
                        icon: AppIcons.arrowForward,
                        isLoading: state.isSubmitting,
                        loadingLabel: 'Securing Connection...',
                        onPressed: () async {
                          final ok = await controller.submit();
                          if (ok && context.mounted) {
                            final user = ref.read(loginControllerProvider).user;
                            if (user != null) {
                              await navigateWithVerificationRestore(
                                ref,
                                GoRouter.of(context),
                                user,
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      VoteChainInlineLink(
                        prefix: "Don't have an account? ",
                        linkText: 'Register',
                        alignLinkToBaseline: true,
                        onTap: () => context.push(AuthRoutes.register),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const VoteChainSecurityFooter(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
