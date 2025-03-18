# GastronomeJourney 状態管理設計書

## 1. 基本方針

GastronomeJourneyアプリケーションでは、状態管理に以下の方針を採用します：

1. **宣言的UI**: UI状態と表示ロジックの明確な分離
2. **単方向データフロー**: データは常に一方向に流れるようにし、予測可能性を高める
3. **局所性**: 状態は可能な限り使用される場所に近く配置する
4. **不変性**: 状態は直接変更せず、新しい状態を生成する
5. **テスト容易性**: すべての状態変化は単体テスト可能である

## 2. 状態管理アーキテクチャ

### 2.1. 層の定義

GastronomeJourneyでは、状態管理を以下の層に分けて実装します：

1. **プレゼンテーション層**: UIコンポーネントと状態の利用
2. **状態管理層**: ビジネスロジックとデータの状態管理
3. **データアクセス層**: リポジトリとデータソースへのアクセス
4. **ドメイン層**: ビジネスロジックとモデル定義

### 2.2. アーキテクチャの概要図

```
┌─────────────────────────────────────────┐
│ プレゼンテーション層 (UI)                 │
│ ┌─────────────┐  ┌─────────────┐       │
│ │ Screens     │  │ Widgets     │       │
│ └─────────────┘  └─────────────┘       │
└───────────────────┬─────────────────────┘
                    │ 状態の購読・アクション発行
                    ▼
┌─────────────────────────────────────────┐
│ 状態管理層                               │
│ ┌─────────────┐  ┌─────────────┐       │
│ │ Providers   │  │ Notifiers   │       │
│ └─────────────┘  └─────────────┘       │
└───────────────────┬─────────────────────┘
                    │ データの取得・更新リクエスト
                    ▼
┌─────────────────────────────────────────┐
│ データアクセス層                         │
│ ┌─────────────┐  ┌─────────────┐       │
│ │ Repositories│  │ Services    │       │
│ └─────────────┘  └─────────────┘       │
└───────────────────┬─────────────────────┘
                    │ データの操作
                    ▼
┌─────────────────────────────────────────┐
│ ドメイン層                               │
│ ┌─────────────┐  ┌─────────────┐       │
│ │ Models      │  │ Entities    │       │
│ └─────────────┘  └─────────────┘       │
└─────────────────────────────────────────┘
```

## 3. Riverpod の概要と使用方針

### 3.1. Riverpod の選定理由

GastronomeJourneyでは、状態管理フレームワークとしてRiverpod（flutter_riverpod）を採用しています。その主な理由は以下の通りです：

1. **コンパイル時の安全性**: Providerはコンパイルタイムにチェックされるためランタイムエラーが少ない
2. **依存関係の自動解決**: Providerの依存関係が自動的に解決される
3. **きめ細かな再構築**: 必要なWidgetのみを再構築する効率的な仕組み
4. **テスト容易性**: Providerは簡単にオーバーライドでき、テストが書きやすい
5. **非同期サポート**: 非同期データの取得と状態管理が簡潔に書ける

### 3.2. Riverpod のバージョンと機能

- Riverpod 2.x を使用 (flutter_riverpod: ^2.3.6)
- Code generationを活用 (riverpod_generator: ^2.2.3)
- アノテーションベースのProvider定義を採用

### 3.3. Provider の種類と使い分け

| Provider 種類 | 主な用途 | 特徴 |
|--------------|---------|-----|
| **Provider** | 静的な値や他のProviderから計算される値 | 単純、変更不可 |
| **StateProvider** | 単純な状態 (bool, int, enum など) | 簡潔、単純な状態に最適 |
| **FutureProvider** | 非同期で取得するデータ | 非同期データの取得と状態管理 |
| **StreamProvider** | Streamから取得するデータ | リアルタイム更新データに最適 |
| **StateNotifierProvider** | 複雑な状態とロジック | 状態と変更ロジックをカプセル化 |
| **NotifierProvider** | 最新のRiverpodでの状態管理 | クラスベースのアプローチ |
| **AsyncNotifierProvider** | 非同期操作を含む複雑な状態 | 非同期ロジックを含む状態管理 |

