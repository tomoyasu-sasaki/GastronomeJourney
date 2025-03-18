# Gastronome Journeyアプリ

## 環境変数の設定

このアプリケーションでは、環境変数を使用して各種APIキーなどの機密情報を管理しています。

### 1. 環境変数ファイルの作成

プロジェクトのルートディレクトリに `.env` ファイルを作成し、以下の環境変数を設定してください：

```
# Firebase設定（モバイルアプリ用）
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_AUTH_DOMAIN=your_auth_domain

# iOS特有の設定
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_BUNDLE_ID=your_ios_bundle_id

# アプリ環境設定
APP_ENV=development  # 'development', 'staging', 'production'
```

### 2. Web版のFirebase設定

Webブラウザ向けの設定は、`lib/config/web_config.dart`ファイル内の直接記述された値を使用します。
このファイルは以下のような形式で、Firebase Consoleから取得した設定値を設定してください：

```dart
static FirebaseOptions get options => const FirebaseOptions(
  apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxx',
  authDomain: 'your-project-id.firebaseapp.com',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
  messagingSenderId: '123456789012',
  appId: '1:123456789012:web:a1b2c3d4e5f6a7b8c9d0e1',
);
```

**注意**: Firebase APIキーはクライアントサイドに公開されても安全なクライアントキーですが、
適切なFirebaseセキュリティルールを併用することをお勧めします。

## アプリの起動

環境変数の設定完了後、以下のコマンドでアプリを起動できます：

```bash
flutter run
```

## セキュリティに関する注意事項

- 環境変数ファイル（`.env`）は絶対にバージョン管理システムにコミットしないでください。
- 適切なFirebaseセキュリティルールを設定して、データへのアクセスを制限してください。
- 本番環境では、`APP_ENV=production`に設定し、デバッグログを最小限に抑えるようにしてください。 