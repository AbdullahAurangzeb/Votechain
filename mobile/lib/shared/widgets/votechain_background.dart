import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Low-opacity hero / background illustration layer.
class VoteChainBackgroundIllustration extends StatelessWidget {
  const VoteChainBackgroundIllustration({
    super.key,
    required this.imageUrl,
    this.opacity = 0.2,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  final double opacity;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height * 0.55,
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Radial emerald glow used on splash and auth screens.
class VoteChainAtmosphericGlow extends StatelessWidget {
  const VoteChainAtmosphericGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [
              AppColors.primaryDisplay.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer security badge — Stitch login footer pattern.
class VoteChainSecurityFooter extends StatelessWidget {
  const VoteChainSecurityFooter({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Opacity(
      opacity: 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: AppSpacing.sm + AppSpacing.xs,
            color: textTheme.labelMedium?.color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              message ??
                  'Your data is encrypted and secured using blockchain technology.',
              textAlign: TextAlign.center,
              style: textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Backward-compatible aliases for authentication backgrounds.
typedef AuthBackgroundIllustration = VoteChainBackgroundIllustration;
typedef AuthAtmosphericGlow = VoteChainAtmosphericGlow;
typedef AuthSecurityFooter = VoteChainSecurityFooter;
