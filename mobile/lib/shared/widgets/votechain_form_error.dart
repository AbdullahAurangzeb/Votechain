import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Inline form validation / submission error message.
class VoteChainFormError extends StatelessWidget {
  const VoteChainFormError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.error,
          ),
    );
  }
}

/// Standard spacing wrapper for form errors above fields or actions.
class VoteChainFormErrorBlock extends StatelessWidget {
  const VoteChainFormErrorBlock({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();

    return Column(
      children: [
        VoteChainFormError(message: message!),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
