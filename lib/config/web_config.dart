import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Web用のFirebase設定（環境変数から値を読み込む代わりに使用できます）
/// 
/// 注意: この設定はパブリックに公開されても問題のない情報のみを含んでいます。
/// Firebase APIキーはクライアントサイドに公開されても安全なクライアントキーであり、
/// 適切なFirebaseセキュリティルールと組み合わせて使用する必要があります。
class WebFirebaseConfig {
  /// Firebaseコンソールから取得したWeb用の設定を返します。
  /// Firebase Console > プロジェクト設定 > 全般 > マイアプリ > ウェブアプリから
  /// 設定を取得してください。
  static FirebaseOptions get options => const FirebaseOptions(
    // 以下の値は公開しても安全です（適切なFirebaseセキュリティルールと併用する場合）
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    authDomain: 'your-project-id.firebaseapp.com',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    messagingSenderId: '123456789012',
    appId: '1:123456789012:web:a1b2c3d4e5f6a7b8c9d0e1',
  );
}

/// 注意: このファイルをGitなどのバージョン管理システムにコミットする前に、
/// 上記のプレースホルダーを実際のAPIキーやプロジェクトIDなどに置き換えてください。
/// 
/// ただし、これらの情報は公開されても、適切なFirebaseセキュリティルールが
/// 設定されていれば、悪用のリスクは限定的です。
/// 
/// 参考：https://firebase.google.com/docs/projects/api-keys 