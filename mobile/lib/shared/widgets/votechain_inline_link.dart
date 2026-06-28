import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Centered "prefix + tappable link" row used on auth screens.
class VoteChainInlineLink extends StatelessWidget {
  const VoteChainInlineLink({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
    this.alignLinkToBaseline = false,
  });

  final String prefix;
  final String linkText;
  final VoidCallback onTap;
  final bool alignLinkToBaseline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final link = GestureDetector(
      onTap: onTap,
      child: Text(
        linkText,
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryDisplay,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Text.rich(
      TextSpan(
        text: prefix,
        style: textTheme.bodyMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        children: [
          WidgetSpan(
            alignment: alignLinkToBaseline
                ? PlaceholderAlignment.baseline
                : PlaceholderAlignment.middle,
            baseline: TextBaseline.alphabetic,
            child: link,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
