import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:gastronomejourney/features/auth/domain/models/user_model.dart';
import 'package:gastronomejourney/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseAuthRepository implements AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '491162828468-0sqhgn0n7janrduj0e8rvdqrfv86obfl.apps.googleusercontent.com' : null,
    scopes: [
      'email',
      'profile',
    ],
  );

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(), // Firebaseは作成日時を提供していないため、現在時刻を使用
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('サインインに失敗しました');

    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('アカウントの作成に失敗しました');

    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        // TODO: Cross-Origin-Opener-Policy関連の警告を解決する必要があります
        // 以下の点について確認と対応が必要：
        // 1. Firebase Consoleで以下の設定を確認
        //    - Authentication > Sign-in method > 承認済みドメインに`localhost`が追加されているか
        //    - OAuth 2.0クライアントID > 承認済みJavaScriptオリジンに`http://localhost:3000`が追加されているか
        // 2. ポップアップウィンドウの処理方法の見直し
        //    - signInWithPopupの代わりにsignInWithRedirectの使用を検討
        //    - または、Google Identity Servicesの新しいAPIへの移行を検討
        // 3. 開発環境と本番環境での動作の違いを確認
        //    - 開発環境: http://localhost:3000
        //    - 本番環境: https://gastronomejourney.firebaseapp.com
        
        // Webプラットフォームの場合、PopUpベースの認証を使用
        final provider = GoogleAuthProvider();
        
        // カスタムパラメータの設定
        provider.setCustomParameters({
          'prompt': 'select_account',
          'login_hint': '',
          // ローカル開発環境用のリダイレクトドメインを設定
          'redirect_uri': 'http://localhost:3000/__/auth/handler',
        });

        // 認証スコープの追加
        provider.addScope('https://www.googleapis.com/auth/userinfo.email');
        provider.addScope('https://www.googleapis.com/auth/userinfo.profile');

        final userCredential = await _auth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) throw Exception('Googleサインインに失敗しました');

        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'popup-closed-by-user':
            throw Exception('ログインがキャンセルされました');
          case 'web-storage-unsupported':
            throw Exception('このブラウザではサポートされていません');
          case 'operation-not-allowed':
            throw Exception('Googleサインインが有効になっていません。Firebase Consoleで有効にしてください');
          case 'unauthorized-domain':
            throw Exception('このドメインはGoogleサインインの許可リストに登録されていません');
          default:
            throw Exception('Googleサインインに失敗しました: ${e.message}');
        }
      } catch (e) {
        throw Exception('Googleサインインに失敗しました: ${e.toString()}');
      }
    } else {
      // モバイルプラットフォームの場合、従来のGoogleSignInを使用
      try {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) throw Exception('Googleサインインがキャンセルされました');

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        final user = userCredential.user;
        if (user == null) throw Exception('Googleサインインに失敗しました');

        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        throw Exception('Googleサインインに失敗しました: ${e.toString()}');
      }
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final user = userCredential.user;
    if (user == null) throw Exception('Appleサインインに失敗しました');

    // Appleサインインの場合、フルネームは初回サインイン時のみ提供される
    if (appleCredential.givenName != null &&
        appleCredential.familyName != null &&
        user.displayName == null) {
      await user.updateDisplayName(
        '${appleCredential.givenName} ${appleCredential.familyName}',
      );
    }

    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがサインインしていません');

    await user.updateDisplayName(displayName);
    await user.updatePhotoURL(photoURL);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('ユーザーがサインインしていません');

    await user.delete();
  }
} 