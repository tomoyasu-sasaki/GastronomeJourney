import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import '../core/utils/env_helper.dart';

/// Firebase設定（環境変数を使用）
class FirebaseConfig {
  static FirebaseOptions get webOptions {
    final config = EnvHelper.getWebConfig();
    return FirebaseOptions(
      apiKey: config['apiKey'] ?? '',
      appId: config['appId'] ?? '',
      messagingSenderId: config['messagingSenderId'] ?? '',
      projectId: config['projectId'] ?? '',
      authDomain: config['authDomain'] ?? '',
      storageBucket: config['storageBucket'] ?? '',
    );
  }

  static FirebaseOptions get androidOptions {
    final config = EnvHelper.getAndroidConfig();
    return FirebaseOptions(
      apiKey: config['apiKey'] ?? '',
      appId: config['appId'] ?? '',
      messagingSenderId: config['messagingSenderId'] ?? '',
      projectId: config['projectId'] ?? '',
      storageBucket: config['storageBucket'] ?? '',
    );
  }

  static FirebaseOptions get iosOptions {
    final config = EnvHelper.getIOSConfig();
    return FirebaseOptions(
      apiKey: config['apiKey'] ?? '',
      appId: config['appId'] ?? '',
      messagingSenderId: config['messagingSenderId'] ?? '',
      projectId: config['projectId'] ?? '',
      storageBucket: config['storageBucket'] ?? '',
      iosBundleId: config['iosBundleId'] ?? '',
    );
  }

  static FirebaseOptions get currentPlatformOptions {
    if (kIsWeb) {
      return webOptions;
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidOptions;
      case TargetPlatform.iOS:
        return iosOptions;
      default:
        return androidOptions; // デフォルトとしてAndroid設定を返す
    }
  }
} 