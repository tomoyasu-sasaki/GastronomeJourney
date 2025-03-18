import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数を安全に扱うためのヘルパークラス
class EnvHelper {
  /// Firebaseの構成値を安全に取得
  static String getFirebaseValue(String key, {String defaultValue = ''}) {
    try {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        return defaultValue;
      }
      return value;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Web用のFirebase設定値を取得
  static Map<String, String> getWebConfig() {
    return {
      'apiKey': getFirebaseValue('FIREBASE_API_KEY'),
      'appId': getFirebaseValue('FIREBASE_APP_ID'),
      'messagingSenderId': getFirebaseValue('FIREBASE_MESSAGING_SENDER_ID'),
      'projectId': getFirebaseValue('FIREBASE_PROJECT_ID'),
      'authDomain': getFirebaseValue('FIREBASE_AUTH_DOMAIN'),
      'storageBucket': getFirebaseValue('FIREBASE_STORAGE_BUCKET'),
    };
  }

  /// Android用のFirebase設定値を取得
  static Map<String, String> getAndroidConfig() {
    return {
      'apiKey': getFirebaseValue('FIREBASE_API_KEY'),
      'appId': getFirebaseValue('FIREBASE_APP_ID'),
      'messagingSenderId': getFirebaseValue('FIREBASE_MESSAGING_SENDER_ID'),
      'projectId': getFirebaseValue('FIREBASE_PROJECT_ID'),
      'storageBucket': getFirebaseValue('FIREBASE_STORAGE_BUCKET'),
    };
  }

  /// iOS用のFirebase設定値を取得
  static Map<String, String> getIOSConfig() {
    return {
      'apiKey': getFirebaseValue('FIREBASE_IOS_API_KEY'),
      'appId': getFirebaseValue('FIREBASE_IOS_APP_ID'),
      'messagingSenderId': getFirebaseValue('FIREBASE_MESSAGING_SENDER_ID'),
      'projectId': getFirebaseValue('FIREBASE_PROJECT_ID'),
      'storageBucket': getFirebaseValue('FIREBASE_STORAGE_BUCKET'),
      'iosBundleId': getFirebaseValue('FIREBASE_IOS_BUNDLE_ID'),
    };
  }

  /// アプリの環境設定を取得
  static String getAppEnvironment() {
    return getFirebaseValue('APP_ENV', defaultValue: 'development');
  }

  /// 環境変数が正しく設定されているかチェック
  static bool validateFirebaseConfig() {
    final requiredKeys = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_MESSAGING_SENDER_ID',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_STORAGE_BUCKET',
    ];

    for (final key in requiredKeys) {
      if (getFirebaseValue(key).isEmpty) {
        return false;
      }
    }
    return true;
  }
} 