### 3.4. コード生成を用いた Provider 定義パターン

```dart
// 1. 単純なProvider
@riverpod
String appVersion(AppVersionRef ref) {
  return '1.0.0';
}

// 2. FutureProvider
@riverpod
Future<List<IzakayaModel>> publicIzakayas(PublicIzakayasRef ref) async {
  final repository = ref.watch(izakayaRepositoryProvider);
  return repository.getPublicIzakayas();
}

// 3. Notifier (StateNotifierの代替)
@riverpod
class IzakayaFilterNotifier extends _$IzakayaFilterNotifier {
  @override
  IzakayaFilter build() {
    return const IzakayaFilter(); // デフォルト値
  }
  
  void updateBudgetRange(RangeValues range) {
    state = state.copyWith(budgetRange: range);
  }
  
  void updateGenre(String genre) {
    state = state.copyWith(
      selectedGenres: state.selectedGenres.contains(genre)
          ? state.selectedGenres.where((g) => g != genre).toList()
          : [...state.selectedGenres, genre],
    );
  }
  
  void reset() {
    state = const IzakayaFilter();
  }
}

// 4. AsyncNotifier
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<UserModel?> build() async {
    final authService = ref.watch(authServiceProvider);
    return authService.getCurrentUser();
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(email, password);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

## 4. 状態の種類と管理方法

### 4.1. 状態の分類

GastronomeJourneyアプリケーションでは、状態を以下のように分類します：

1. **アプリケーション状態**: アプリ全体で共有される状態（認証情報、テーマ設定など）
2. **画面状態**: 特定の画面に関連する状態（フォーム入力、ページ状態など）
3. **UIコンポーネント状態**: 特定のUIコンポーネント内部の状態（アニメーション状態、展開/折りたたみ状態など）
4. **エフェメラル状態**: 一時的な状態（スクロール位置、フォーカス状態など）

### 4.2. 状態の配置ガイドライン

| 状態の種類 | 配置場所 | 推奨Provider |
|----------|---------|-------------|
| アプリケーション状態 | グローバルProvider | NotifierProvider, AsyncNotifierProvider |
| 画面状態 | 画面スコープのProvider | NotifierProvider, FutureProvider |
| UIコンポーネント状態 | ローカルスコープのProvider/StatefulWidget | StateProvider, Consumer内のStateNotifier |
| エフェメラル状態 | StatefulWidget内部 | setState |

### 4.3. 状態の依存関係

Riverpodでは、Provider間の依存関係を明示的に宣言できます。以下のルールに従って状態間の依存関係を管理してください：

1. サイクリック依存を避ける（A→B→C→Aのような循環参照を作らない）
2. 依存方向は高レベル→低レベルの方向とする（プレゼンテーション→状態管理→データアクセスの方向）
3. 異なるドメイン間の依存関係は最小限に抑える

例：
```dart
@riverpod
Future<List<IzakayaModel>> filteredIzakayas(FilteredIzakayasRef ref) async {
  // 依存関係の宣言
  final filter = ref.watch(izakayaFilterNotifierProvider);
  final izakayas = await ref.watch(publicIzakayasProvider.future);
  
  // フィルター適用ロジック
  return izakayas.where((izakaya) {
    // 予算範囲のフィルタリング
    final inBudgetRange = izakaya.budget >= filter.budgetRange.start && 
                         izakaya.budget <= filter.budgetRange.end;
    
    // ジャンルのフィルタリング
    final genreMatches = filter.selectedGenres.isEmpty || 
                        filter.selectedGenres.contains(izakaya.genre);
    
    return inBudgetRange && genreMatches;
  }).toList();
}
```

## 5. 状態管理の実装パターン

### 5.1. CRUD操作の実装パターン

データのCRUD操作を実装する際の基本パターンは以下の通りです：

#### 5.1.1. 作成操作 (Create)

```dart
@riverpod
class IzakayaListNotifier extends _$IzakayaListNotifier {
  @override
  Future<List<IzakayaModel>> build() async {
    final repository = ref.watch(izakayaRepositoryProvider);
    return repository.getUserIzakayas();
  }
  
