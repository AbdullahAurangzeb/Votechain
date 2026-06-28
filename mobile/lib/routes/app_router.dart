import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/auth_routes.dart';
import '../features/authentication/presentation/pages/forgot_password_page.dart';
import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/authentication/presentation/pages/splash_page.dart';
import '../features/authentication/presentation/providers/app_bootstrap_provider.dart';
import '../features/verification/presentation/pages/ai_scanning_page.dart';
import '../features/verification/presentation/pages/review_extracted_info_page.dart';
import '../features/verification/presentation/pages/upload_cnic_page.dart';
import '../features/verification/presentation/pages/verification_pending_page.dart';
import '../features/verification/presentation/verification_routes.dart';

/// Application route configuration (GoRouter).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: AuthRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final splashDone = ref.read(hasCompletedSplashProvider);
      final onSplash = state.matchedLocation == AuthRoutes.splash;

      if (!splashDone && !onSplash) {
        return AuthRoutes.splash;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AuthRoutes.splash,
        name: AuthRoutes.splashName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AuthRoutes.login,
        name: AuthRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AuthRoutes.register,
        name: AuthRoutes.registerName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AuthRoutes.forgotPassword,
        name: AuthRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: VerificationRoutes.uploadCnic,
        name: VerificationRoutes.uploadCnicName,
        builder: (context, state) => const UploadCnicPage(),
      ),
      GoRoute(
        path: VerificationRoutes.scanning,
        name: VerificationRoutes.scanningName,
        builder: (context, state) => const AiScanningPage(),
      ),
      GoRoute(
        path: VerificationRoutes.review,
        name: VerificationRoutes.reviewName,
        builder: (context, state) => const ReviewExtractedInfoPage(),
      ),
      GoRoute(
        path: VerificationRoutes.pending,
        name: VerificationRoutes.pendingName,
        builder: (context, state) => const VerificationPendingPage(),
      ),
    ],
  );
});
