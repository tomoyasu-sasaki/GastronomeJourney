# GastronomeJourney 環境構築マニュアル

## 1. 前提条件

### 1.1. 必要なハードウェア
- MacOS、Windows、Linuxのいずれかのコンピュータ
- メモリ: 8GB以上推奨
- ストレージ: 10GB以上の空き容量

### 1.2. サポートOS
- MacOS 10.15 (Catalina) 以上
- Windows 10 (64bit) 以上
- Linux: Ubuntu 18.04 LTS 以上

### 1.3. 必要なアカウント
- Googleアカウント（Firebase管理用）
- GitHubアカウント（ソースコード管理用）
- Apple Developer Program登録（iOSへのデプロイ時のみ）
- Google Play Developer登録（Androidへのデプロイ時のみ）

## 2. 開発環境セットアップ

### 2.1. Flutter SDK のインストール

#### 2.1.1. Flutter SDKのダウンロードとインストール

**MacOS / Linux:**
```bash
# ダウンロードディレクトリに移動
cd ~/development

# Flutterリポジトリのクローン
git clone https://github.com/flutter/flutter.git -b stable

# PATHの設定（~/.zshrc または ~/.bashrc に追加）
export PATH="$PATH:$HOME/development/flutter/bin"

# 設定を反映
source ~/.zshrc  # または source ~/.bashrc

# インストール確認
flutter doctor
```

