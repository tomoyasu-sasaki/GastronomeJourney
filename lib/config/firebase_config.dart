import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/utils/env_helper.dart';
import 'package:gastronomejourney/config/web_config.dart';

/// Firebase設定（環境変数を使用）
class FirebaseConfig {
  static Future<FirebaseOptions> getOptions() async {
    if (kIsWeb) {
      return WebFirebaseConfig.options;
    }

    final envHelper = EnvHelper();
    return FirebaseOptions(
      apiKey: await envHelper.getFirebaseApiKey(),
      appId: await envHelper.getFirebaseAppId(),
      messagingSenderId: await envHelper.getFirebaseMessagingSenderId(),
      projectId: await envHelper.getFirebaseProjectId(),
      storageBucket: await envHelper.getFirebaseStorageBucket(),
      iosClientId: await envHelper.getFirebaseIosClientId(),
      iosBundleId: await envHelper.getFirebaseIosBundleId(),
    );
  }
} 