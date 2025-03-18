# GastronomeJourney CI/CD ワークフロー設定

## 1. 概要

このドキュメントでは、GastronomeJourneyプロジェクトで使用するGitHub Actionsのワークフロー設定ファイルのサンプルを提供します。これらの設定ファイルは、継続的インテグレーション（CI）と継続的デリバリー（CD）のプロセスを自動化するために使用されます。

## 2. ディレクトリ構造

GitHub Actionsのワークフロー設定ファイルは、プロジェクトのルートディレクトリにある`.github/workflows/`ディレクトリに配置します。

```
.github/
  workflows/
    flutter_ci.yml        # Flutter CI ワークフロー
    flutter_deploy_dev.yml    # 開発環境へのデプロイワークフロー
    flutter_deploy_staging.yml  # ステージング環境へのデプロイワークフロー
    flutter_deploy_prod.yml   # 本番環境へのデプロイワークフロー
```

## 3. Flutter CI ワークフロー

このワークフローは、プルリクエストやブランチへのプッシュ時に実行され、コードの品質チェックを行います。

### `flutter_ci.yml`

```yaml
name: Flutter CI

on:
  push:
    branches: [ develop, 'release/*', main ]
  pull_request:
    branches: [ develop, 'release/*', main ]

jobs:
  analyze_and_test:
    name: Analyze and Test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
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
          fail_ci_if_error: true

  build_android:
    name: Build Android APK
    needs: analyze_and_test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --debug
      
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: app-debug
          path: build/app/outputs/flutter-apk/app-debug.apk
```

## 4. 開発環境デプロイワークフロー

このワークフローは、`develop`ブランチへのプッシュ時に実行され、開発環境へのデプロイを行います。

### `flutter_deploy_dev.yml`

```yaml
name: Deploy to Development

on:
  push:
    branches: [ develop ]

jobs:
  deploy_to_firebase:
    name: Deploy to Firebase App Distribution
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build Android APK
        run: flutter build apk
      
      - name: Upload Artifact to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID_ANDROID_DEV }}
          serviceCredentialsFileContent: ${{ secrets.CREDENTIAL_FILE_CONTENT }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk
          releaseNotes: |
            Development build from branch ${{ github.ref_name }}
            Commit: ${{ github.sha }}
```

## 5. ステージング環境デプロイワークフロー

このワークフローは、`release/*`ブランチへのプッシュ時に実行され、ステージング環境へのデプロイを行います。

### `flutter_deploy_staging.yml`

```yaml
name: Deploy to Staging

on:
  push:
    branches: [ 'release/*' ]

jobs:
  deploy_android:
    name: Deploy Android to Firebase (Staging)
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment config
        run: |
          echo "${{ secrets.ENV_STAGING }}" > .env
      
      - name: Build Android APK
        run: flutter build apk
      
      - name: Upload Android Build to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID_ANDROID_STAGING }}
          serviceCredentialsFileContent: ${{ secrets.CREDENTIAL_FILE_CONTENT }}
          groups: qa-team, beta-testers
          file: build/app/outputs/flutter-apk/app-release.apk
          releaseNotes: |
            Staging build from branch ${{ github.ref_name }}
            Commit: ${{ github.sha }}
  
  deploy_ios:
    name: Deploy iOS to TestFlight
    runs-on: macos-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment config
        run: |
          echo "${{ secrets.ENV_STAGING }}" > .env
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      
      - name: Install Fastlane
        run: |
          cd ios
          bundle install
      
      - name: Setup Keychain and Provisioning Profile
        env:
          APPLE_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
          APPLE_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          cd ios
          bundle exec fastlane setup_signing
      
      - name: Build and upload to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}
        run: |
          cd ios
          bundle exec fastlane beta
```

## 6. 本番環境デプロイワークフロー

このワークフローは、`main`ブランチへのプッシュ時に実行され、本番環境へのデプロイを行います。

### `flutter_deploy_prod.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
    tags:
      - 'v*'

jobs:
  deploy_android:
    name: Deploy Android to Google Play
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment config
        run: |
          echo "${{ secrets.ENV_PRODUCTION }}" > .env
      
      - name: Build Android App Bundle
        run: flutter build appbundle
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      
      - name: Install Fastlane
        run: |
          cd android
          bundle install
      
      - name: Setup Google Play API Access
        env:
          GOOGLE_PLAY_SERVICE_ACCOUNT_JSON: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
        run: |
          cd android
          echo "$GOOGLE_PLAY_SERVICE_ACCOUNT_JSON" > google-play-service-account.json
      
      - name: Deploy to Google Play
        run: |
          cd android
          bundle exec fastlane deploy_production
  
  deploy_ios:
    name: Deploy iOS to App Store
    runs-on: macos-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup environment config
        run: |
          echo "${{ secrets.ENV_PRODUCTION }}" > .env
      
      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.0'
          bundler-cache: true
      
      - name: Install Fastlane
        run: |
          cd ios
          bundle install
      
      - name: Setup Keychain and Provisioning Profile
        env:
          APPLE_CERTIFICATE_BASE64: ${{ secrets.APPLE_CERTIFICATE_BASE64 }}
          APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
          APPLE_PROVISIONING_PROFILE_BASE64: ${{ secrets.APPLE_PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          cd ios
          bundle exec fastlane setup_signing
      
      - name: Build and upload to App Store
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APP_STORE_CONNECT_API_KEY_CONTENT }}
        run: |
          cd ios
          bundle exec fastlane release
