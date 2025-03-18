# GastronomeJourney パフォーマンスベンチマークとモニタリングガイド

## 1. 概要

このドキュメントでは、GastronomeJourneyアプリケーションのパフォーマンス目標、測定方法、モニタリング戦略について定義します。ユーザー体験の質を確保するためには、パフォーマンスが重要な要素となります。

## 2. パフォーマンス目標

### 2.1. 起動時間

アプリの起動速度はユーザーの第一印象に大きく影響します。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| コールドスタート時間 | <2秒 | <3秒 | AppStartupTimeトレース |
| ウォームスタート時間 | <1秒 | <1.5秒 | AppStartupTimeトレース |
| スプラッシュスクリーン表示時間 | 800ms | 1.2秒 | カスタムトレース |

### 2.2. UI応答性

ユーザーインターフェースの応答性は、ユーザー体験に直接的な影響を与えます。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| 入力レイテンシ | <50ms | <100ms | 手動テスト |
| アニメーションフレームレート | 60fps | >45fps | FPSモニター |
| 画面遷移時間 | <300ms | <500ms | 画面遷移トレース |
| スクロールの滑らかさ | 60fps | >50fps | プロファイリングツール |

### 2.3. ネットワーク操作

データのロードや送信は、アプリの重要な機能です。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| 居酒屋リスト初回ロード時間 | <1.5秒 | <2.5秒 | カスタムネットワークトレース |
| 画像読み込み時間（一般） | <1秒 | <2秒 | 画像ロードトレース |
| 居酒屋詳細画面のロード時間 | <1秒 | <2秒 | 画面ロードトレース |
| 検索クエリ応答時間 | <1秒 | <2秒 | 検索操作トレース |
| 新規投稿送信時間 | <1.5秒 | <3秒 | 送信操作トレース |

### 2.4. メモリ使用量

メモリの効率的な使用は、特に低スペックデバイスでの安定性に影響します。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| ピークメモリ使用量 | <150MB | <200MB | メモリプロファイリング |
| バックグラウンド時のメモリ使用量 | <50MB | <80MB | バックグラウンドメモリ測定 |
| メモリリーク | なし | なし | 長時間実行テスト |

### 2.5. バッテリー消費

バッテリー消費が少ないことは、モバイルアプリでは重要な要素です。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| バックグラウンド処理電力消費 | 最小限 | 低 | Firebase Performance Monitoring |
| 1時間の使用あたりのバッテリー消費 | <2% | <5% | バッテリー消費テスト |
| 位置情報サービスの電力効率 | 効率的 | 中程度 | 位置情報使用パターン分析 |

### 2.6. ストレージ使用量

アプリのインストールとデータのストレージ使用量は、ユーザーの限られたデバイスストレージに影響します。

| 指標 | 目標値 | 許容値 | 測定方法 |
|-----|-------|-------|---------|
| アプリインストールサイズ（Android） | <30MB | <50MB | APKサイズ分析 |
| アプリインストールサイズ（iOS） | <50MB | <80MB | IPAサイズ分析 |
| キャッシュ最大サイズ | <100MB | <200MB | ストレージ使用量モニタリング |
| オフラインデータサイズ | <50MB | <100MB | データベースサイズ分析 |

## 3. パフォーマンス測定ツールとアプローチ

### 3.1. Flutter DevTools

Flutter DevToolsを使用して、アプリのパフォーマンスをローカルで監視および分析します。

#### 3.1.1. Flutter Performance View

Flutterの「Performance」ビューを使用して、UI描画のパフォーマンスを測定します。

```dart
// デバッグビルドでパフォーマンスオーバーレイを有効にする
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true; // レイアウトの境界を表示
  debugRepaintRainbowEnabled = true; // リペイントをハイライト
  runApp(MyApp());
}
```

#### 3.1.2. Flutter Memory View

メモリリークやメモリ使用量を追跡します。

```dart
// アプリ内のメモリ使用量をロギング
void logMemoryUsage() {
  final memoryInfo = MemoryAllocations.instance;
  print('Current memory usage: ${memoryInfo.currentRss}');
}
```

### 3.2. Firebase Performance Monitoring

Firebase Performance Monitoringを使用して、本番環境でのアプリのパフォーマンスを追跡します。

#### 3.2.1. 設定

```dart
// main.dartでFirebase Performance Monitoringを初期化
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  runApp(MyApp());
}
```

#### 3.2.2. カスタムトレースの実装

