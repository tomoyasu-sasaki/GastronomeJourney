# GastronomeJourney 実装計画書

## 1. プロジェクト構成

### 1.1. 技術スタック
- **フロントエンド:**
  - Flutter 3.19.0以上
  - flutter_riverpod: 状態管理（主要な状態管理ライブラリとして採用）
  - go_router: ルーティング
  - freezed: イミュータブルなモデルクラス生成
  - json_serializable: JSONシリアライズ
  - flutter_hooks: 関数型UIコンポーネント
  - material_design_icons_flutter: Material Design 3アイコン

- **バックエンド (Firebase):**
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
  - Firebase Cloud Functions
  - Firebase Analytics
  - Firebase Crashlytics

### 1.2. プロジェクトディレクトリ構成
```
lib/
├── app.dart
├── main.dart
├── config/
│   ├── router.dart
│   ├── theme.dart      # Material Design 3テーマ設定
│   └── constants.dart
├── features/
│   ├── auth/
│   │   ├── data/       # リポジトリ実装
│   │   ├── domain/     # モデル、インターフェース
│   │   └── presentation/ # UI、Provider
│   ├── izakaya/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── search/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── core/
│   ├── models/
│   ├── repositories/
│   ├── services/
│   └── utils/
└── shared/
    ├── widgets/        # 共通UI要素
    └── extensions/
```

## 2. データモデル設計

### 2.1. Firestoreコレクション構造
```
users/
  ├── uid
  │   ├── displayName: String
  │   ├── email: String
  │   ├── photoURL: String
  │   └── createdAt: Timestamp

izakayas/
  ├── izakayaId
  │   ├── name: String
  │   ├── address: String
  │   ├── phone: String
  │   ├── businessHours: String
  │   ├── holidays: String
  │   ├── budget: Number
  │   ├── genre: String
  │   ├── images: Array<String>
  │   ├── isPublic: Boolean
  │   ├── userId: String
  │   ├── createdAt: Timestamp
  │   └── updatedAt: Timestamp

bookmarks/
  ├── bookmarkId
  │   ├── userId: String
  │   ├── izakayaId: String
  │   └── createdAt: Timestamp
```

## 3. 機能実装計画

### 3.0. 実装優先順位
本プロジェクトではMVP（Minimum Viable Product）開発アプローチを採用し、以下の優先順位で実装を進める：

1. **最優先機能（MVP）**:
   - 認証機能
   - 居酒屋情報登録・表示機能
   - 基本的な画像アップロード機能
   - 公開/非公開設定

2. **第2優先機能**:
   - 検索・フィルタリング機能
   - 気になるリスト機能

3. **第3優先機能**:
   - UIの洗練
   - パフォーマンス最適化

この優先順位に従って、フェーズ分けした実装を進める。

### 3.1. 認証機能 (Phase 1: 2週間)
- [x] Firebase Auth設定
- [x] サインアップ画面実装
- [x] ログイン画面実装
- [x] パスワードリセット機能
- [x] SNS認証（Google, Apple）
- [x] ユーザープロフィール管理

### 3.2. 居酒屋情報管理 (Phase 1: 3週間)
- [ ] 居酒屋情報入力フォーム
- [ ] 画像アップロード機能
  - [ ] 複数画像選択
  - [ ] 画像圧縮処理
  - [ ] Firebase Storage連携
- [ ] 公開設定切り替え
- [ ] バリデーション実装
- [ ] 編集・削除機能

### 3.3. 検索・フィルタリング (Phase 2: 2週間)
- [ ] キーワード検索実装
- [ ] ジャンルフィルター
- [ ] 検索結果の並び替え
- [ ] 検索履歴管理
- [ ] 検索結果のキャッシュ

### 3.4. 気になるリスト機能 (Phase 2: 1週間)
- [ ] ブックマーク追加/削除
- [ ] ブックマーク一覧表示
- [ ] ブックマーク同期処理

### 3.5. UI/UXの実装 (Phase 3: 2週間)
- [ ] Material Design 3に基づいたカスタムテーマ設定
  - [ ] ダイナミックカラー対応
  - [ ] ダーク/ライトモード対応
  - [ ] カスタムコンポーネント作成
- [ ] アニメーション実装
- [ ] エラーハンドリング
- [ ] ローディング表示
- [ ] プレースホルダー実装

## 4. テスト計画

### 4.1. ユニットテスト
- [ ] モデルクラステスト
- [ ] リポジトリテスト
- [ ] ビジネスロジックテスト

