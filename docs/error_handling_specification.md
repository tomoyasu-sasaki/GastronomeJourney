# GastronomeJourney エラーハンドリング仕様書

## 1. エラーハンドリング方針

### 1.1. 基本方針

GastronomeJourneyアプリケーションでは、以下の方針に従ってエラーハンドリングを実施します：

1. **ユーザーフレンドリー**: エラーメッセージは一般ユーザーにも理解できる明確な言葉で表示
2. **回復可能性**: 可能な限りアプリケーションを復旧可能な状態に維持
3. **一貫性**: 全アプリケーションで一貫したエラーハンドリングパターンを使用
4. **詳細ロギング**: 開発者向けに詳細なエラー情報をログに記録
5. **オフライン対応**: ネットワーク不通時の適切な対応と回復戦略

### 1.2. エラーの層別管理

エラーは以下の4つの層で管理します：

1. **プレゼンテーション層**: UI表示とユーザーへのフィードバック
2. **ビジネスロジック層**: アプリケーションロジックにおけるエラー処理
3. **データアクセス層**: ローカルストレージとリモートAPIアクセスでのエラー処理
4. **インフラ層**: ネットワーク、デバイス、プラットフォーム関連のエラー処理

## 2. エラーの種類と分類

### 2.1. エラーの重大度分類

| 重大度レベル | 説明 | 対応方法 |
|------------|------|---------|
| **致命的** | アプリの継続が不可能なエラー | アプリの再起動を要求、またはフォールバック画面表示 |
| **重大** | 特定の機能が完全に使用不能になるエラー | 該当機能の無効化とエラーメッセージ表示 |
| **警告** | 機能の一部に影響するが回避可能なエラー | 警告メッセージ表示と代替手段の提案 |
| **情報** | ユーザーに注意を促す軽微な問題 | 通知またはスナックバーでの情報提供 |

### 2.2. エラーカテゴリ

#### 2.2.1. ネットワークエラー
- 接続なし
- タイムアウト
- サーバー応答エラー
- DNSエラー

#### 2.2.2. 認証エラー
- ログイン失敗
- セッション期限切れ
- 権限不足
- アカウント無効

#### 2.2.3. データエラー
- バリデーション失敗
- 必須データ欠落
- データ整合性エラー
- データ変換エラー

#### 2.2.4. リソースエラー
- ストレージ不足
- カメラ/写真アクセス拒否
- 位置情報アクセス拒否
- メモリ不足

#### 2.2.5. アプリケーションエラー
- 未処理例外
- 内部状態エラー
- ライフサイクルエラー
- サードパーティライブラリエラー

## 3. エラーコードとメッセージ体系

### 3.1. エラーコード形式

エラーコードは以下の形式で定義します：

`GJ-[カテゴリ]-[識別番号]`

カテゴリコード：
- `NET`: ネットワークエラー
- `AUTH`: 認証エラー
- `DATA`: データエラー
- `RES`: リソースエラー
- `APP`: アプリケーションエラー

例：`GJ-NET-001` = ネットワーク接続なしエラー

### 3.2. 標準エラーメッセージ

#### 3.2.1. ネットワークエラー
- `GJ-NET-001`: "インターネット接続がありません。Wi-Fiまたはモバイルデータをご確認ください。"
- `GJ-NET-002`: "サーバーとの通信がタイムアウトしました。後ほど再試行してください。"
- `GJ-NET-003`: "サーバーからのデータ取得に失敗しました。[詳細コード: {code}]"

#### 3.2.2. 認証エラー
- `GJ-AUTH-001`: "メールアドレスまたはパスワードが正しくありません。"
- `GJ-AUTH-002`: "ログインセッションが期限切れです。再度ログインしてください。"
- `GJ-AUTH-003`: "この操作を実行する権限がありません。"
- `GJ-AUTH-004`: "このメールアドレスは既に登録されています。"

#### 3.2.3. データエラー
- `GJ-DATA-001`: "入力データが無効です。フォームをご確認ください。"
- `GJ-DATA-002`: "必須情報が入力されていません。"
- `GJ-DATA-003`: "データの保存に失敗しました。後ほど再試行してください。"
- `GJ-DATA-004`: "データの読み込みに失敗しました。"

