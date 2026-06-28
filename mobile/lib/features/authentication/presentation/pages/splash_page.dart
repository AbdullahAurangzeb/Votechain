// Stitch: VoteChain Splash Screen (c86c1acf)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_spacing.dart';
import '../../data/auth_assets.dart';
import '../auth_routes.dart';
import '../../../../shared/widgets/votechain_background.dart';
import '../providers/app_bootstrap_provider.dart';
import '../providers/auth_controllers.dart';
import '../widgets/auth_splash_status.dart';

/// Splash screen — auto-navigates to login after bootstrap delay.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBootstrap());
  }

  Future<void> _runBootstrap() async {
    ref.read(hasCompletedSplashProvider.notifier).state = false;
    await ref.read(splashControllerProvider.notifier).initialize();
    if (!mounted) return;

    ref.read(hasCompletedSplashProvider.notifier).state = true;
    context.go(AuthRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.brandNeutral,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const VoteChainAtmosphericGlow(),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 0.9,
                colors: [
                  AppColors.secondaryContainer.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final heroHeight =
                    (constraints.maxHeight * 0.32).clamp(140.0, 280.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.12),
                      CachedNetworkImage(
                        imageUrl: AuthAssets.splashHero,
                        height: heroHeight,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => SizedBox(
                          height: heroHeight,
                          child: Icon(
                            AppIcons.shield,
                            size: heroHeight * 0.45,
                            color: AppColors.primaryDisplay.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          AppIcons.shield,
                          size: heroHeight * 0.5,
                          color: AppColors.primaryDisplay.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'VoteChain',
                        style: textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Secure, Transparent, and Intelligent Mobile Voting',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      const AuthSplashStatusIndicator(),
                      const SizedBox(height: AppSpacing.xl),
                      Opacity(
                        opacity: 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.shieldLock,
                              size: 14,
                              color: textTheme.labelMedium?.color,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'End-to-End Encrypted',
                              style: textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
