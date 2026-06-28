// Stitch: Forgot Password (8032ec75)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_form_error.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_scroll_form.dart';
import '../../../../shared/widgets/votechain_success_banner.dart';
import '../../../../shared/widgets/votechain_text_button.dart';
import '../../../../shared/widgets/votechain_text_field.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../data/auth_assets.dart';
import '../auth_routes.dart';
import '../providers/auth_controllers.dart';

/// Forgot password — mock reset link flow.
class ForgotPasswordPage extends ConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final controller = ref.read(forgotPasswordControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: VoteChainAppBar(
        showBack: true,
        onBack: () => context.go(AuthRoutes.login),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            VoteChainScrollForm(
              wrapInSafeArea: false,
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: AuthAssets.forgotPasswordHero,
                    width: 256,
                    height: 256,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(
                      AppIcons.shieldLock,
                      size: 120,
                      color: AppColors.brandSecondary.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const VoteChainPageHeader(
                    title: 'Forgot Password?',
                    subtitle:
                        "Enter your registered email address or CNIC. We'll send you a secure password reset link.",
                    maxSubtitleWidth: 360,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  VoteChainFormErrorBlock(message: state.errorMessage),
                  VoteChainTextField(
                    label: 'Email or CNIC',
                    hint: 'e.g. john@example.com',
                    icon: AppIcons.mail,
                    onChanged: controller.setIdentifier,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainPrimaryButton(
                    label: 'Send Reset Link',
                    icon: AppIcons.send,
                    isLoading: state.isSubmitting,
                    loadingLabel: 'Sending...',
                    onPressed: () => controller.submit(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  VoteChainTextButton(
                    label: 'Back to Login',
                    expanded: true,
                    onPressed: () => context.go(AuthRoutes.login),
                  ),
                ],
              ),
            ),
            if (state.success)
              Positioned(
                left: AppSpacing.screenHorizontal,
                right: AppSpacing.screenHorizontal,
                bottom: AppSpacing.lg,
                child: const VoteChainSuccessBanner(
                  message: 'Password reset link sent successfully.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
