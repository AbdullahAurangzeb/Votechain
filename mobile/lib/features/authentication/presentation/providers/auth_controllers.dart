import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/forgot_password_use_case.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import 'auth_providers.dart';

/// Splash bootstrap state.
enum SplashStatus { loading, navigateLogin, navigateAuthenticated }

class SplashState {
  const SplashState({
    required this.status,
    this.user,
  });

  final SplashStatus status;
  final AuthUser? user;

  SplashState copyWith({
    SplashStatus? status,
    AuthUser? user,
  }) =>
      SplashState(
        status: status ?? this.status,
        user: user ?? this.user,
      );
}

class SplashController extends StateNotifier<SplashState> {
  SplashController(this._restoreSession, this._sessionController)
      : super(const SplashState(status: SplashStatus.loading));

  final RestoreSessionUseCase _restoreSession;
  final AuthSessionController _sessionController;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 2800));

    final user = await _restoreSession();

    if (user != null) {
      _sessionController.setUser(user);
      state = SplashState(
        status: SplashStatus.navigateAuthenticated,
        user: user,
      );
      return;
    }

    state = const SplashState(status: SplashStatus.navigateLogin);
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, SplashState>((ref) {
  return SplashController(
    ref.watch(restoreSessionUseCaseProvider),
    ref.read(authSessionProvider.notifier),
  );
});

/// Login form + submission state.
class LoginState {
  const LoginState({
    this.identifier = '',
    this.password = '',
    this.rememberMe = false,
    this.isSubmitting = false,
    this.identifierError,
    this.passwordError,
    this.generalError,
    this.user,
  });

  final String identifier;
  final String password;
  final bool rememberMe;
  final bool isSubmitting;
  final String? identifierError;
  final String? passwordError;
  final String? generalError;
  final AuthUser? user;

  LoginState copyWith({
    String? identifier,
    String? password,
    bool? rememberMe,
    bool? isSubmitting,
    String? identifierError,
    String? passwordError,
    String? generalError,
    AuthUser? user,
    bool clearErrors = false,
  }) {
    return LoginState(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      identifierError:
          clearErrors ? null : identifierError ?? this.identifierError,
      passwordError: clearErrors ? null : passwordError ?? this.passwordError,
      generalError: clearErrors ? null : generalError ?? this.generalError,
      user: user ?? this.user,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController(this._login, this._sessionController)
      : super(const LoginState());

  final LoginUseCase _login;
  final AuthSessionController _sessionController;

  void setIdentifier(String value) =>
      state = state.copyWith(identifier: value, clearErrors: true);

  void setPassword(String value) =>
      state = state.copyWith(password: value, clearErrors: true);

  void setRememberMe(bool value) => state = state.copyWith(rememberMe: value);

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, clearErrors: true);

    try {
      final user = await _login(
        identifier: state.identifier,
        password: state.password,
      );
      _sessionController.setUser(user);
      state = state.copyWith(isSubmitting: false, user: user);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        generalError: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController(
    ref.watch(loginUseCaseProvider),
    ref.read(authSessionProvider.notifier),
  );
});

/// Registration step 1 form state.
class RegisterState {
  const RegisterState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.confirmPassword = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.user,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final bool isSubmitting;
  final String? errorMessage;
  final AuthUser? user;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? password,
    String? confirmPassword,
    bool? isSubmitting,
    String? errorMessage,
    AuthUser? user,
    bool clearError = false,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}

class RegisterController extends StateNotifier<RegisterState> {
  RegisterController(this._register, this._sessionController)
      : super(const RegisterState());

  final RegisterUseCase _register;
  final AuthSessionController _sessionController;

  void setFullName(String v) =>
      state = state.copyWith(fullName: v, clearError: true);
  void setEmail(String v) => state = state.copyWith(email: v, clearError: true);
  void setPhone(String v) => state = state.copyWith(phone: v, clearError: true);
  void setPassword(String v) =>
      state = state.copyWith(password: v, clearError: true);
  void setConfirmPassword(String v) =>
      state = state.copyWith(confirmPassword: v, clearError: true);

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final user = await _register(
        RegisterRequest(
          fullName: state.fullName,
          email: state.email,
          phone: state.phone,
          password: state.password,
          confirmPassword: state.confirmPassword,
        ),
      );
      _sessionController.setUser(user);
      state = state.copyWith(isSubmitting: false, user: user);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Registration failed. Please try again.',
      );
      return false;
    }
  }
}

final registerControllerProvider =
    StateNotifierProvider<RegisterController, RegisterState>((ref) {
  return RegisterController(
    ref.watch(registerUseCaseProvider),
    ref.read(authSessionProvider.notifier),
  );
});

/// Forgot password form state.
class ForgotPasswordState {
  const ForgotPasswordState({
    this.identifier = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.success = false,
  });

  final String identifier;
  final bool isSubmitting;
  final String? errorMessage;
  final bool success;

  ForgotPasswordState copyWith({
    String? identifier,
    bool? isSubmitting,
    String? errorMessage,
    bool? success,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      identifier: identifier ?? this.identifier,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController(this._useCase) : super(const ForgotPasswordState());

  final ForgotPasswordUseCase _useCase;

  void setIdentifier(String value) =>
      state = state.copyWith(identifier: value, clearError: true);

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, clearError: true, success: false);

    try {
      await _useCase(identifier: state.identifier);
      state = state.copyWith(isSubmitting: false, success: true);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to send reset link. Please try again.',
      );
      return false;
    }
  }

  void resetSuccess() => state = state.copyWith(success: false);
}

final forgotPasswordControllerProvider =
    StateNotifierProvider<ForgotPasswordController, ForgotPasswordState>((ref) {
  return ForgotPasswordController(ref.watch(forgotPasswordUseCaseProvider));
});
