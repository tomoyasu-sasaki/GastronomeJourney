import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Web用のFirebase設定
/// 環境変数から設定を読み込みます
class WebFirebaseConfig {
  /// Firebaseコンソールから取得したWeb用の設定を返します。
  /// 環境変数から値を読み込みます。
  static FirebaseOptions get options => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '',
    projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
    storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '',
    messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
    appId: dotenv.env['FIREBASE_APP_ID'] ?? '',
  );
}

/// 注意: このファイルをGitなどのバージョン管理システムにコミットする前に、
/// 上記のプレースホルダーを実際のAPIキーやプロジェクトIDなどに置き換えてください。
/// 
/// ただし、これらの情報は公開されても、適切なFirebaseセキュリティルールが
/// 設定されていれば、悪用のリスクは限定的です。
/// 
/// 参考：https://firebase.google.com/docs/projects/api-keys 