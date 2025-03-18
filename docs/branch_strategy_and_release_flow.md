# GastronomeJourney ブランチ戦略とリリースフロー

## 1. 概要

このドキュメントでは、GastronomeJourneyアプリケーションの開発、テスト、デプロイのためのブランチ戦略とリリースフローについて詳細に説明します。統一されたアプローチを採用することで、コードの品質を維持し、効率的な開発プロセスを確保します。

## 2. ブランチ戦略

GastronomeJourneyプロジェクトでは、GitFlow（拡張版）をベースとしたブランチ戦略を採用します。

### 2.1. ブランチの種類

| ブランチ種別 | 命名規則 | 説明 | 派生元 | マージ先 |
|------------|---------|------|---------|---------|
| `main` | `main` | 本番環境にリリースされるコード | - | - |
| `develop` | `develop` | 開発環境の最新コード | `main` | `main` |
| 機能ブランチ | `feature/[JIRA-ID]-[機能名]` | 新機能の開発 | `develop` | `develop` |
| バグ修正ブランチ | `bugfix/[JIRA-ID]-[バグ内容]` | バグの修正 | `develop` | `develop` |
| ホットフィックスブランチ | `hotfix/[JIRA-ID]-[修正内容]` | 本番環境のクリティカルな修正 | `main` | `main`と`develop` |
| リリースブランチ | `release/v[バージョン]` | リリース準備 | `develop` | `main`と`develop` |

### 2.2. ブランチライフサイクル

#### 2.2.1. 機能開発ブランチ

1. `develop`ブランチから`feature/[JIRA-ID]-[機能名]`ブランチを作成
2. 機能開発を実装
3. 機能が完成したら、`develop`ブランチへプルリクエストを作成
4. コードレビュー、自動テスト通過後にマージ
5. マージ後、feature ブランチは削除

```bash
# 機能ブランチの作成例
git checkout develop
git pull
git checkout -b feature/GJ-123-izakaya-search-filter
```

#### 2.2.2. バグ修正ブランチ

1. `develop`ブランチから`bugfix/[JIRA-ID]-[バグ内容]`ブランチを作成
2. バグ修正を実装
3. 修正が完成したら、`develop`ブランチへプルリクエストを作成
4. コードレビュー、自動テスト通過後にマージ
5. マージ後、bugfix ブランチは削除

```bash
# バグ修正ブランチの作成例
git checkout develop
git pull
git checkout -b bugfix/GJ-456-rating-calculation-fix
```

#### 2.2.3. リリースブランチ

1. リリース準備が整ったら、`develop`ブランチから`release/v[バージョン]`ブランチを作成
2. リリース準備（バージョン番号更新、最終テスト、ドキュメント更新など）
3. 準備が完了したら、`main`ブランチと`develop`ブランチへのプルリクエストを作成
4. 最終レビュー後、まず`main`へマージ
5. `main`へのマージ後、Gitタグを作成
6. その後、`develop`へもマージ
7. マージ後、release ブランチは削除

```bash
# リリースブランチの作成例
git checkout develop
git pull
git checkout -b release/v1.2.0

# バージョン番号更新後のコミット例
git commit -am "Bump version to 1.2.0"

# リリース後のタグ作成例
git checkout main
git pull
git tag -a v1.2.0 -m "Version 1.2.0"
git push origin v1.2.0
```

#### 2.2.4. ホットフィックスブランチ

1. 本番環境で緊急のバグが発見された場合、`main`ブランチから`hotfix/[JIRA-ID]-[修正内容]`ブランチを作成
2. 修正を実装
3. 修正が完了したら、`main`ブランチと`develop`ブランチへのプルリクエストを作成
4. コードレビュー後、まず`main`へマージ
5. `main`へのマージ後、マイナーバージョンを上げたGitタグを作成
6. その後、`develop`へもマージ
7. マージ後、hotfix ブランチは削除

```bash
# ホットフィックスブランチの作成例
git checkout main
git pull
git checkout -b hotfix/GJ-789-critical-auth-fix

# バージョン番号更新後のコミット例
git commit -am "Bump version to 1.2.1"

# ホットフィックス後のタグ作成例
git checkout main
git pull
git tag -a v1.2.1 -m "Hotfix: Critical auth issue fixed"
git push origin v1.2.1
```

### 2.3. ブランチ保護ルール

リポジトリには以下のブランチ保護ルールを設定します：

#### 2.3.1. `main`ブランチ

- 直接プッシュ禁止
- プルリクエストには最低1人のレビュー承認が必要
- すべてのステータスチェック（CI/CD）の通過が必要
- マージ後にブランチを自動的に削除しない

#### 2.3.2. `develop`ブランチ

- 直接プッシュ禁止
- プルリクエストには最低1人のレビュー承認が必要
- すべてのステータスチェック（CI/CD）の通過が必要
- マージ後にブランチを自動的に削除する設定を推奨

### 2.4. コミットメッセージ規約

コミットメッセージは以下の形式に従ってください：

```
[タイプ]: [簡潔な説明]

[詳細な説明（必要な場合）]

[関連するJIRAチケット]
```