  Future<void> addIzakaya(IzakayaModel izakaya) async {
    final repository = ref.read(izakayaRepositoryProvider);
    
    // 楽観的UI更新（すぐに結果を反映）
    state = AsyncData([...state.value ?? [], izakaya]);
    
    try {
      // 実際のデータ保存
      await repository.addIzakaya(izakaya);
      // 必要に応じてデータを再取得（IDなどが更新される場合）
      await invalidateSelf();
    } catch (e, stack) {
      // エラー発生時は状態を元に戻すか、エラー状態に更新
      state = AsyncError(e, stack);
      rethrow;
    }
  }
  
  Future<void> invalidateSelf() async {
    ref.invalidateSelf();
  }
}
```

#### 5.1.2. 読み込み操作 (Read)

```dart
// 単一アイテムの取得
@riverpod
Future<IzakayaModel?> izakayaById(IzakayaByIdRef ref, String id) async {
  final repository = ref.watch(izakayaRepositoryProvider);
  return repository.getIzakayaById(id);
}

// リアルタイム更新が必要な場合
@riverpod
Stream<IzakayaModel?> izakayaByIdStream(IzakayaByIdStreamRef ref, String id) {
  final repository = ref.watch(izakayaRepositoryProvider);
  return repository.watchIzakayaById(id);
}
```

#### 5.1.3. 更新操作 (Update)

```dart
@riverpod
class IzakayaDetailNotifier extends _$IzakayaDetailNotifier {
  @override
  Future<IzakayaModel?> build(String id) async {
    final repository = ref.watch(izakayaRepositoryProvider);
    return repository.getIzakayaById(id);
  }
  
