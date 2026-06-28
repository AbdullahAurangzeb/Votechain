import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the splash bootstrap sequence has finished this app session.
///
/// Used by GoRouter to force `/` before any deep link (e.g. persisted `/login` on web).
final hasCompletedSplashProvider = StateProvider<bool>((ref) => false);

/// Notifies [GoRouter] when splash completion changes.
final routerRefreshListenableProvider = Provider<RouterRefreshListenable>((ref) {
  final listenable = RouterRefreshListenable();
  ref.onDispose(listenable.dispose);

  ref.listen<bool>(hasCompletedSplashProvider, (_, __) {
    listenable.notify();
  });

  return listenable;
});

final class RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}
