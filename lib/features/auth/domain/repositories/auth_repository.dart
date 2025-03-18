import 'package:gastronomejourney/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  });
  
  Future<UserModel> signInWithGoogle();
  
  Future<UserModel> signInWithApple();
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  });
  
  Future<void> sendEmailVerification();
  
  Future<UserModel?> getCurrentUser();
  
  Future<void> deleteAccount();
} 