#### タイプの例:

- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響を与えない変更（スペース、フォーマット等）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンス向上のための変更
- `test`: テストの追加・修正
- `chore`: ビルドプロセスやツール、設定の変更

例:
```
feat: 居酒屋検索フィルター機能を追加

- 地域によるフィルタリング
- 予算範囲によるフィルタリング
- 営業時間によるフィルタリング

GJ-123
```

## 3. 環境構成

GastronomeJourneyでは、以下の環境を設定します：

### 3.1. 環境の種類

| 環境 | 目的 | URL | Firebase プロジェクト |
|-----|------|-----|----------------------|
| 開発環境（Dev） | 開発者が日々の作業を確認 | dev.gastronomejourney.com | gastronome-journey-dev |
| テスト環境（Staging） | QAテスト、受け入れテスト | staging.gastronomejourney.com | gastronome-journey-staging |
| 本番環境（Production） | エンドユーザー向け | gastronomejourney.com | gastronome-journey-prod |

### 3.2. 環境ごとの構成管理

各環境では、以下の点が異なります：

- Firebase プロジェクト接続情報
- API エンドポイント
- ロギングレベル
- 機能フラグ（Feature Flags）

環境ごとの設定は`.env`ファイルで管理し、ビルド時に適切な設定が使用されるようにします。

```dart
// 環境変数を読み込むユーティリティクラス例
class Environment {
  static const String apiUrl = String.fromEnvironment('API_URL', 
    defaultValue: 'https://api.dev.gastronomejourney.com');
  
  static const String environment = String.fromEnvironment('ENVIRONMENT', 
    defaultValue: 'development');
  
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development';
  
  static LogLevel get logLevel {
    if (isProduction) return LogLevel.error;
    if (isStaging) return LogLevel.warning;
    return LogLevel.verbose;
  }
}
```

### 3.3. 環境ごとのアプリ識別

各環境のアプリは一目で識別できるようにします：

- 開発環境: アプリ名に「(Dev)」のサフィックス、異なるアプリアイコン（赤色ベース）
- テスト環境: アプリ名に「(Staging)」のサフィックス、異なるアプリアイコン（黄色ベース）
- 本番環境: 通常のアプリ名とアイコン

## 4. リリースフロー

### 4.1. リリースサイクル

GastronomeJourneyでは、2週間ごとのスプリントサイクルに合わせたリリースフローを採用します。

#### 4.1.1. 通常リリーススケジュール

1. スプリント終了の2日前: リリースブランチ作成
2. スプリント終了の1日前: QAテスト完了
3. スプリント終了日: リリース承認とデプロイ
4. 次のスプリント開始日: ポストリリースレビュー

#### 4.1.2. ホットフィックスリリース

緊急の修正が必要な場合は、スケジュールに関係なくホットフィックスリリースを実施します。

### 4.2. リリース準備プロセス

1. `develop`ブランチから`release/v[バージョン]`を作成
2. リリースブランチで以下の作業を実施:
   - `pubspec.yaml`のバージョン番号更新
   - リリースノート作成
   - 残っている小さなバグ修正
3. リリースブランチをテスト環境にデプロイし、QAテスト実施
4. テスト結果に基づく修正を行い、再テスト

### 4.3. リリース実行プロセス

1. QAテスト合格後、リリースブランチから`main`ブランチへのプルリクエスト作成
2. プルリクエストのレビューと承認
3. `main`ブランチへのマージ
4. リリースタグの作成（例: `v1.2.0`）
5. CIパイプラインによる本番ビルド生成
6. 本番環境へのデプロイ
   - Firebase App Distributionを利用した内部テスト配布
   - App StoreとGoogle Playへの提出
7. リリースブランチから`develop`ブランチへのマージ

### 4.4. リリース後のモニタリング

1. Firebase CrashlyticsとFirebase Performanceによるモニタリング
2. ユーザーフィードバックの監視
3. 重大な問題が発見された場合のロールバックプランの発動
4. リリース後24時間と72時間の健全性チェック

## 5. バージョニング戦略

GastronomeJourneyでは、セマンティックバージョニング（SemVer）を採用します。

### 5.1. バージョン番号の構成

バージョン番号は `X.Y.Z` の形式で、以下を表します：

- X = メジャーバージョン（互換性のない変更を含む場合に増加）
- Y = マイナーバージョン（後方互換性を維持した機能追加の場合に増加）
- Z = パッチバージョン（バグ修正の場合に増加）

### 5.2. バージョン管理例

- 初期リリース: `1.0.0`
- 新機能追加: `1.1.0`
- バグ修正: `1.1.1`
- ホットフィックス: `1.1.2`
- 大規模なUI刷新や破壊的変更: `2.0.0`

### 5.3. バージョンコードの管理

Android用のバージョンコードは、以下の形式で自動生成します：

```
[メジャー][マイナー][パッチ][ビルド番号]
```

例えば、バージョン `1.2.3` でビルド番号が `45` の場合、バージョンコードは `1020345` となります。

## 6. CI/CDパイプライン

GastronomeJourneyでは、GitHub Actionsを使用したCI/CDパイプラインを実装します。