#### 3.2.4. リソースエラー
- `GJ-RES-001`: "ストレージ容量が不足しています。空き容量を確保してください。"
- `GJ-RES-002`: "カメラへのアクセスが許可されていません。設定アプリで許可をお願いします。"
- `GJ-RES-003`: "位置情報へのアクセスが許可されていません。設定アプリで許可をお願いします。"
- `GJ-RES-004`: "画像の処理に失敗しました。異なる画像で再試行してください。"

#### 3.2.5. アプリケーションエラー
- `GJ-APP-001`: "予期せぬエラーが発生しました。アプリを再起動してください。"
- `GJ-APP-002`: "この機能は現在利用できません。"
- `GJ-APP-003`: "アプリのバージョンが古いため、この機能は利用できません。アップデートをお願いします。"

### 3.3. エラーメッセージのローカライズ

エラーメッセージは多言語対応し、以下の言語をサポートします：
- 日本語（デフォルト）
- 英語

エラーメッセージは `lib/l10n/` ディレクトリ内の言語ファイルで管理します。

```dart
// lib/l10n/app_ja.arb
{
  "errorNetworkNoConnection": "インターネット接続がありません。Wi-Fiまたはモバイルデータをご確認ください。",
  "errorNetworkTimeout": "サーバーとの通信がタイムアウトしました。後ほど再試行してください。",
  // ... 他のエラーメッセージ
}

// lib/l10n/app_en.arb
{
  "errorNetworkNoConnection": "No internet connection. Please check your Wi-Fi or mobile data.",
  "errorNetworkTimeout": "Connection to server timed out. Please try again later.",
  // ... 他のエラーメッセージ
}
```

## 4. エラーハンドリングパターン

### 4.1. Try-Catch パターン

```dart
Future<void> saveIzakaya(IzakayaModel izakaya) async {
  try {
    await _repository.saveIzakaya(izakaya);
  } on FirebaseException catch (e) {
    switch (e.code) {
      case 'permission-denied':
        throw AppException(
          code: 'GJ-AUTH-003', 
          message: localization.errorAuthNoPermission
        );
      case 'unavailable':
        throw AppException(
          code: 'GJ-NET-003', 
          message: localization.errorNetworkServerError
        );
      default:
        throw AppException(
          code: 'GJ-APP-001', 
          message: localization.errorAppUnexpected,
          originalException: e
        );
    }
  } catch (e) {
    throw AppException(
      code: 'GJ-APP-001', 
      message: localization.errorAppUnexpected,
      originalException: e
    );
  }
}
```

### 4.2. Result パターン

```dart
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  const Result.success(this.data)
      : error = null,
        isSuccess = true;

  const Result.failure(this.error)
      : data = null,
        isSuccess = false;
        
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return failure(error!);
    }
  }
}

Future<Result<IzakayaModel>> getIzakayaById(String id) async {
  try {
    final izakaya = await _repository.getIzakayaById(id);
    if (izakaya != null) {
      return Result.success(izakaya);
    } else {
      return Result.failure(AppException(
        code: 'GJ-DATA-004',
        message: localization.errorDataNotFound,
      ));
    }
  } catch (e) {
    return Result.failure(_handleException(e));
  }
}

// 使用例
final result = await getIzakayaById('izakaya123');
result.when(
  success: (izakaya) {
    // 成功時の処理
    showIzakayaDetails(izakaya);
  },
  failure: (error) {
    // エラー時の処理
    showErrorMessage(error.message);
  },
);
```

### 4.3. Stream エラーハンドリング

```dart
Stream<List<IzakayaModel>> watchPublicIzakayas() {
  return _repository.watchPublicIzakayas().handleError((e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          throw AppException(
            code: 'GJ-AUTH-003', 
            message: localization.errorAuthNoPermission
          );
        default:
          throw AppException(
            code: 'GJ-APP-001', 
            message: localization.errorAppUnexpected,
            originalException: e
          );
      }
    } else {
      throw AppException(
        code: 'GJ-APP-001', 
        message: localization.errorAppUnexpected,
        originalException: e
      );
    }
  });
}
```

### 4.4. Riverpod でのエラーハンドリング

