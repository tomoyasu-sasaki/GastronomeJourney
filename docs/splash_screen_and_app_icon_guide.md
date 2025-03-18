# GastronomeJourney スプラッシュスクリーンとアプリアイコン設定ガイド

## 1. 概要

このドキュメントでは、GastronomeJourneyアプリのスプラッシュスクリーンとアプリアイコンの設定方法について説明します。モバイルアプリのユーザー体験において、スプラッシュスクリーンとアプリアイコンは最初の印象を決める重要な要素です。

## 2. スプラッシュスクリーン

### 2.1. Flutter スプラッシュスクリーンの設定方法

GastronomeJourneyでは、`flutter_native_splash`パッケージを使用してスプラッシュスクリーンを実装します。

#### 2.1.1. パッケージのインストール

`pubspec.yaml`ファイルに以下を追加します：

```yaml
dependencies:
  flutter_native_splash: ^2.3.6

dev_dependencies:
  flutter_native_splash: ^2.3.6
```

#### 2.1.2. 設定ファイルの作成

プロジェクトのルートディレクトリに`flutter_native_splash.yaml`ファイルを作成し、以下の内容を追加します：

```yaml
flutter_native_splash:
  # スプラッシュスクリーンの背景色
  color: "#121212"
  # または背景画像を使用する場合
  # background_image: "assets/images/splash_background.png"
  
  # スプラッシュスクリーンの中央に表示するロゴ
  image: assets/images/splash_logo.png
  
  # ブランディングイメージ（下部に表示される小さなロゴ）
  branding: assets/images/branding.png
  branding_mode: bottom
  
  # ダークモード設定
  color_dark: "#121212"
  image_dark: assets/images/splash_logo_dark.png
  branding_dark: assets/images/branding_dark.png
  
  # Androidの設定
  android: true
  android_12:
    # Android 12以降用の設定
    icon_background_color: "#121212"
    image: assets/images/splash_logo_android12.png
    icon_background_color_dark: "#121212"
    image_dark: assets/images/splash_logo_android12_dark.png
  
  # iOSの設定
  ios: true
  
  # Webの設定
  web: false
  
  # スプラッシュスクリーンの表示時間（ミリ秒）
  # 注意: この設定はAndroidでのみ機能します
  android_screen_orientation: portrait
```

#### 2.1.3. スプラッシュスクリーンの生成

以下のコマンドを実行して、設定に基づいたスプラッシュスクリーンを生成します：

```bash
flutter pub run flutter_native_splash:create
```

#### 2.1.4. スプラッシュスクリーンの削除（必要に応じて）

```bash
flutter pub run flutter_native_splash:remove
```

### 2.2. スプラッシュスクリーンのデザインガイドライン

#### 2.2.1. デザイン要件

- **シンプルさ**: スプラッシュスクリーンはシンプルで、過度に複雑なグラフィックを避けます
- **ブランド一貫性**: アプリのブランドカラーとロゴを使用し、一貫性を保ちます
- **読み込み速度**: スプラッシュスクリーンは素早く表示される必要があります
- **レスポンシブ**: 様々な画面サイズとアスペクト比に対応する必要があります

#### 2.2.2. 画像サイズの推奨値

- **中央ロゴ**: 1024×1024ピクセル（アスペクト比1:1）
- **背景画像**: 2732×2732ピクセル（最大iPadのサイズ）
- **ブランディングイメージ**: 400×100ピクセル（横長のロゴに最適）

### 2.3. プラットフォーム固有の設定

#### 2.3.1. Android

Android 12以降では、スプラッシュスクリーンの仕様が変更されました。以下の点に注意してください：

- **アイコンベースのスプラッシュ**: アプリアイコンを中心に表示するシンプルなスプラッシュスクリーンが標準となりました
- **カスタマイズの制限**: 背景色とアイコンのみカスタマイズ可能です
- **ダークモード対応**: ダークモードでは別の色設定が必要です

Android 12より前のバージョンでは、`res/drawable/launch_background.xml`ファイルでスプラッシュスクリーンをカスタマイズできます。

#### 2.3.2. iOS

iOSでは、`LaunchScreen.storyboard`ファイルを使用してスプラッシュスクリーンをカスタマイズできます。以下の点に注意してください：

- **静的イメージ**: アニメーションはサポートされていません
- **アスペクト比の維持**: 様々なデバイスサイズで適切に表示されるようにアスペクト比を維持します
- **セーフエリアの考慮**: ノッチやホームインジケータのあるデバイスでの表示を考慮します

## 3. アプリアイコン

### 3.1. アプリアイコンの要件

#### 3.1.1. Android アプリアイコン

Androidでは、以下のサイズのアイコンが必要です：

| 用途 | サイズ（ピクセル） |
|------|-------------------|
| ldpi | 36×36 |
| mdpi | 48×48 |
| hdpi | 72×72 |
| xhdpi | 96×96 |
| xxhdpi | 144×144 |
| xxxhdpi | 192×192 |
| Play Store | 512×512 |

