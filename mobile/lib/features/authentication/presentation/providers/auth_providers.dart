import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/auth_remote_data_source.dart';
import '../../data/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/use_cases/forgot_password_use_case.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/entities/auth_user.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>(
  (ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)),
);

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)),
);

/// Globally available authenticated user for the active session.
final authSessionProvider =
    StateNotifierProvider<AuthSessionController, AuthUser?>((ref) {
  return AuthSessionController(ref.watch(authRepositoryProvider));
});

/// Holds the active authenticated user across the app session.
class AuthSessionController extends StateNotifier<AuthUser?> {
  AuthSessionController(this._repository) : super(null);

  final AuthRepository _repository;

  void setUser(AuthUser? user) => state = user;

  Future<void> clear() async {
    await _repository.clearSession();
    state = null;
  }
}