### 6.1. 継続的インテグレーション（CI）

以下のタスクが各プルリクエスト時に自動的に実行されます：

1. コードのビルド検証
2. 静的コード解析（`flutter analyze`）
3. 単体テスト（`flutter test`）
4. Widget テスト
5. コードカバレッジレポート生成

### 6.2. 継続的デリバリー（CD）

以下のタスクがブランチへのマージ時に自動的に実行されます：

#### 6.2.1. `develop`ブランチへのマージ時

1. 開発環境用のビルド生成
2. Firebase App Distributionへのアップロード
3. Firebase Hostingへのデプロイ（Webアプリの場合）

#### 6.2.2. リリースブランチ作成時

1. テスト環境用のビルド生成
2. Firebase App Distributionへのアップロード
3. Firebase Hostingへのデプロイ（Webアプリの場合）

#### 6.2.3. `main`ブランチへのマージ時

1. 本番環境用のビルド生成
2. Firebase App Distributionへの内部テスト版アップロード
3. App StoreとGoogle Play Consoleへの自動提出設定（リリース承認は手動）

### 6.3. GitHub Actionsのワークフロー例

```yaml
# .github/workflows/ci.yml
name: Flutter CI

on:
  push:
    branches: [ develop, main ]
  pull_request:
    branches: [ develop, main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed .
      - name: Analyze project source
        run: flutter analyze
      - name: Run tests
        run: flutter test --coverage
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## 7. リリースノート作成ガイドライン

リリースノートは、以下の情報を含めるようにします：

### 7.1. リリースノートの構成

1. **バージョン番号と日付**
2. **新機能**: ユーザーが利用できる新しい機能
3. **改善点**: 既存機能の改善
4. **バグ修正**: 修正されたバグ
5. **変更点**: 動作が変わった部分
6. **既知の問題**: 認識されているが未解決の問題

### 7.2. リリースノートの例

```
# GastronomeJourney v1.2.0 (2023年4月1日)

## 新機能
- 居酒屋検索時にフィルター機能を追加しました
- プロフィール画面でお気に入りの居酒屋を表示できるようになりました

## 改善点
- 地図表示のパフォーマンスを向上させました
- UI全体の応答性を改善しました

## バグ修正
- 一部のAndroidデバイスで画像が正しく表示されない問題を修正
- ログアウト後に履歴が残る問題を解決

## 変更点
- 居酒屋詳細画面のレイアウトを刷新しました

## 既知の問題
- タブレット向けのレイアウト最適化は次回リリースで対応予定です
```

## 8. 展開戦略

### 8.1. フェーズドロールアウト

本番環境へのリリースは、段階的に行います：

1. 内部テスター（開発・QAチーム）: 100%
2. クローズドベータテスター: 20% → 50% → 100%
3. オープンベータユーザー: 5% → 20% → 50% → 100%
4. 全ユーザー: 10% → 25% → 50% → 100%

各段階でクラッシュ率や重大な問題がないことを確認してから次の段階に進みます。

### 8.2. フィーチャーフラグ

一部の新機能は、フィーチャーフラグを使って段階的に有効化します：

```dart
// フィーチャーフラグの例
class FeatureFlags {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  
  static bool get isNewSearchEnabled => 
    _remoteConfig.getBool('enable_new_search_interface');
  
  static bool get isRealtimeChatEnabled => 
    _remoteConfig.getBool('enable_realtime_chat');
    
  static Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      'enable_new_search_interface': false,
      'enable_realtime_chat': false,
    });
    await _remoteConfig.fetchAndActivate();
  }
}
```

### 8.3. A/Bテスト

特定の機能や設計変更については、A/Bテストを実施して効果を測定します：

1. Firebase A/B Testingを設定
2. ユーザーを複数のグループに分割
3. 各グループに異なるバージョンの機能を提供
4. コンバージョン率やエンゲージメント指標を比較
5. データに基づいて最終的な実装を決定

## 9. 緊急時のロールバック手順

### 9.1. App Store/Google Playでのロールバック

1. コンソールにログインし、リリースを停止
2. 前のバージョンへのロールバックを指示
3. 開発チームに通知

### 9.2. Firebase関連のロールバック

1. Firebase Consoleでリモート設定値を以前の安定した値に戻す
2. Firestoreセキュリティルールを前バージョンにロールバック
3. Cloud Functionsを前バージョンにロールバック

### 9.3. 再リリース手順

1. 問題の原因を特定
2. ホットフィックスブランチで修正
3. 緊急レビューと承認
4. 緊急ビルドと配布

## 10. リリース責任者の役割と責任

リリース責任者は以下の責任を負います：

1. リリーススケジュールの管理
2. リリース準備状況の確認
3. リリースGo/No-Goの判断
4. リリースノートの最終承認
5. リリース実行の監督
6. リリース後のモニタリング統括
7. 問題発生時の対応指示

## 11. 更新履歴

| 日付 | バージョン | 変更内容 | 担当者 |
|-----|-----------|---------|-------|
| 2023-XX-XX | 1.0 | 初版作成 | XXX | 