```dart
// 画面読み込みのトレース例
Future<void> loadIzakayaDetails(String id) async {
  final Trace trace = FirebasePerformance.instance.newTrace('izakaya_details_load');
  await trace.start();
  
  try {
    final repository = IzakayaRepository();
    final izakaya = await repository.getIzakayaById(id);
    // 処理...
  } finally {
    await trace.stop();
  }
}

// ネットワークリクエストの測定
Future<void> trackNetworkRequest() async {
  final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
    'https://api.example.com/izakayas', 
    HttpMethod.Get,
  );
  
  await metric.start();
  try {
    final response = await http.get(Uri.parse('https://api.example.com/izakayas'));
    metric.httpResponseCode = response.statusCode;
    metric.responsePayloadSize = response.bodyBytes.length;
  } finally {
    await metric.stop();
  }
}
```

### 3.3. カスタムパフォーマンス測定

アプリケーション固有のパフォーマンス指標を測定するためのカスタムユーティリティを実装します。

```dart
class PerformanceTracker {
  static final Map<String, Stopwatch> _timers = {};
  
  // 測定開始
  static void startMeasurement(String name) {
    final stopwatch = Stopwatch()..start();
    _timers[name] = stopwatch;
  }
  
  // 測定終了と結果取得
  static Duration stopMeasurement(String name) {
    final stopwatch = _timers[name];
    if (stopwatch == null) {
      throw Exception('Timer "$name" not found');
    }
    
    stopwatch.stop();
    final elapsed = stopwatch.elapsed;
    _timers.remove(name);
    
    // Firebase Analyticsにログを送信
    FirebaseAnalytics.instance.logEvent(
      name: 'performance_measurement',
      parameters: {
        'measurement_name': name,
        'duration_ms': elapsed.inMilliseconds,
      },
    );
    
    return elapsed;
  }
}

// 使用例
void loadData() async {
  PerformanceTracker.startMeasurement('data_loading');
  await fetchData();
  final duration = PerformanceTracker.stopMeasurement('data_loading');
  print('Data loading took ${duration.inMilliseconds}ms');
}
```

### 3.4. プロファイリングビルド

リリース構成に近いプロファイリングビルドを使用して、実際の使用条件に近いパフォーマンスを測定します。

```bash
# プロファイリングビルドの作成
flutter build apk --profile
flutter build ios --profile

# プロファイリングビルドの実行
flutter run --profile
```

## 4. パフォーマンスモニタリング戦略

### 4.1. 継続的パフォーマンステスト

CIパイプラインでの自動パフォーマンステストを設定します。

```yaml
# GitHub Actionsを使用したパフォーマンステストの例
name: Performance Testing

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  performance_test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      - name: Install dependencies
        run: flutter pub get
      - name: Run performance tests
        run: flutter test integration_test/performance_test.dart --profile
      - name: Upload performance report
        uses: actions/upload-artifact@v3
        with:
          name: performance-report
          path: build/performance-report/
```

### 4.2. 本番環境モニタリング

Firebase Performance Monitoringを使用して、本番環境でのパフォーマンスを継続的に監視します。

#### 4.2.1. パフォーマンスダッシュボード

Firebase Consoleのパフォーマンスセクションで、主要な指標を監視します：

- アプリ起動時間
- 画面遷移時間
- ネットワークリクエスト時間
- カスタムトレース

#### 4.2.2. アラートの設定

パフォーマンスメトリクスが特定のしきい値を超えた場合のアラートを設定します。

### 4.3. パフォーマンスリグレッション検出

新しいバージョンのリリース前に、パフォーマンスリグレッションがないことを確認します。

```dart
// performance_test.dart
void main() {
  group('Performance Regression Tests', () {
    testWidgets('Home screen loading time', (WidgetTester tester) async {
      final Stopwatch stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 目標値と比較
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    // 他のパフォーマンステスト
  });
}
```

## 5. パフォーマンス最適化ガイドライン

### 5.1. 一般的な最適化

#### 5.1.1. メモリ最適化

- 未使用のリソースを解放する
- 大きなメモリオブジェクトをキャッシュする際は弱参照を使用する
- リスト表示では`ListView.builder`を使用する

```dart
// 良い例
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(item: items[index]),
)

// 避けるべき例
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)
```

#### 5.1.2. UI描画の最適化

- `const`ウィジェットを使用する
- 複雑なウィジェットツリーを避ける
- `RepaintBoundary`を適切に使用する

```dart
// 再描画を最小限に抑える
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ComplexWidget(),
    );
  }
}
```

### 5.2. Firestore最適化

#### 5.2.1. クエリの最適化

- 必要なフィールドのみを取得する
- 適切なインデックスを作成する
- クエリ結果をキャッシュする

```dart
// 良い例
FirebaseFirestore.instance
  .collection('izakayas')
  .where('rating', isGreaterThanOrEqualTo: 4)
  .orderBy('rating', descending: true)
  .limit(10)
  .get();

// 避けるべき例
FirebaseFirestore.instance
  .collection('izakayas')
  .get()
  .then((snapshot) => snapshot.docs
    .where((doc) => doc['rating'] >= 4)
    .toList()
    .sort((a, b) => b['rating'] - a['rating'])
    .take(10));
```

