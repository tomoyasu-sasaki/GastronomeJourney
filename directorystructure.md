# GastronomeJourney プロジェクトディレクトリ構造

## 現在の構造

```
gastronomejourney/
├── .cursor/                   # Cursor IDEの設定ファイル
├── .dart_tool/                # Dartツールの設定ファイル
├── .gitignore                 # Gitの除外設定ファイル
├── .idea/                     # IntelliJ IDEAの設定ファイル
├── .metadata                  # Flutterのメタデータ
├── analysis_options.yaml      # Dart解析の設定ファイル
├── android/                   # Androidプラットフォーム固有のコード
├── build/                     # ビルド生成物
├── directorystructure.md      # このファイル（ディレクトリ構造の説明）
├── docs/                      # プロジェクトドキュメント
│   ├── GastronomeJourney.md   # プロジェクト概要と要件定義
│   ├── api_specifications.md  # API仕様書
│   ├── branch_strategy_and_release_flow.md # ブランチ戦略とリリースフロー
│   ├── ci_cd_workflow_samples.md # CI/CDワークフローサンプル
│   ├── code_review_checklist.md # コードレビューチェックリスト
│   ├── database_migration_strategy.md # データベースマイグレーション戦略
│   ├── environment_setup_guide.md # 環境セットアップガイド
│   ├── error_handling_specification.md # エラーハンドリング仕様
│   ├── implementation_plan.md # 実装計画
│   ├── performance_benchmark_and_monitoring.md # パフォーマンスベンチマークとモニタリング
│   ├── splash_screen_and_app_icon_guide.md # スプラッシュ画面とアプリアイコンガイド
│   ├── state_management_design.md # 状態管理設計
│   ├── test_specifications.md # テスト仕様
│   ├── ui_design_system_guide.md # UIデザインシステムガイド
│   └── user_story_map.md # ユーザーストーリーマップ
├── gastronomejourney.iml      # IntelliJ IDEAのモジュール設定
├── ios/                       # iOSプラットフォーム固有のコード
├── lib/                       # Dartソースコード
│   └── main.dart              # アプリケーションのエントリーポイント
├── linux/                     # Linuxプラットフォーム固有のコード
├── macos/                     # macOSプラットフォーム固有のコード
├── pubspec.lock               # パッケージ依存関係のロックファイル
├── pubspec.yaml               # パッケージ依存関係と設定
├── README.md                  # プロジェクト説明
├── technologystack.md         # 技術スタックの説明
├── test/                      # テストコード
│   └── widget_test.dart       # ウィジェットテストのサンプル
├── web/                       # Webプラットフォーム固有のコード
└── windows/                   # Windowsプラットフォーム固有のコード
```

## 推奨ディレクトリ構造（実装予定）

```
gastronomejourney/
├── ...                        # 上記の基本ファイル
├── lib/
│   ├── core/                  # アプリ全体で使用する共通コード
│   │   ├── constants/         # 定数
│   │   ├── errors/            # エラー処理
│   │   ├── routes/            # ルーティング設定
│   │   ├── themes/            # テーマ設定
│   │   └── utils/             # ユーティリティ関数
│   ├── data/                  # データレイヤー
│   │   ├── datasources/       # データソース（ローカル、リモート）
│   │   ├── models/            # データモデル
│   │   └── repositories/      # リポジトリの実装
│   ├── domain/                # ドメインレイヤー
│   │   ├── entities/          # ビジネスエンティティ
│   │   ├── repositories/      # リポジトリのインターフェース
│   │   └── usecases/          # ユースケース
│   ├── presentation/          # プレゼンテーションレイヤー
│   │   ├── pages/             # 画面
│   │   │   ├── auth/          # 認証関連の画面
│   │   │   ├── home/          # ホーム画面
│   │   │   ├── izakaya/       # 居酒屋関連の画面
│   │   │   ├── profile/       # プロフィール画面
│   │   │   └── search/        # 検索画面
│   │   ├── providers/         # Riverpodプロバイダー
│   │   └── widgets/           # 共通ウィジェット
│   ├── firebase_options.dart  # Firebaseの設定
│   └── main.dart              # アプリケーションのエントリーポイント
├── assets/                    # アセット（画像、フォントなど）
│   ├── images/                # 画像
│   └── fonts/                 # フォント
└── test/                      # テストコード
    ├── core/                  # コアのテスト
    ├── data/                  # データレイヤーのテスト
    ├── domain/                # ドメインレイヤーのテスト
    └── presentation/          # プレゼンテーションレイヤーのテスト
```

このディレクトリ構造は、プロジェクトの要件に基づいてクリーンアーキテクチャを適用し、責務を明確に分離することで、拡張性と保守性を高める設計になっています。
