# GastronomeJourney 技術スタック

## 開発環境

- **言語**: Dart 3.3.x
- **SDK**: Flutter 3.19.x
- **開発環境**: 
  - Android Studio / Visual Studio Code
  - Xcode (iOSビルド用)
  - Flutter DevTools

## フロントエンド

### フレームワークとUI
- **プラットフォーム**: Flutter（クロスプラットフォーム開発）
  - Android
  - iOS
  - (オプション) Web サポート
- **UIデザイン**: 
  - Material Design 3
  - Flutter Widgets
  - レスポンシブデザイン対応

### 状態管理
- **主要状態管理**: 
  - Riverpod 2.x
  - StateNotifier
- **ローカルデータ管理**:
  - SharedPreferences
  - flutter_secure_storage (認証情報などセキュアなデータ向け)

### ルーティング
- **画面遷移**: 
  - go_router
  - 宣言的ルーティング

### アセット管理
- **画像・リソース**: 
  - flutter_gen (アセットの型安全な利用)
  - SVG サポート

### UI コンポーネント
- **カスタムウィジェット**: 
  - 再利用可能なコンポーネント設計
  - アニメーション対応ウィジェット
- **フォーム管理**:
  - flutter_form_builder
  - form_validators

### 多言語対応
- **国際化**: 
  - flutter_localizations
  - intl パッケージ

## バックエンド (Firebase)

### 認証
- **Firebase Authentication**:
  - Eメール・パスワード認証
  - Google/Apple Sign-In
  - 匿名認証

### データベース
- **Cloud Firestore**:
  - NoSQLデータベース
  - リアルタイムデータ同期
  - オフラインデータ対応

### ストレージ
- **Firebase Storage**:
  - 画像保存
  - マルチメディアコンテンツ管理

### バックエンドロジック
- **Firebase Cloud Functions**:
  - サーバーレスバックエンド処理
  - トリガーベースの処理
  - APIエンドポイント

### プッシュ通知
- **Firebase Cloud Messaging**:
  - クロスプラットフォームプッシュ通知

### アナリティクス & モニタリング
- **Firebase Analytics**:
  - ユーザー行動分析
- **Firebase Crashlytics**:
  - クラッシュレポート
  - エラー追跡
- **Firebase Performance Monitoring**:
  - パフォーマンス測定
  - ボトルネック特定

## 開発運用ツール

### バージョン管理
- **Git**:
  - GitHub / GitLab リポジトリ
  - ブランチ戦略（Gitflow）

### CI/CD
- **Firebase App Distribution**:
  - テスト版配布
- **Codemagic / GitHub Actions**:
  - 自動ビルド
  - 自動テスト
  - デプロイメント自動化

### テスト
- **ユニットテスト**:
  - flutter_test パッケージ
  - mockito
- **ウィジェットテスト**:
  - flutter_test
  - integration_test
- **UIテスト**:
  - integration_test
  - flutter_driver

### コード品質
- **静的解析**:
  - flutter_lints
  - custom lint rules
- **コードフォーマット**:
  - dart format

## セキュリティ

- **データ暗号化**:
  - Firebase Security Rules
  - flutter_secure_storage
- **認証フロー**:
  - JWT トークン管理
  - 安全な認証状態維持
- **セキュリティテスト**:
  - 脆弱性スキャン
  - ペネトレーションテスト

## 拡張予定機能用技術

- **地図機能**:
  - google_maps_flutter
  - geolocator
- **SNS連携**:
  - flutter_social_share
  - url_launcher
- **画像処理・編集**:
  - image_picker
  - image_cropper
  - photo_view

このスタックは、プロジェクト要件に基づいて選定されており、変更される可能性があります。特にセキュリティとパフォーマンスを重視し、ユーザー体験の向上を目指します。