```

## 7. iOSのFastlaneファイル例

iOSのデプロイには、Fastlaneを使用します。以下は、基本的なFastlaneファイルの例です。

### `ios/Gemfile`

```ruby
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
```

### `ios/fastlane/Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc "Setup signing for iOS build"
  lane :setup_signing do
    create_keychain(
      name: "build_keychain",
      password: ENV["KEYCHAIN_PASSWORD"],
      default_keychain: true,
      unlock: true,
      timeout: 3600,
      lock_when_sleeps: false
    )
    
    import_certificate(
      certificate_path: "certificate.p12",
      certificate_password: ENV["APPLE_CERTIFICATE_PASSWORD"],
      keychain_name: "build_keychain",
      keychain_password: ENV["KEYCHAIN_PASSWORD"]
    )
    
    install_provisioning_profile(path: "profile.mobileprovision")
    
    update_project_provisioning(
      xcodeproj: "Runner.xcodeproj",
      profile: "profile.mobileprovision",
      build_configuration: "Release"
    )
  end

  desc "Push a new beta build to TestFlight"
  lane :beta do
    increment_build_number(xcodeproj: "Runner.xcodeproj")
    build_app(workspace: "Runner.xcworkspace", scheme: "Runner")
    upload_to_testflight(
      api_key: app_store_connect_api_key,
      skip_waiting_for_build_processing: true
    )
  end

  desc "Push a new release build to the App Store"
  lane :release do
    increment_build_number(xcodeproj: "Runner.xcodeproj")
    build_app(workspace: "Runner.xcworkspace", scheme: "Runner")
    upload_to_app_store(
      api_key: app_store_connect_api_key,
      force: true,
      skip_screenshots: true,
      skip_metadata: true
    )
  end

  def app_store_connect_api_key
    app_store_connect_api_key = {
      key_id: ENV["APP_STORE_CONNECT_API_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"],
      key_content: ENV["APP_STORE_CONNECT_API_KEY_CONTENT"],
    }
  end
end
```

## 8. AndroidのFastlaneファイル例

Androidのデプロイには、Fastlaneを使用します。以下は、基本的なFastlaneファイルの例です。

### `android/Gemfile`

```ruby
source "https://rubygems.org"

gem "fastlane"
```

### `android/fastlane/Fastfile`

```ruby
default_platform(:android)

platform :android do
  desc "Deploy to Google Play internal testing track"
  lane :deploy_internal do
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: 'google-play-service-account.json',
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      release_status: 'draft'
    )
  end

  desc "Deploy to Google Play production"
  lane :deploy_production do
    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab',
      json_key: 'google-play-service-account.json',
      skip_upload_metadata: false,
      skip_upload_images: false,
      skip_upload_screenshots: false,
      release_status: 'completed'
    )
  end
end
```

## 9. GitHub Secrets

上記のワークフロー設定ファイルで使用しているシークレット（secrets）は、GitHub リポジトリの Settings > Secrets and variables > Actions で設定します。以下は必要なシークレットの一覧です：

### 共通
- `ENV_DEVELOPMENT`: 開発環境用の環境変数
- `ENV_STAGING`: ステージング環境用の環境変数
- `ENV_PRODUCTION`: 本番環境用の環境変数

### Firebase App Distribution
- `FIREBASE_APP_ID_ANDROID_DEV`: 開発環境のAndroidアプリID
- `FIREBASE_APP_ID_ANDROID_STAGING`: ステージング環境のAndroidアプリID
- `CREDENTIAL_FILE_CONTENT`: Firebase認証用のサービスアカウントキー（JSON）

### iOS デプロイ
- `APPLE_CERTIFICATE_BASE64`: Base64エンコードされた証明書ファイル
- `APPLE_CERTIFICATE_PASSWORD`: 証明書のパスワード
- `APPLE_PROVISIONING_PROFILE_BASE64`: Base64エンコードされたプロビジョニングプロファイル
- `KEYCHAIN_PASSWORD`: キーチェーンのパスワード
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect APIキーID
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`: App Store Connect APIキー発行者ID
- `APP_STORE_CONNECT_API_KEY_CONTENT`: App Store Connect APIキーの内容

### Android デプロイ
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Google Play APIアクセス用のサービスアカウントキー（JSON）

## 10. 更新履歴

| 日付 | バージョン | 更新内容 | 担当者 |
|-----|-----------|---------|-------|
| 2023-XX-XX | 1.0 | 初版作成 | XXX | 