#### 5.2.2. オフラインサポート

- オフラインキャッシュを有効化する
- 重要なデータを事前にキャッシュする

```dart
// オフラインキャッシュの設定
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 5.3. 画像最適化

#### 5.3.1. 画像キャッシュと遅延読み込み

- `cached_network_image`パッケージを使用する
- プレースホルダーを表示する
- 適切な解像度の画像を使用する

```dart
// 最適化された画像表示
CachedNetworkImage(
  imageUrl: izakaya.imageUrl,
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fit: BoxFit.cover,
  memCacheWidth: 300, // メモリキャッシュの解像度を制限
)
```

#### 5.3.2. 画像リサイズ

Firebase Storageに保存する前に、画像をリサイズします。

```dart
// Cloud Functionsを使用した画像リサイズの例
exports.resizeImage = functions.storage.object().onFinalize(async (object) => {
  // 画像処理ロジック
});
```

### 5.4. 状態管理の最適化

#### 5.4.1. Riverpod最適化

- 適切なスコープを使用する
- 不要な再構築を避ける
- 自動破棄を活用する

```dart
// 効率的なProviderの使用
@riverpod
Future<List<IzakayaModel>> topRatedIzakayas(TopRatedIzakayasRef ref) async {
  final repository = ref.watch(izakayaRepositoryProvider);
  return repository.getTopRatedIzakayas(limit: 10);
}

// UIでの効率的な使用
class TopIzakayasList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 必要な部分のみを監視
    final userName = ref.watch(userProfileProvider.select((user) => user.name));
    // ...
  }
}
```

## 6. パフォーマンス問題のトラブルシューティング

### 6.1. 一般的なパフォーマンス問題と解決策

| 問題 | 原因 | 解決策 |
|-----|-----|-------|
| 画面の遅延またはフリーズ | メインスレッドでの重い処理 | `compute`または`Isolate`を使用 |
| スクロール中のジャンク | 過度なリビルドまたは複雑なUIレイアウト | `const`ウィジェットの使用、`ListView.builder`の最適化 |
| アプリ起動の遅さ | 初期化時の重い処理 | 遅延初期化、バックグラウンド処理の使用 |
| メモリリーク | リソースの解放漏れ | `dispose`メソッドでのリソース解放、弱参照の使用 |
| バッテリーの急速な消費 | 過度なバックグラウンド処理や位置情報の使用 | バックグラウンド処理の最適化、位置情報の使用頻度削減 |

### 6.2. パフォーマンスデバッグプロセス

1. 問題の特定
   - DevToolsを使用してボトルネックを特定
   - ユーザーからのフィードバックを分析

2. 状況の再現
   - 問題を再現するテストケースを作成
   - プロファイリングビルドで測定

3. 原因の診断
   - タイムラインの分析
   - メモリスナップショットの検査
   - CPU使用率の調査

4. 解決策の実装と検証
   - パフォーマンス改善を実装
   - 改善前後での測定値を比較

### 6.3. パフォーマンスデバッグツール

- Flutter DevTools
- Android Profiler
- iOS Instruments
- Firebase Performance Monitoring
- カスタムパフォーマンスログ

## 7. リリース前のパフォーマンスチェックリスト

リリース前に確認すべきパフォーマンス関連の項目のチェックリストです：

- [ ] アプリの起動時間が目標値内に収まっている
- [ ] UI操作の応答時間が目標値内に収まっている
- [ ] すべての画面遷移がスムーズである
- [ ] リスト表示のスクロールが60FPSを維持している
- [ ] メモリリークがないことを確認した
- [ ] オフラインモードでの動作を検証した
- [ ] 低スペックデバイスでのパフォーマンスを検証した
- [ ] リリースビルドでのパフォーマンスを検証した
- [ ] Firebase Performance MonitoringとCrashlyticsが有効になっている
- [ ] バッテリー消費が目標値内に収まっている
- [ ] アプリサイズが目標値内に収まっている

## 8. パフォーマンスモニタリングと改善の継続的なサイクル

1. **測定**: パフォーマンス指標を継続的に測定
2. **分析**: データを分析してボトルネックと傾向を特定
3. **改善**: 具体的な最適化を実装
4. **検証**: 改善の効果を検証
5. **繰り返し**: このサイクルを継続的に繰り返す

## 9. 更新履歴

| 日付 | バージョン | 更新内容 | 担当者 |
|-----|-----------|---------|-------|
| 2023-XX-XX | 1.0 | 初版作成 | XXX | 