アダプティブアイコン（Android 8.0以降）では、以下の要素が必要です：

- フォアグラウンドレイヤー: 108×108dp（実際は最低でも432×432px）
- バックグラウンドレイヤー: 108×108dp（実際は最低でも432×432px）

#### 3.1.2. iOS アプリアイコン

iOSでは、以下のサイズのアイコンが必要です：

| 用途 | サイズ（ピクセル） |
|------|-------------------|
| iPhone通知（2x） | 40×40 |
| iPhone通知（3x） | 60×60 |
| iPhone設定（2x） | 58×58 |
| iPhone設定（3x） | 87×87 |
| iPhoneスポットライト（2x） | 80×80 |
| iPhoneスポットライト（3x） | 120×120 |
| iPhoneアプリ（2x） | 120×120 |
| iPhoneアプリ（3x） | 180×180 |
| iPadアプリ（1x） | 76×76 |
| iPadアプリ（2x） | 152×152 |
| iPadProアプリ | 167×167 |
| App Store | 1024×1024 |

### 3.2. Flutter でのアプリアイコン設定

Flutter では、`flutter_launcher_icons`パッケージを使用してアプリアイコンを簡単に設定できます。

#### 3.2.1. パッケージのインストール

`pubspec.yaml`ファイルに以下を追加します：

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

#### 3.2.2. 設定ファイルの作成

プロジェクトのルートディレクトリに`flutter_launcher_icons.yaml`ファイルを作成し、以下の内容を追加します：

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF" # Androidのアダプティブアイコンの背景色
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png" # Androidのアダプティブアイコンのフォアグラウンド
  min_sdk_android: 21 # 最小サポートするAndroid SDK バージョン
  remove_alpha_ios: true # iOS用のアイコンからアルファチャンネルを削除
  web:
    generate: false
  windows:
    generate: false
  macos:
    generate: false
```

#### 3.2.3. アイコンの生成

以下のコマンドを実行して、設定に基づいたアプリアイコンを生成します：

```bash
flutter pub run flutter_launcher_icons
```

### 3.3. アプリアイコンのデザインガイドライン

#### 3.3.1. 共通ガイドライン

- **シンプルさ**: アイコンはシンプルで、小さいサイズでも認識できるようにします
- **ユニークさ**: 他のアプリと区別できるようにユニークなデザインにします
- **ブランド一貫性**: アプリのブランドカラーとスタイルを反映させます
- **背景**: 様々な背景色の上でも視認性が確保できるようにします

#### 3.3.2. Androidのガイドライン

- **マテリアルデザイン**: Googleのマテリアルデザインガイドラインに従います
- **アダプティブアイコン**: フォアグラウンドとバックグラウンドの2層でデザインします
- **セーフゾーン**: フォアグラウンドの重要な要素は中央の72×72dpのエリア内に収めます

#### 3.3.3. iOSのガイドライン

- **ヒューマンインターフェイスガイドライン**: Appleのガイドラインに従います
- **マスク**: iOSは自動的に角丸の正方形のマスクを適用します
- **透明度**: 背景を透明にしないでください（完全に塗りつぶします）

## 4. スプラッシュスクリーンとアプリアイコンの連携

ユーザー体験を向上させるために、スプラッシュスクリーンとアプリアイコンのデザインを連携させることが重要です：

- **視覚的一貫性**: スプラッシュスクリーンとアプリアイコンで同じカラースキームとビジュアル要素を使用します
- **ブランドアイデンティティ**: 両方でブランドロゴを一貫して使用します
- **シームレスな遷移**: スプラッシュスクリーンからアプリのメイン画面への視覚的な連続性を確保します

## 5. アセット管理のベストプラクティス

### 5.1. アセットの組織化

プロジェクト内でアセットを効率的に管理するための推奨ディレクトリ構造：

```
assets/
  ├── icons/
  │   ├── app_icon.png
  │   └── app_icon_foreground.png
  ├── images/
  │   ├── splash_logo.png
  │   ├── splash_logo_dark.png
  │   └── splash_background.png
  └── branding/
      ├── branding.png
      └── branding_dark.png
```

### 5.2. ソースファイルの保存

元の高解像度のソースファイル（PSD、AI、Figmaなど）は、以下のリポジトリに保存します：

- GastronomeJourney Designリポジトリ: `https://github.com/example/gastronomejourney-design`

## 6. デザインレビューと承認プロセス

スプラッシュスクリーンとアプリアイコンのデザインレビューと承認のプロセスは以下の通りです：

1. デザイナーがスプラッシュスクリーンとアプリアイコンの案を作成
2. デザインレビューミーティングで案を検討
3. 必要に応じてデザインを修正
4. 最終デザインの承認
5. 必要なサイズとフォーマットでのアセット書き出し
6. 開発環境での実装とテスト
7. 異なるデバイスでの表示確認

## 7. 更新履歴

| 日付 | バージョン | 更新内容 | 担当者 |
|-----|-----------|---------|-------|
| 2023-XX-XX | 1.0 | 初版作成 | XXX | 