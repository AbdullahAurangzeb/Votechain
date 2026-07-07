// Stitch: VoteChain Registration - Step 1 (04ad90aa)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/votechain_form_error.dart';
import '../../../../shared/widgets/votechain_info_banner.dart';
import '../../../../shared/widgets/votechain_inline_link.dart';
import '../../../../shared/widgets/votechain_page_header.dart';
import '../../../../shared/widgets/votechain_password_field.dart';
import '../../../../shared/widgets/votechain_primary_button.dart';
import '../../../../shared/widgets/votechain_scroll_form.dart';
import '../../../../shared/widgets/votechain_step_indicator.dart';
import '../../../../shared/widgets/votechain_surface_card.dart';
import '../../../../shared/widgets/votechain_text_field.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../auth_navigation.dart';
import '../auth_routes.dart';
import '../providers/auth_controllers.dart';

/// Registration step 1 — personal information.
class RegisterPage extends ConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerControllerProvider);
    final controller = ref.read(registerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: const VoteChainAppBar(showBrand: true),
      body: VoteChainScrollForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VoteChainStepIndicator(
              currentStep: 1,
              totalSteps: 4,
              stepLabel: 'Personal Information',
            ),
            const SizedBox(height: AppSpacing.xl),
            const VoteChainPageHeader(
              title: 'Create Your Account',
              subtitle:
                  'Register to participate in secure blockchain-based elections.',
              maxSubtitleWidth: double.infinity,
            ),
            const SizedBox(height: AppSpacing.lg),
            VoteChainSurfaceCard(
              color: AppColors.surfaceContainer.withValues(alpha: 0.7),
              child: Column(
                children: [
                  VoteChainTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    icon: AppIcons.person,
                    onChanged: controller.setFullName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainTextField(
                    label: 'Email Address',
                    hint: 'example@email.com',
                    icon: AppIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: controller.setEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainTextField(
                    label: 'Phone Number',
                    hint: '+92 300 0000000',
                    icon: AppIcons.call,
                    keyboardType: TextInputType.phone,
                    onChanged: controller.setPhone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainPasswordField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    onChanged: controller.setPassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  VoteChainPasswordField(
                    label: 'Confirm Password',
                    hint: 'Repeat your password',
                    onChanged: controller.setConfirmPassword,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              VoteChainFormError(message: state.errorMessage!),
            ],
            const SizedBox(height: AppSpacing.lg),
            VoteChainPrimaryButton(
              label: 'Continue',
              icon: AppIcons.arrowForward,
              isLoading: state.isSubmitting,
              onPressed: () async {
                final ok = await controller.submit();
                if (ok && context.mounted) {
                  final user = ref.read(registerControllerProvider).user;
                  if (user != null) {
                    navigateAfterAuthentication(GoRouter.of(context), user);
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const VoteChainInfoBanner(
              message:
                  'The next step will verify your identity using your CNIC and facial recognition to ensure a secure voting environment.',
            ),
            const SizedBox(height: AppSpacing.xl),
            VoteChainInlineLink(
              prefix: 'Already have an account? ',
              linkText: 'Login',
              onTap: () => context.go(AuthRoutes.login),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