```dart
@riverpod
Future<List<IzakayaModel>> publicIzakayas(PublicIzakayasRef ref) async {
  try {
    final repository = ref.watch(izakayaRepositoryProvider);
    return await repository.getPublicIzakayas();
  } on NetworkException catch (e) {
    ref.read(analyticsServiceProvider).logError('network_error', e);
    throw AppException(
      code: 'GJ-NET-001',
      message: ref.read(localizationProvider).errorNetworkNoConnection,
      originalException: e,
    );
  } catch (e) {
    ref.read(analyticsServiceProvider).logError('unknown_error', e);
    throw AppException(
      code: 'GJ-APP-001',
      message: ref.read(localizationProvider).errorAppUnexpected,
      originalException: e,
    );
  }
}

// 使用例
Consumer(
  builder: (context, ref, child) {
    final izakayasAsync = ref.watch(publicIzakayasProvider);
    
    return izakayasAsync.when(
      data: (izakayas) => IzakayaListView(izakayas: izakayas),
      loading: () => const LoadingIndicator(),
      error: (error, stack) {
        if (error is AppException) {
          return ErrorView(
            message: error.message,
            onRetry: () => ref.refresh(publicIzakayasProvider),
          );
        }
        return const UnexpectedErrorView();
      },
    );
  },
)
```

## 5. UI上のエラー表示パターン

### 5.1. エラー表示コンポーネント

#### 5.1.1. スナックバー

軽微なエラーや通知に使用します。

```dart
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      action: SnackBarAction(
        label: context.l10n.retry,
        textColor: Colors.white,
        onPressed: () {
          // リトライアクション
        },
      ),
    ),
  );
}
```

#### 5.1.2. ダイアログ

ユーザーの注意が必要な重要なエラーに使用します。

```dart
void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.ok),
        ),
      ],
    ),
  );
}
```

#### 5.1.3. エラー画面

回復不能な致命的エラー、または空の状態表示に使用します。

```dart
class ErrorView extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  
  const ErrorView({
    Key? key,
    required this.message,
    this.buttonText,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(buttonText ?? context.l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 5.2. フォームエラー表示

フォーム入力のバリデーションエラーを表示します。

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: context.l10n.emailAddress,
    errorText: _emailError,
    // エラー時のスタイル設定
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2,
      ),
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return context.l10n.emailRequired;
    }
    if (!EmailValidator.validate(value)) {
      return context.l10n.emailInvalid;
    }
    return null;
  },
  onSaved: (value) {
    _email = value;
  },
)
```

## 6. オフラインモード対応

### 6.1. オフライン検出

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final BehaviorSubject<bool> _isConnected = BehaviorSubject.seeded(true);

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Stream<bool> get isConnected => _isConnected.stream;
  bool get isConnectedValue => _isConnected.value;

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnected.add(false);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _isConnected.add(result != ConnectivityResult.none);
  }

  void dispose() {
    _isConnected.close();
  }
}
```

### 6.2. オフラインデータ同期

```dart
class SyncService {
  final FirebaseFirestore _firestore;
  final Box<PendingOperation> _pendingOperationsBox;
  final ConnectivityService _connectivityService;
  
  SyncService(this._firestore, this._pendingOperationsBox, this._connectivityService) {
    _connectivityService.isConnected.listen((isConnected) {
      if (isConnected) {
        _processPendingOperations();
      }
    });
  }
  
  Future<void> addPendingOperation(PendingOperation operation) async {
    await _pendingOperationsBox.add(operation);
  }
  