### 4.2. ウィジェットテスト
- [ ] 各画面のウィジェットテスト
- [ ] ナビゲーションテスト
- [ ] フォームバリデーションテスト

### 4.3. インテグレーションテスト
- [ ] Firebase認証テスト
- [ ] Firestoreデータ操作テスト
- [ ] ストレージ操作テスト

## 5. セキュリティ実装

### 5.1. Firebaseセキュリティルール
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

## 6. パフォーマンス最適化

### 6.1. データ取得の最適化
- [ ] ページネーション実装
- [ ] インデックス設定
- [ ] キャッシュ戦略実装

### 6.2. 画像最適化
- [ ] 画像圧縮パラメータ設定
- [ ] プログレッシブ画像ロード
- [ ] キャッシュ制御

## 7. デプロイメント計画

### 7.1. CI/CD設定
- [ ] GitHub Actions設定
- [ ] ビルド自動化
- [ ] テスト自動実行
- [ ] Firebase自動デプロイ

### 7.2. モニタリング設定
- [ ] Firebase Analytics設定
- [ ] Crashlytics設定
- [ ] パフォーマンスモニタリング
- [ ] エラーレポート通知

## 8. マイルストーン

1. **準備フェーズ (1週間)**
   - プロジェクト設定
   - Firebase設定
   - ベース実装（ルーティング、テーマ設定）

2. **MVP実装 (5週間)**
   - 認証機能（2週間）
   - 居酒屋情報管理（3週間）
   - 基本的な公開/非公開機能

3. **追加機能実装 (3週間)**
   - 検索・フィルタリング（2週間）
   - 気になるリスト機能（1週間）

4. **UI改善フェーズ (2週間)**
   - Material Design 3の適用強化
   - アニメーション・トランジション改善
   - レスポンシブ対応強化

5. **テストフェーズ (2週間)**
   - 結合テスト
   - UIテスト
   - パフォーマンステスト

6. **最終フェーズ (1週間)**
   - バグ修正
   - ドキュメント整備
   - ストア申請準備

## 9. 開発ガイドライン

### 9.1. コーディング規約
- Effective Dartに準拠
  - **Style Guide**: 読みやすく一貫性のあるコードスタイル
  - **Documentation Guide**: 効果的なDartdocコメント
  - **Usage Guide**: Dart言語機能の使用方法
  - **Design Guide**: 適切なAPIデザイン
- コメント必須（公開メソッド、複雑なロジック）
- 命名規則の統一
- 最大行長120文字

### 9.2. 詳細なコーディング規則

#### 9.2.1. 命名規則
- **クラス名**: UpperCamelCase（例: `IzakayaRepository`, `AuthService`）
- **メソッド名・変数名**: lowerCamelCase（例: `fetchIzakaya()`, `userProfile`）
- **定数**: lowerCamelCase（例: `maxImageSize`）
  - グローバル定数は`k`プレフィックス（例: `kDefaultTimeout`）
- **プライベートメンバー**: 先頭にアンダースコア（例: `_privateMethod()`, `_internalState`）
- **列挙型**: UpperCamelCase、値はlowerCamelCase（例: `enum IzakayaType { japanese, chinese }`）
- **拡張メソッド**: 目的を明確にした名前（例: `extension StringUtils on String`）

#### 9.2.2. ファイル命名規則
- **すべてのファイル名**: snake_case（例: `izakaya_repository.dart`）
- **Widget**: `<名前>_screen.dart`または`<名前>_widget.dart`（例: `login_screen.dart`, `custom_button_widget.dart`）
- **モデル**: `<名前>_model.dart`（例: `izakaya_model.dart`）
- **リポジトリ**: `<名前>_repository.dart`（例: `user_repository.dart`）
- **プロバイダー**: `<名前>_provider.dart`（例: `auth_provider.dart`）
- **Mixin**: `<名前>_mixin.dart`（例: `validation_mixin.dart`）
- **ユーティリティ**: `<名前>_utils.dart`（例: `string_utils.dart`）
- **拡張機能**: `<名前>_extension.dart`（例: `datetime_extension.dart`）

### 9.3. アーキテクチャパターン

#### 9.3.1. 責任分離原則
- **モデル層**（`/core/models/`）: データ構造の定義のみを担当
- **リポジトリ層**（`/core/repositories/`）: データの取得・保存ロジックを担当
- **サービス層**（`/core/services/`）: ビジネスロジックを担当
- **プレゼンテーション層**（`/features/<機能>/`）: UIとユーザー操作を担当

#### 9.3.2. 依存性注入
- Riverpodを使用した依存性注入
- インターフェース（抽象クラス）を活用した疎結合設計
- テスト可能性を考慮したコンポーネント設計