  Future<void> updateIzakaya(IzakayaModel updatedIzakaya) async {
    if (state.value == null) return;
    
    final repository = ref.read(izakayaRepositoryProvider);
    
    // 楽観的UI更新
    state = AsyncData(updatedIzakaya);
    
    try {
      // 実際のデータ更新
      await repository.updateIzakaya(updatedIzakaya);
      
      // 関連する他のプロバイダの更新
      ref.invalidate(izakayaListNotifierProvider);
    } catch (e, stack) {
      // エラー処理
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}
```

#### 5.1.4. 削除操作 (Delete)

```dart
Future<void> deleteIzakaya(String id) async {
  if (state.value == null) return;
  
  final repository = ref.read(izakayaRepositoryProvider);
  final originalList = state.value ?? [];
  
  // 楽観的UI更新
  state = AsyncData(originalList.where((item) => item.id != id).toList());
  
  try {
    // 実際のデータ削除
    await repository.deleteIzakaya(id);
  } catch (e, stack) {
    // エラー発生時は元に戻す
    state = AsyncData(originalList);
    state = AsyncError(e, stack);
    rethrow;
  }
}
```

### 5.2. 非同期処理の実装パターン

#### 5.2.1. データ取得の実装

```dart
@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  Future<UserProfileModel?> build() async {
    final authService = ref.watch(authServiceProvider);
    final user = await authService.getCurrentUser();
    if (user == null) return null;
    
    final repository = ref.watch(userRepositoryProvider);
    return repository.getUserProfile(user.uid);
  }
  
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
```

#### 5.2.2. ページネーションの実装

```dart
@riverpod
class PaginatedIzakayaListNotifier extends _$PaginatedIzakayaListNotifier {
  static const _pageSize = 20;
  
  @override
  Future<PaginatedData<IzakayaModel>> build() async {
    return _fetchPage(0);
  }
  
  Future<PaginatedData<IzakayaModel>> _fetchPage(int page) async {
    final repository = ref.read(izakayaRepositoryProvider);
    final result = await repository.getIzakayas(
      page: page,
      pageSize: _pageSize,
    );
    return result;
  }
  
  Future<void> loadNextPage() async {
    if (state.value == null) return;
    
    final currentPage = state.value!.currentPage;
    final hasMore = state.value!.hasMore;
    
    if (!hasMore) return;
    
    state = const AsyncValue.loading();
    try {
      final nextPage = await _fetchPage(currentPage + 1);
      state = AsyncValue.data(nextPage);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

#### 5.2.3. リアルタイム更新の実装

```dart
@riverpod
Stream<List<IzakayaModel>> nearbyIzakayasStream(
  NearbyIzakayasStreamRef ref,
  GeoPoint location,
  double radius,
) {
  final repository = ref.watch(izakayaRepositoryProvider);
  return repository.watchNearbyIzakayas(location, radius);
}
```

### 5.3. フォーム状態管理

```dart
@riverpod
class IzakayaFormNotifier extends _$IzakayaFormNotifier {
  @override
  IzakayaFormState build() {
    return const IzakayaFormState();
  }
  
  void updateName(String name) {
    state = state.copyWith(
      name: name,
      nameError: _validateName(name),
    );
  }
  
  void updateAddress(String address) {
    state = state.copyWith(
      address: address,
      addressError: _validateAddress(address),
    );
  }
  
  Future<void> submit() async {
    if (!state.isValid) return;
    
    state = state.copyWith(isSubmitting: true);
    try {
      final repository = ref.read(izakayaRepositoryProvider);
      await repository.createIzakaya(state.toModel());
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (e, stack) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }
  
  String? _validateName(String name) {
    if (name.isEmpty) return '店舗名を入力してください';
    if (name.length > 50) return '店舗名は50文字以内で入力してください';
    return null;
  }
  
  String? _validateAddress(String address) {
    if (address.isEmpty) return '住所を入力してください';
    return null;
  }
}
```

## 6. UI との統合

### 6.1. 基本的な使用方法

```dart
class IzakayaListScreen extends ConsumerWidget {
  const IzakayaListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final izakayasAsync = ref.watch(izakayaListNotifierProvider);
    
    return izakayasAsync.when(
      data: (izakayas) => ListView.builder(
        itemCount: izakayas.length,
        itemBuilder: (context, index) {
          final izakaya = izakayas[index];
          return IzakayaCard(izakaya: izakaya);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }
}
```

### 6.2. 状態変更のトリガー

```dart
class IzakayaDetailScreen extends ConsumerWidget {
  const IzakayaDetailScreen({
    super.key,
    required this.izakayaId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final izakayaAsync = ref.watch(izakayaDetailNotifierProvider(izakayaId));
    
    return izakayaAsync.when(
      data: (izakaya) => izakaya == null
          ? const Center(child: Text('店舗が見つかりません'))
          : Scaffold(
              body: IzakayaDetailView(izakaya: izakaya),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // 状態変更のトリガー
                  ref.read(izakayaDetailNotifierProvider(izakayaId).notifier)
                     .toggleFavorite();
                },
                child: Icon(
                  izakaya.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('エラーが発生しました: $error'),
      ),
    );
  }
}
```

### 6.3. フォームの実装

```dart
class IzakayaFormScreen extends ConsumerWidget {
  const IzakayaFormScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(izakayaFormNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('新規店舗登録')),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: formState.name,
              decoration: InputDecoration(
                labelText: '店舗名',
                errorText: formState.nameError,
              ),
              onChanged: (value) {
                ref.read(izakayaFormNotifierProvider.notifier)
                   .updateName(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: formState.address,
              decoration: InputDecoration(
                labelText: '住所',
                errorText: formState.addressError,
              ),
              onChanged: (value) {
                ref.read(izakayaFormNotifierProvider.notifier)
                   .updateAddress(value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isValid && !formState.isSubmitting
                  ? () {
                      ref.read(izakayaFormNotifierProvider.notifier)
                         .submit();
                    }
                  : null,
              child: formState.isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 7. テスト戦略

### 7.1. Provider のテスト

```dart
void main() {
  group('IzakayaListNotifier', () {
    late ProviderContainer container;
    late MockIzakayaRepository mockRepository;
    
    setUp(() {
      mockRepository = MockIzakayaRepository();
      container = ProviderContainer(
        overrides: [
          izakayaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('初期状態は空のリスト', () {
      final notifier = container.read(izakayaListNotifierProvider.notifier);
      expect(notifier.state.value, isEmpty);
    });
    
    test('店舗の追加が成功する', () async {
      final izakaya = IzakayaModel(
        id: '1',
        name: 'テスト店舗',
        // ... 他の必要なフィールド
      );
      
      when(mockRepository.addIzakaya(any))
          .thenAnswer((_) async => izakaya);
      
      final notifier = container.read(izakayaListNotifierProvider.notifier);
      await notifier.addIzakaya(izakaya);
      
      expect(notifier.state.value, contains(izakaya));
      verify(mockRepository.addIzakaya(izakaya)).called(1);
    });
  });
}
```

### 7.2. 統合テスト

```dart
void main() {
  group('Izakaya CRUD Flow', () {
    late ProviderContainer container;
    late MockIzakayaRepository mockRepository;
    
    setUp(() {
      mockRepository = MockIzakayaRepository();
      container = ProviderContainer(
        overrides: [
          izakayaRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('店舗の作成から表示までのフロー', () async {
      // 1. 店舗の作成
      final newIzakaya = IzakayaModel(
        id: '1',
        name: '新規店舗',
        // ... 他の必要なフィールド
      );
      
      when(mockRepository.addIzakaya(any))
          .thenAnswer((_) async => newIzakaya);
      
      await container.read(izakayaListNotifierProvider.notifier)
                     .addIzakaya(newIzakaya);
      
      // 2. リストの取得
      when(mockRepository.getUserIzakayas())
          .thenAnswer((_) async => [newIzakaya]);
      
      final listNotifier = container.read(izakayaListNotifierProvider.notifier);
      await listNotifier.invalidateSelf();
      
      // 3. 検証
      expect(listNotifier.state.value, contains(newIzakaya));
    });
  });
}
```

## 8. パフォーマンス最適化

### 8.1. 不要な再構築の防止

```dart
// 1. select を使用した部分的な監視
final name = ref.watch(izakayaDetailNotifierProvider(izakayaId)
    .select((value) => value.name));

// 2. const コンストラクタの活用
const IzakayaCard({required this.izakaya});

// 3. メモ化された値の使用
@riverpod
List<IzakayaModel> filteredIzakayas(FilteredIzakayasRef ref) {
  final filter = ref.watch(izakayaFilterNotifierProvider);
  final izakayas = ref.watch(izakayaListNotifierProvider).value ?? [];
  
  return useMemoized(() {
    return izakayas.where((izakaya) {
      return filter.matches(izakaya);
    }).toList();
  }, [izakayas, filter]);
}
```

### 8.2. キャッシュ戦略

```dart
@riverpod
Future<IzakayaModel?> izakayaById(IzakayaByIdRef ref, String id) async {
  final repository = ref.watch(izakayaRepositoryProvider);
  
  // キャッシュの有効期限を設定
  ref.keepAlive();
  
  return repository.getIzakayaById(id);
}

// キャッシュの手動制御
void clearCache(WidgetRef ref) {
  ref.invalidate(izakayaByIdProvider);
  ref.invalidate(izakayaListNotifierProvider);
}
```

## 9. デバッグと開発支援

### 9.1. デバッグ用の拡張機能

```dart
// Provider の値をログ出力
void debugProvider(ProviderRef ref, String providerName) {
  ref.listen<dynamic>(
    providerName,
    (previous, next) {
      debugPrint('$providerName changed: $next');
    },
  );
}

// 状態変更の追跡
@riverpod
class DebugNotifier extends _$DebugNotifier {
  @override
  void build() {
    ref.onDispose(() {
      debugPrint('DebugNotifier disposed');
    });
  }
  
  void logStateChange(String message) {
    debugPrint('State change: $message');
  }
}
```

### 9.2. 開発者向けツール

```dart
class DevTools extends ConsumerWidget {
  const DevTools({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Provider の状態'),
            onTap: () {
              // Provider の状態を表示
              showDialog(
                context: context,
                builder: (context) => const ProviderDebugDialog(),
              );
            },
          ),
          ListTile(
            title: const Text('キャッシュのクリア'),
            onTap: () {
              // キャッシュをクリア
              ref.read(debugNotifierProvider.notifier)
                 .clearAllCaches();
            },
          ),
        ],
      ),
    );
  }
}
``` 