  Future<void> _processPendingOperations() async {
    if (_pendingOperationsBox.isEmpty) return;
    
    for (var i = 0; i < _pendingOperationsBox.length; i++) {
      final operation = _pendingOperationsBox.getAt(i);
      if (operation == null) continue;
      
      try {
        switch (operation.type) {
          case OperationType.create:
            await _firestore
                .collection(operation.collection)
                .doc(operation.documentId)
                .set(operation.data);
            break;
          case OperationType.update:
            await _firestore
                .collection(operation.collection)
                .doc(operation.documentId)
                .update(operation.data);
            break;
          case OperationType.delete:
            await _firestore
                .collection(operation.collection)
                .doc(operation.documentId)
                .delete();
            break;
        }
        
        // 成功したら操作を削除
        await _pendingOperationsBox.deleteAt(i);
        i--; // インデックスを調整
      } catch (e) {
        // エラーが発生した場合はスキップして次へ
        continue;
      }
    }
  }
}
```

## 7. クラッシュレポートとロギング

### 7.1. Firebase Crashlytics の設定

```dart
Future<void> initializeCrashlytics() async {
  await Firebase.initializeApp();
  
  // Crashlyticsの初期化
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode // デバッグモードでは無効化
  );
  
  // FlutterエラーをCrashlyticsに送信
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  // Zone内の非同期エラーを捕捉
  runZonedGuarded<Future<void>>(() async {
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
```

### 7.2. カスタムログとエラー報告

```dart
class LoggingService {
  final FirebaseCrashlytics _crashlytics;
  final FirebaseAnalytics _analytics;
  
  LoggingService(this._crashlytics, this._analytics);
  
  // ユーザー情報の設定
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
    await _analytics.setUserId(id: userId);
  }
  
  // エラーログ
  Future<void> logError(String message, dynamic error, StackTrace? stack) async {
    // デバッグログ
    log(message, error: error, stackTrace: stack);
    
    // Crashlyticsへの非致命的エラー報告
    await _crashlytics.recordError(
      error,
      stack,
      reason: message,
      fatal: false,
    );
    
    // Analyticsへのエラーイベント記録
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': message,
        'error_details': error.toString(),
      },
    );
  }
  
  // カスタムキーの記録
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }
}
```

### 7.3. デバッグモードでの詳細ロギング

```dart
class DebugLogger {
  static bool _enabled = kDebugMode;
  
  static void enable() {
    _enabled = true;
  }
  
  static void disable() {
    _enabled = false;
  }
  
  static void log(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_enabled) return;
    
    final now = DateTime.now().toIso8601String();
    final prefix = tag != null ? '[$tag]' : '';
    
    // 標準ログ出力
    debugPrint('$now $prefix $message');
    
    // エラーがある場合は詳細出力
    if (error != null) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
  
  static void network(String url, {String? method, int? statusCode, Object? body}) {
    if (!_enabled) return;
    
    final methodStr = method != null ? '[$method]' : '';
    final statusStr = statusCode != null ? 'Status: $statusCode' : '';
    
    debugPrint('🌐 Network $methodStr $url $statusStr');
    if (body != null) {
      debugPrint('Body: $body');
    }
  }
}
```

## 8. デバッグとトラブルシューティング

### 8.1. 開発者モード

```dart
class DevModeManager {
  static const _devModeEnabledKey = 'dev_mode_enabled';
  static final _prefs = SharedPreferences.getInstance();
  
  static final _devModeSubject = BehaviorSubject<bool>.seeded(false);
  static Stream<bool> get devModeStream => _devModeSubject.stream;
  static bool get isDevModeEnabled => _devModeSubject.value;
  
  static Future<void> initialize() async {
    final prefs = await _prefs;
    final isEnabled = prefs.getBool(_devModeEnabledKey) ?? false;
    _devModeSubject.add(isEnabled);
  }
  