### 9.4. Riverpod使用ガイドライン

#### 9.4.1. Providerの種類と使い分け
- **Provider**: 単純な値や計算結果の提供（例: `final themeProvider = Provider((ref) => AppTheme())`）
- **StateProvider**: 単純な状態管理（例: `final counterProvider = StateProvider((ref) => 0)`）
- **StateNotifierProvider**: 複雑な状態管理（例: `final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref))`）
- **FutureProvider**: 非同期データの取得（例: `final izakayasProvider = FutureProvider((ref) => ref.read(izakayaRepository).fetchIzakayas())`）
- **StreamProvider**: ストリームデータの監視（例: `final userChangesProvider = StreamProvider((ref) => ref.read(authRepository).userChanges())`）

#### 9.4.2. 状態管理パターン
- 状態クラスは`freezed`を使用して不変に
- 状態変更は必ずStateNotifierのメソッド経由で実行
- 複雑な状態は`AsyncValue`を活用し、loading/error/dataの状態を統一的に管理
- UIからビジネスロジックを分離し、StateNotifier内でロジックを実装

### 9.5. エラーハンドリングポリシー

#### 9.5.1. 例外処理パターン
- 独自例外クラスの定義（例: `class AuthException extends Exception`）
- ドメイン固有の例外と汎用例外を適切に区別
- リポジトリ層での例外変換（Firebase例外→アプリ固有例外）
- Try-catchはできるだけ上位レイヤーで実施

#### 9.5.2. エラーメッセージ
- ユーザー向けエラーメッセージは多言語化対応
- 開発者向けログメッセージは詳細に
- エラーコードの統一（例: `auth/invalid-email`, `network/timeout`）

### 9.6. 非同期処理パターン

#### 9.6.1. Future/Stream使用ガイドライン
- **Future**: 単発のデータ取得に使用
- **Stream**: 継続的なデータ更新の監視に使用
- 非同期処理は適切な例外処理を含めること
- 長時間処理にはタイムアウト設定を付与

#### 9.6.2. ローディング状態管理
- ローディング状態はUIコンポーネント毎に個別管理せず、状態モデルに含める
- `AsyncValue`を活用した統一的なローディング処理
- スケルトンローディングやプレースホルダーの統一パターン

### 9.7. テストガイドライン

#### 9.7.1. テストファイル命名規則
- テストファイル: `<テスト対象ファイル名>_test.dart`（例: `izakaya_repository_test.dart`）
- テストグループ: 機能単位でグループ化（例: `group('IzakayaRepository', () { ... })`）
- テストケース: 期待する動作を明確に（例: `test('should return izakayas when fetchIzakayas is called', () { ... })`）

#### 9.7.2. モック作成ルール
- モックライブラリ: `mocktail`を使用
- モッククラス: `Mock<クラス名>`（例: `class MockFirebaseAuth extends Mock implements FirebaseAuth {}`）
- スタブ定義は各テストメソッド内で明示的に行う

### 9.8. Git運用ルール
- ブランチ命名規則
  - feature/: 新機能開発
  - fix/: バグ修正
  - refactor/: リファクタリング
- コミットメッセージ規約
  - feat: 新機能
  - fix: バグ修正
  - docs: ドキュメント
  - style: フォーマット
  - refactor: リファクタリング
  - test: テスト関連
  - chore: その他

### 9.9. レビュー基準
- 機能要件との整合性
- コーディング規約準拠
- テストカバレッジ
- パフォーマンス影響
- セキュリティ考慮

### 9.10. Material Design 3ガイドライン

#### 9.10.1 テーマ設定
- **カラーシステム**
  - プライマリ、セカンダリ、ターシャリカラーをベースに色彩システムを構築
  - ダイナミックカラーをサポートし、ユーザーのシステムテーマに適応
  - ダーク/ライトテーマの両方をサポート

#### 9.10.2 コンポーネント使用
- **基本コンポーネント**
  - Button, Card, Dialog, BottomSheet, NavigationBar, AppBarなどはMaterial 3の新コンポーネントを使用
  - カスタムコンポーネントを作成する場合も、Material Designの原則に従う

#### 9.10.3 タイポグラフィ
- Material Design 3のタイポグラフィスケールに準拠
- 日本語フォントをサポートしつつ、読みやすさとブランドイメージを両立

#### 9.10.4 スペーシングとレイアウト
- 8dpの倍数でスペーシングを設定
- レスポンシブレイアウトはBreakpointシステムに基づいて設計 