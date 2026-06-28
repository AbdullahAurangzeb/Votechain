import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';

/// Centered scrollable form body with consistent auth screen padding.
class VoteChainScrollForm extends StatelessWidget {
  const VoteChainScrollForm({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.wrapInSafeArea = true,
  });

  final Widget child;
  final double maxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapInSafeArea;

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [child],
          ),
        ),
      ),
    );

    if (!wrapInSafeArea) return scrollView;
    return SafeArea(child: scrollView);
  }
}
