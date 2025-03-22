import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 環境変数を安全に扱うためのヘルパークラス
class EnvHelper {
  String _getEnvValue(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception('環境変数 $key が設定されていません');
    }
    return value;
  }

  Future<String> getFirebaseApiKey() async {
    return _getEnvValue('FIREBASE_API_KEY');
  }

  Future<String> getFirebaseAppId() async {
    return _getEnvValue('FIREBASE_APP_ID');
  }

  Future<String> getFirebaseMessagingSenderId() async {
    return _getEnvValue('FIREBASE_MESSAGING_SENDER_ID');
  }

  Future<String> getFirebaseProjectId() async {
    return _getEnvValue('FIREBASE_PROJECT_ID');
  }

  Future<String> getFirebaseStorageBucket() async {
    return _getEnvValue('FIREBASE_STORAGE_BUCKET');
  }

  Future<String> getFirebaseIosClientId() async {
    return _getEnvValue('FIREBASE_IOS_CLIENT_ID');
  }

  Future<String> getFirebaseIosBundleId() async {
    return _getEnvValue('FIREBASE_IOS_BUNDLE_ID');
  }

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
      'apiKey': getFirebaseValue('FIREBASE_WEB_API_KEY'),
      'appId': getFirebaseValue('FIREBASE_WEB_APP_ID'),
      'messagingSenderId': getFirebaseValue('FIREBASE_WEB_MESSAGING_SENDER_ID'),
      'projectId': getFirebaseValue('FIREBASE_WEB_PROJECT_ID'),
      'authDomain': getFirebaseValue('FIREBASE_WEB_AUTH_DOMAIN'),
      'storageBucket': getFirebaseValue('FIREBASE_WEB_STORAGE_BUCKET'),
    };
  }

  /// Android用のFirebase設定値を取得
  static Map<String, String> getAndroidConfig() {
    return {
      'apiKey': getFirebaseValue('FIREBASE_ANDROID_API_KEY'),
      'appId': getFirebaseValue('FIREBASE_ANDROID_APP_ID'),
      'messagingSenderId': getFirebaseValue('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
      'projectId': getFirebaseValue('FIREBASE_ANDROID_PROJECT_ID'),
      'storageBucket': getFirebaseValue('FIREBASE_ANDROID_STORAGE_BUCKET'),
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
      'FIREBASE_WEB_API_KEY',
      'FIREBASE_WEB_APP_ID',
      'FIREBASE_WEB_MESSAGING_SENDER_ID',
      'FIREBASE_WEB_PROJECT_ID',
      'FIREBASE_WEB_STORAGE_BUCKET',
    ];

    for (final key in requiredKeys) {
      if (getFirebaseValue(key).isEmpty) {
        return false;
      }
    }
    return true;
  }
} 