**Windows:**
1. [Flutter SDKのダウンロードページ](https://docs.flutter.dev/get-started/install/windows)から最新の安定版をダウンロード
2. ダウンロードしたzipファイルを `C:\src\flutter` などの任意のディレクトリに解凍
3. 環境変数PATHに `C:\src\flutter\bin` を追加
4. コマンドプロンプトまたはPowerShellを起動し、以下を実行:
```bash
flutter doctor
```

#### 2.1.2. 必要なプラットフォームSDKのセットアップ

**Android Studio セットアップ:**
1. [Android Studioをダウンロード](https://developer.android.com/studio)してインストール
2. Android Studioを起動し、「SDK Manager」から以下をインストール:
   - Android SDK
   - Android SDK Command-line Tools
   - Android SDK Build-Tools
   - Android Emulator
3. 最新のAndroid SDK Platform（最新の安定版）
4. 環境変数の設定:
   - `ANDROID_HOME` = Android SDKの場所（例: `/Users/username/Library/Android/sdk`）
   - `PATH` に `$ANDROID_HOME/tools` と `$ANDROID_HOME/platform-tools` を追加

**iOS開発環境（MacOSのみ）:**
1. App StoreからXcodeをインストール
2. Xcodeのコマンドラインツールをインストール:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```
3. iOSシミュレータを設定:
```bash
open -a Simulator
```

### 2.2. エディタ/IDEのセットアップ

**Visual Studio Codeの設定:**
1. [VS Codeをダウンロード](https://code.visualstudio.com/)してインストール
2. 以下の拡張機能をインストール:
   - Flutter
   - Dart
   - Flutter Widget Snippets
   - Material Icon Theme
   - Error Lens
   - Git History
   - Firebase Explorer (オプション)

**Android Studioの設定 (代替IDE):**
1. 「Plugins」から以下をインストール:
   - Flutter
   - Dart
2. Flutter/Dartプロジェクトの設定を適用

### 2.3. バージョン管理ツール

**Gitのインストール:**
```bash
# MacOS (Homebrew)
brew install git

# Ubuntu
sudo apt update
sudo apt install git

# Windows
# https://git-scm.com/download/win からダウンロードしてインストール
```

**Git設定の初期化:**
```bash
git config --global user.name "あなたの名前"
git config --global user.email "your.email@example.com"
```

## 3. プロジェクトセットアップ

### 3.1. プロジェクトの作成/クローン

**新規プロジェクト作成:**
```bash
# プロジェクト作成
flutter create --org com.example gastronome_journey
cd gastronome_journey

# AndroidとiOSの最小SDKバージョン設定
# android/app/build.gradle を編集:
# minSdkVersion 21
# targetSdkVersion 33

# ios/Runner/Info.plist を編集:
# MinimumOSVersion の値を "12.0" に設定
```

**既存プロジェクトのクローン:**
```bash
git clone https://github.com/your-organization/gastronome_journey.git
cd gastronome_journey
flutter pub get
```

### 3.2. 必要なパッケージの追加

**pubspec.yamlへの依存関係追加:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  
  # 状態管理
  flutter_riverpod: ^2.3.6
  
  # ルーティング
  go_router: ^7.1.1
  
  # モデル生成
  freezed: ^2.3.5
  freezed_annotation: ^2.2.0
  json_serializable: ^6.7.0
  json_annotation: ^4.8.1
  
  # Firebase
  firebase_core: ^2.13.1
  firebase_auth: ^4.6.2
  cloud_firestore: ^4.8.0
  firebase_storage: ^11.2.2
  firebase_analytics: ^10.4.2
  firebase_crashlytics: ^3.3.2
  
  # UI
  flutter_hooks: ^0.18.6
  google_fonts: ^4.0.4
  cached_network_image: ^3.2.3
  image_picker: ^0.8.7+5
  flutter_image_compress: ^1.1.3
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.1
  build_runner: ^2.4.5
```

**パッケージのインストール:**
```bash
flutter pub get
```

## 4. Firebaseプロジェクトセットアップ

### 4.1. Firebaseプロジェクト作成

1. [Firebase Console](https://console.firebase.google.com/)にアクセス
2. 「プロジェクトを追加」をクリック
3. プロジェクト名として「GastronomeJourney」を入力
4. Google Analyticsを有効化し、設定を完了

### 4.2. Androidアプリの追加設定

1. Firebase Consoleで「Android」アプリを追加
2. Android パッケージ名を入力（例: `com.example.gastronome_journey`）
3. `google-services.json` ファイルをダウンロードし、`android/app/` ディレクトリに配置
4. `android/build.gradle` に以下を追加:
```gradle
buildscript {
  dependencies {
    // ...
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```
5. `android/app/build.gradle` に以下を追加:
```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services'  // Google Services プラグイン
```

### 4.3. iOSアプリの追加設定 (MacOSのみ)

1. Firebase Consoleで「iOS」アプリを追加
2. iOSバンドルIDを入力（例: `com.example.gastronomeJourney`）
3. `GoogleService-Info.plist` ファイルをダウンロードし、Xcodeプロジェクトのルートに追加
   ```bash
   open ios/Runner.xcworkspace
   # Xcodeで右クリック > "Add Files to 'Runner'" から GoogleService-Info.plist を追加
   ```
4. Podfileに必要な依存関係を追加:
   ```ruby
   target 'Runner' do
     # 既存の設定...
     pod 'Firebase/Core'
     pod 'Firebase/Auth'
     pod 'Firebase/Firestore'
     pod 'Firebase/Storage'
     pod 'Firebase/Analytics'
     pod 'Firebase/Crashlytics'
   end
   ```
5. 依存関係をインストール:
   ```bash
   cd ios
   pod install
   cd ..
   ```

### 4.4. Firebaseの初期化コード

**lib/firebase_options.dart**の作成:
```bash
# FlutterFire CLIをインストール
dart pub global activate flutterfire_cli

# Firebaseプロジェクトの構成
flutterfire configure --project=gastronome-journey
```

**lib/main.dart** にFirebaseの初期化コードを追加:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 4.5. Firestore セキュリティルールの設定

Firebase Consoleで以下のセキュリティルールを設定:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザードキュメント
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // 居酒屋ドキュメント
    match /izakayas/{izakayaId} {
      allow read: if resource.data.isPublic == true || 
                    request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // ブックマークドキュメント
    match /bookmarks/{bookmarkId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4.6. Firebase Storageルールの設定

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /izakayas/{izakayaId}/{allPaths=**} {
      allow read: if true;  // 画像は公開可能
      allow write: if request.auth != null && 
                    request.resource.size < 10 * 1024 * 1024 &&
                    request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 5. CI/CD環境の設定 (オプション)

### 5.1. GitHub Actionsの設定

**`.github/workflows/flutter.yml`** ファイルを作成:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze project source
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
```

### 5.2. Firebaseへの自動デプロイ

**Firebase Hostingのセットアップ (Webアプリの場合):**
```bash
# Firebase CLIのインストール
npm install -g firebase-tools

# Firebase CLIでログイン
firebase login

# プロジェクトの初期化
firebase init hosting

# ビルドとデプロイ
flutter build web
firebase deploy --only hosting
```

## 6. 環境変数の設定

### 6.1. 開発/本番環境の切り替え

**lib/config/constants.dart**を作成:
```dart
enum Flavor { development, production }

class AppConfig {
  static Flavor flavor = Flavor.development;
  
  static bool get isDevelopment => flavor == Flavor.development;
  static bool get isProduction => flavor == Flavor.production;
  
  // APIエンドポイント
  static String get apiBaseUrl {
    switch (flavor) {
      case Flavor.development:
        return 'https://dev-api.example.com';
      case Flavor.production:
        return 'https://api.example.com';
    }
  }
  
  // その他の環境固有の設定
  static int get cacheTimeInMinutes {
    switch (flavor) {
      case Flavor.development:
        return 5;
      case Flavor.production:
        return 60;
    }
  }
}
```

### 6.2. 環境変数の安全な管理

**Flutterの環境変数管理:**
1. `.env` ファイルを作成（gitignoreに追加）
   ```
   API_KEY=your_api_key_here
   SOME_OTHER_SECRET=secret_value
   ```

2. `flutter_dotenv` パッケージを追加:
   ```yaml
   dependencies:
     flutter_dotenv: ^5.0.2
   ```

3. `pubspec.yaml` にアセット設定を追加:
   ```yaml
   flutter:
     assets:
       - .env
   ```

4. 初期化と使用:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   Future<void> main() async {
     await dotenv.load(fileName: ".env");
     // 続きの初期化処理
   }

   // 使用方法
   final apiKey = dotenv.env['API_KEY'];
   ```

## 7. トラブルシューティング

### 7.1. よくある問題と解決策

**Flutter関連:**
- **問題**: Flutter SDKが見つからない
  **解決策**: PATH環境変数を確認し、必要に応じて再設定

- **問題**: パッケージの依存関係エラー
  **解決策**: `flutter clean` を実行後、`flutter pub get` を再実行

- **問題**: ビルドエラー
  **解決策**: Gradleのバージョン互換性を確認、`flutter doctor -v` で構成を検証

**Firebase関連:**
- **問題**: Firebase初期化エラー
  **解決策**: `google-services.json` や `GoogleService-Info.plist` の配置を確認

- **問題**: Firestoreアクセス権限エラー
  **解決策**: セキュリティルールを確認し、適切なアクセス権を設定

### 7.2. サポートリソース

- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Firebase ドキュメント](https://firebase.google.com/docs)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub issues](https://github.com/flutter/flutter/issues)
- プロジェクト内部のSlackチャンネル: #gastronome-journey-dev

## 8. 開発環境のベストプラクティス

### 8.1. 推奨設定

- **Visual Studio Code設定:**
  ```json
  {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    },
    "dart.lineLength": 120,
    "[dart]": {
      "editor.rulers": [120],
      "editor.defaultFormatter": "Dart-Code.dart-code"
    }
  }
  ```

- **Android Studio設定:**
  - Code Style > Dart > Line length: 120
  - Editor > General > Auto Import > Add unambiguous imports on the fly: 有効化

### 8.2. コード品質ツール

**analysis_options.yaml** の設定:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - annotate_overrides
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_types_as_parameter_names
    - camel_case_types
    - cancel_subscriptions
    - close_sinks
    - constant_identifier_names
    - control_flow_in_finally
    - empty_constructor_bodies
    - implementation_imports
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - package_names
    - package_prefixed_library_names
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_typing_uninitialized_variables
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_brace_in_string_interps
    - unnecessary_getters_setters
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_statements
    - unrelated_type_equality_checks

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    must_be_immutable: error
    sort_unnamed_constructors_first: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

## 9. デモデータとテスト用アカウント

### 9.1. テスト用Firebase認証アカウント

- 開発環境用:
  - Email: `dev@gastronome-journey.com`
  - パスワード: `DevPassword123`

- テスト用ユーザー:
  - Email: `test.user@example.com`
  - パスワード: `TestUser123`

### 9.2. サンプルデータの投入方法

Firestoreにサンプルデータを投入するスクリプト:

```dart
// tools/sample_data_generator.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await generateSampleData();
}

Future<void> generateSampleData() async {
  final firestore = FirebaseFirestore.instance;
  
  // サンプルユーザーの作成
  await firestore.collection('users').doc('sample_user_id').set({
    'displayName': 'サンプルユーザー',
    'email': 'sample@example.com',
    'photoURL': 'https://example.com/profile.jpg',
    'createdAt': FieldValue.serverTimestamp(),
  });
  
  // サンプルの居酒屋データを作成
  await firestore.collection('izakayas').add({
    'name': '居酒屋サンプル',
    'address': '東京都渋谷区道玄坂1-1-1',
    'phone': '03-1234-5678',
    'businessHours': '17:00-23:00',
    'holidays': '月曜日',
    'budget': 3000,
    'genre': '和食',
    'images': ['https://example.com/sample1.jpg', 'https://example.com/sample2.jpg'],
    'isPublic': true,
    'userId': 'sample_user_id',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
```

実行方法:
```bash
dart tools/sample_data_generator.dart
``` 