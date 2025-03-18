import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastronomejourney/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:gastronomejourney/features/auth/domain/models/auth_state.dart';
import 'package:gastronomejourney/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges.map(
    (user) => user != null
        ? AuthState.authenticated(user)
        : const AuthState.unauthenticated(),
  );
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(authRepositoryProvider)),
);

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState.initial());

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signInWithApple();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      state = const AuthState.loading();
      await _repository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      // プロフィール更新後、最新のユーザー情報を取得
      final updatedUser = await _repository.getCurrentUser();
      if (updatedUser != null) {
        state = AuthState.authenticated(updatedUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      state = const AuthState.loading();
      await _repository.sendEmailVerification();
      // メール送信後、最新のユーザー情報を取得
      final updatedUser = await _repository.getCurrentUser();
      if (updatedUser != null) {
        state = AuthState.authenticated(updatedUser);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.sendPasswordResetEmail(email);
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      state = const AuthState.loading();
      await _repository.deleteAccount();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
} 