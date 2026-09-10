import 'package:hiddify/features/auth/data/auth_repository.dart';
import 'package:hiddify/features/auth/models/auth_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  Future<UserSession?> build() async {
    final repo = await ref.watch(authRepositoryProvider.future);
    if (repo.isAuthenticated) {
      try {
        return await repo.getSession();
      } catch (e) {
        // Token expired or invalid
        await repo.clearTokens();
        return null;
      }
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(authRepositoryProvider.future);
      await repo.login(email: email, password: password);
      return await repo.getSession();
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(authRepositoryProvider.future);
      await repo.register(email: email, password: password, code: code);
      return await repo.getSession();
    });
  }

  Future<void> logout() async {
    final repo = await ref.read(authRepositoryProvider.future);
    await repo.logout();
    state = const AsyncData(null);
  }

  Future<void> refreshSession() async {
    final repo = await ref.read(authRepositoryProvider.future);
    if (repo.isAuthenticated) {
      state = await AsyncValue.guard(() => repo.getSession());
    }
  }
}

@riverpod
class AppConfigNotifier extends _$AppConfigNotifier {
  @override
  Future<AppConfig?> build() async {
    final repo = await ref.watch(authRepositoryProvider.future);
    try {
      return await repo.getAppConfig();
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = await ref.read(authRepositoryProvider.future);
      return await repo.getAppConfig();
    });
  }
}