  static Future<void> setDevModeEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_devModeEnabledKey, enabled);
    _devModeSubject.add(enabled);
    
    if (enabled) {
      DebugLogger.enable();
    } else {
      DebugLogger.disable();
    }
  }
  
  static Future<void> toggleDevMode() async {
    await setDevModeEnabled(!isDevModeEnabled);
  }
}
```

### 8.2. デバッグ画面

```dart
class DebugMenuScreen extends StatelessWidget {
  const DebugMenuScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デバッグメニュー')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('開発者モード'),
            value: DevModeManager.isDevModeEnabled,
            onChanged: (value) => DevModeManager.setDevModeEnabled(value),
          ),
          ListTile(
            title: const Text('キャッシュをクリア'),
            onTap: () async {
              await context.read<CacheManager>().clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('キャッシュをクリアしました')),
              );
            },
          ),
          ListTile(
            title: const Text('エラーを模擬発生'),
            subtitle: const Text('テスト用にエラーを発生させます'),
            onTap: () {
              throw Exception('手動で発生させたテストエラー');
            },
          ),
          ListTile(
            title: const Text('ネットワークログ表示'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NetworkLogScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('環境情報'),
            subtitle: Text('環境: ${kDebugMode ? 'デバッグ' : '本番'}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const EnvironmentInfoDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 8.3. エラーシミュレーション

```dart
class ErrorSimulator {
  static void simulateNetworkError() {
    throw const SocketException('Simulated network error');
  }
  
  static void simulateTimeoutError() {
    throw TimeoutException('Simulated timeout error', const Duration(seconds: 10));
  }
  
  static void simulateAuthError() {
    throw FirebaseAuthException(
      code: 'user-not-found',
      message: 'Simulated authentication error',
    );
  }
  
  static void simulateFirestoreError() {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'Simulated Firestore permission error',
    );
  }
  
  static void simulateCrash() {
    throw Exception('Simulated crash for testing');
  }
}
```

## 9. アプリケーション例外クラス

### 9.1. 基本例外クラス

```dart
class AppException implements Exception {
  final String code;
  final String message;
  final dynamic originalException;
  final StackTrace? stackTrace;
  
  const AppException({
    required this.code,
    required this.message,
    this.originalException,
    this.stackTrace,
  });
  
  @override
  String toString() => 'AppException($code): $message';
  
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'originalException': originalException?.toString(),
    };
  }
}
```

### 9.2. 派生例外クラス

```dart
class NetworkException extends AppException {
  const NetworkException({
    required String code,
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    code: code,
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );
  
  factory NetworkException.noConnection() {
    return const NetworkException(
      code: 'GJ-NET-001',
      message: 'インターネット接続がありません。Wi-Fiまたはモバイルデータをご確認ください。',
    );
  }
  
  factory NetworkException.timeout() {
    return const NetworkException(
      code: 'GJ-NET-002',
      message: 'サーバーとの通信がタイムアウトしました。後ほど再試行してください。',
    );
  }
}

class AuthException extends AppException {
  const AuthException({
    required String code,
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    code: code,
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );
  
  factory AuthException.invalidCredentials() {
    return const AuthException(
      code: 'GJ-AUTH-001',
      message: 'メールアドレスまたはパスワードが正しくありません。',
    );
  }
  
  factory AuthException.sessionExpired() {
    return const AuthException(
      code: 'GJ-AUTH-002',
      message: 'ログインセッションが期限切れです。再度ログインしてください。',
    );
  }
}

class DataException extends AppException {
  const DataException({
    required String code,
    required String message,
    dynamic originalException,
    StackTrace? stackTrace,
  }) : super(
    code: code,
    message: message,
    originalException: originalException,
    stackTrace: stackTrace,
  );
  
  factory DataException.validationFailed(String details) {
    return DataException(
      code: 'GJ-DATA-001',
      message: '入力データが無効です: $details',
    );
  }
  
  factory DataException.notFound() {
    return const DataException(
      code: 'GJ-DATA-004',
      message: 'データが見つかりませんでした。',
    );
  }
}
```

## 10. 開発プロセスとエラー対応ガイドライン

### 10.1. 新機能開発時のエラー対策

1. 新機能を開発する際は、以下のエラーケースを必ず検討し対応する：
   - ネットワーク接続がない場合
   - バックエンドサービスが利用できない場合
   - ユーザー入力が無効な場合
   - 必要な権限が不足している場合
   - デバイスリソースが不足している場合

2. すべての外部リソースアクセス（ネットワーク、ファイル、デバイス機能）は try-catch または Result パターンで包む

3. ローディング状態、エラー状態、空の状態をすべて考慮したUI設計を行う

### 10.2. コードレビュー時のエラーハンドリングチェックリスト

- [ ] すべての外部リソースアクセスにエラーハンドリングが実装されているか
- [ ] 適切なエラー種別とエラーコードが使用されているか
- [ ] ユーザーに分かりやすいエラーメッセージが提供されているか
- [ ] エラー発生時の回復パスやフォールバックが提供されているか
- [ ] 開発者用のログが十分に記録されているか
- [ ] クラッシュや致命的なエラーが適切に報告されるか

### 10.3. リリース前の検証項目

- オフラインモードでの動作確認
- 不安定なネットワーク環境でのテスト
- サーバーエラー応答のシミュレーションテスト
- 無効な入力データのバリデーションテスト
- リソース制約（ディスク容量不足、メモリ不足）のシミュレーション
- 実機での動作確認（特に古いOSバージョンや低スペックデバイス） 