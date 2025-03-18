# GastronomeJourney テスト仕様書

## 1. テスト戦略概要

本ドキュメントは、GastronomeJourneyアプリのテスト戦略と具体的なテスト仕様を定義します。テストは以下の3つのレベルで実施します：

1. **単体テスト**: 個々のクラスやメソッドの機能を検証
2. **結合テスト**: 複数のモジュール間の連携を検証
3. **UIテスト**: ユーザーインターフェースと全体的な機能を検証

## 2. テスト環境

### 2.1. テスト環境構成

- **開発環境**: ローカル開発環境でのテスト実行
- **テスト環境**: Firebase Emulatorを使用した分離環境
- **CI環境**: GitHub Actionsを使用した自動テスト

### 2.2. テストデータ

- テスト用のモックデータセット
- テスト専用のFirebase Projectを使用
- テスト実行前後にデータをクリーンアップする仕組み

## 3. 単体テスト仕様

### 3.1. テスト対象

以下のコンポーネントが単体テストの対象となります：

- **Model クラス**: すべてのデータモデル
- **Repository クラス**: Firestoreとのデータやり取り
- **Service クラス**: ビジネスロジック
- **Provider/Notifier クラス**: 状態管理ロジック
- **Utility クラス**: 共通ユーティリティ関数

### 3.2. テスト範囲と基準

- **コードカバレッジ目標**: 80%以上
- **必須テスト項目**:
  - すべてのパブリックメソッド
  - 複雑なロジックを含むプライベートメソッド
  - エラーハンドリングパス
  - エッジケース処理

### 3.3. モックとスタブ

- Firebaseサービスは `mocktail` を使用してモック化
- ネットワーク依存のコードは適切にスタブ化
- 外部サービス依存部分はインターフェースを通して参照し、テスト時に差し替え可能に

### 3.4. テストケース例

#### 3.4.1. モデルクラステスト (例: IzakayaModel)

```dart
void main() {
  group('IzakayaModel Tests', () {
    test('should create a valid model from JSON', () {
      // Setup
      final json = {
        'id': 'test123',
        'name': 'テスト居酒屋',
        'address': '東京都渋谷区',
        'budget': 3000,
        'genre': '和食',
        'isPublic': true,
        'userId': 'user123',
        'createdAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
      };
      
      // Execute
      final model = IzakayaModel.fromJson(json);
      
      // Verify
      expect(model.id, 'test123');
      expect(model.name, 'テスト居酒屋');
      expect(model.budget, 3000);
      expect(model.isPublic, true);
    });
    
    test('should convert model to JSON correctly', () {
      // Setup
      final model = IzakayaModel(
        id: 'test123',
        name: 'テスト居酒屋',
        address: '東京都渋谷区',
        budget: 3000,
        genre: '和食',
        isPublic: true,
        userId: 'user123',
        createdAt: DateTime(2023, 5, 1),
        updatedAt: DateTime(2023, 5, 1),
      );
      
      // Execute
      final json = model.toJson();
      
      // Verify
      expect(json['id'], 'test123');
      expect(json['name'], 'テスト居酒屋');
      expect(json['budget'], 3000);
      expect(json['isPublic'], true);
    });
    
    test('should handle optional fields', () {
      // Setup
      final json = {
        'id': 'test123',
        'name': 'テスト居酒屋',
        'address': '東京都渋谷区',
        'budget': 3000,
        'genre': '和食',
        'isPublic': true,
        'userId': 'user123',
        'createdAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
        // Optional fields missing
      };
      
      // Execute
      final model = IzakayaModel.fromJson(json);
      
      // Verify
      expect(model.phone, isNull);
      expect(model.businessHours, isNull);
      expect(model.holidays, isNull);
      expect(model.images, isEmpty);
    });
  });
}
```

#### 3.4.2. リポジトリテスト (例: IzakayaRepository)

```dart
@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, QuerySnapshot])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late IzakayaRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    
    when(() => mockFirestore.collection('izakayas'))
        .thenReturn(mockCollection);
    when(() => mockCollection.doc(any()))
        .thenReturn(mockDocument);
    
    repository = IzakayaRepository(firestore: mockFirestore);
  });

  group('IzakayaRepository Tests', () {
    test('should add new izakaya', () async {
      // Setup
      final izakaya = IzakayaModel(
        name: 'テスト居酒屋',
        address: '東京都渋谷区',
        budget: 3000,
        genre: '和食',
        isPublic: true,
        userId: 'user123',
      );
      
      when(() => mockDocument.set(any()))
          .thenAnswer((_) => Future.value());
      
      // Execute
      await repository.addIzakaya(izakaya);
      
      // Verify
      verify(() => mockCollection.doc(any())).called(1);
      verify(() => mockDocument.set(any())).called(1);
    });
    
    test('should get izakaya by id', () async {
      // Setup
      final mockSnapshot = MockDocumentSnapshot();
      final mockData = {
        'id': 'test123',
        'name': 'テスト居酒屋',
        'address': '東京都渋谷区',
        'budget': 3000,
        'genre': '和食',
        'isPublic': true,
        'userId': 'user123',
        'createdAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 5, 1)),
      };
      
      when(() => mockDocument.get())
          .thenAnswer((_) => Future.value(mockSnapshot));
      when(() => mockSnapshot.data())
          .thenReturn(mockData);
      when(() => mockSnapshot.id).thenReturn('test123');
      when(() => mockSnapshot.exists).thenReturn(true);
      
      // Execute
      final result = await repository.getIzakayaById('test123');
      
      // Verify
      expect(result, isNotNull);
      expect(result!.id, 'test123');
      expect(result.name, 'テスト居酒屋');
    });
    
    test('should return null for non-existent izakaya', () async {
      // Setup
      final mockSnapshot = MockDocumentSnapshot();
      
      when(() => mockDocument.get())
          .thenAnswer((_) => Future.value(mockSnapshot));
      when(() => mockSnapshot.exists).thenReturn(false);
      
      // Execute
      final result = await repository.getIzakayaById('nonexistent');
      
      // Verify
      expect(result, isNull);
    });
    
    test('should get public izakayas', () async {
      // Setup - モックの詳細は省略
      
      // Execute
      final result = await repository.getPublicIzakayas();
      
      // Verify
      expect(result, isNotEmpty);
      expect(result.length, 2);
      expect(result[0].isPublic, true);
      expect(result[1].isPublic, true);
    });
    
    // エラーケースのテスト
    test('should handle errors gracefully', () async {
      // Setup
      when(() => mockDocument.get())
          .thenThrow(FirebaseException(plugin: 'firestore'));
      
      // Execute & Verify
      expect(
        () => repository.getIzakayaById('test123'),
        throwsA(isA<IzakayaRepositoryException>()),
      );
    });
  });
}
```

#### 3.4.3. Notifierテスト (例: IzakayaNotifier)

```dart
@GenerateMocks([IzakayaRepository])
void main() {
  late MockIzakayaRepository mockRepository;
  late ProviderContainer container;

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

  group('IzakayaNotifier Tests', () {
    test('should load public izakayas', () async {
      // Setup
      final izakayas = [
        IzakayaModel(
          id: 'test123',
          name: 'テスト居酒屋1',
          address: '東京都渋谷区',
          budget: 3000,
          genre: '和食',
          isPublic: true,
          userId: 'user123',
        ),
        IzakayaModel(
          id: 'test456',
          name: 'テスト居酒屋2',
          address: '東京都新宿区',
          budget: 4000,
          genre: '洋食',
          isPublic: true,
          userId: 'user456',
        ),
      ];
      
      when(() => mockRepository.getPublicIzakayas())
          .thenAnswer((_) => Future.value(izakayas));
      
      // Execute
      await container.read(izakayaNotifierProvider.notifier).loadPublicIzakayas();
      final state = container.read(izakayaNotifierProvider);
      
      // Verify
      expect(state.isLoading, false);
      expect(state.izakayas, equals(izakayas));
      expect(state.errorMessage, isNull);
    });
    
    test('should handle loading error', () async {
      // Setup
      when(() => mockRepository.getPublicIzakayas())
          .thenThrow(Exception('Network error'));
      
      // Execute
      await container.read(izakayaNotifierProvider.notifier).loadPublicIzakayas();
      final state = container.read(izakayaNotifierProvider);
      
      // Verify
      expect(state.isLoading, false);
      expect(state.izakayas, isEmpty);
      expect(state.errorMessage, isNotNull);
    });
    
    test('should add new izakaya', () async {
      // Setup
      final izakaya = IzakayaModel(
        name: '新しい居酒屋',
        address: '東京都中野区',
        budget: 2500,
        genre: '居酒屋',
        isPublic: true,
        userId: 'currentUser',
      );
      
      when(() => mockRepository.addIzakaya(any()))
          .thenAnswer((_) => Future.value());
      
      // Execute
      final success = await container.read(izakayaNotifierProvider.notifier)
          .addIzakaya(izakaya);
      
      // Verify
      expect(success, true);
      verify(() => mockRepository.addIzakaya(any())).called(1);
    });
  });
}
```

## 4. 結合テスト仕様

### 4.1. テスト対象

以下の機能間連携が結合テストの対象となります：

- **認証フロー**: サインアップ→ログイン→プロフィール編集
- **投稿フロー**: データ入力→画像アップロード→投稿保存→表示
- **検索フロー**: 検索条件入力→検索実行→結果表示
- **ブックマークフロー**: 投稿表示→ブックマーク追加→ブックマークリスト表示

### 4.2. テスト環境

- Firebase Emulatorを使用した統合テスト環境
- テスト専用のデータセット
- 実際のUIコンポーネントとFirebase連携を検証

### 4.3. テストケース例

#### 4.3.1. 認証フロー結合テスト

```dart
@GenerateMocks([Firebase, FirebaseAuth])
void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService authService;
  late UserRepository userRepository;

  setUpAll(() async {
    // Firebase Emulatorの設定
    await Firebase.initializeApp();
    // Firebase Emulator接続設定
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authService = AuthService(auth: mockAuth);
    userRepository = UserRepository(firestore: FirebaseFirestore.instance);
  });

  tearDown(() async {
    // テストデータのクリーンアップ
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
  });

  group('Authentication Flow Integration Tests', () {
    test('complete signup, login, and profile update flow', () async {
      // 1. サインアップ
      final email = 'test@example.com';
      final password = 'Test123!';
      final displayName = 'テストユーザー';
      
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      
      when(() => mockAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      )).thenAnswer((_) => Future.value(mockUserCredential));
      
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test_uid');
      
      final signupResult = await authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      expect(signupResult.success, true);
      
      // 2. ユーザープロフィール検証
      final userProfile = await userRepository.getUserProfile('test_uid');
      expect(userProfile, isNotNull);
      expect(userProfile!.displayName, displayName);
      
      // 3. ログアウト
      when(() => mockAuth.signOut())
          .thenAnswer((_) => Future.value());
      
      await authService.signOut();
      
      // 4. ログイン
      when(() => mockAuth.signInWithEmailAndPassword(
        email: email, 
        password: password,
      )).thenAnswer((_) => Future.value(mockUserCredential));
      
      final loginResult = await authService.signIn(
        email: email,
        password: password,
      );
      
      expect(loginResult.success, true);
      
      // 5. プロフィール更新
      final newDisplayName = '更新テストユーザー';
      await userRepository.updateUserProfile(
        'test_uid',
        {'displayName': newDisplayName},
      );
      
      final updatedProfile = await userRepository.getUserProfile('test_uid');
      expect(updatedProfile!.displayName, newDisplayName);
    });
  });
}
```

#### 4.3.2. 投稿フロー結合テスト

```dart
void main() {
  late IzakayaRepository izakayaRepository;
  late StorageService storageService;
  late IzakayaService izakayaService;

  setUpAll(() async {
    // Firebase Emulatorの設定
    await Firebase.initializeApp();
    // Firebase Emulator接続設定
  });

  setUp(() {
    izakayaRepository = IzakayaRepository(firestore: FirebaseFirestore.instance);
    storageService = StorageService(storage: FirebaseStorage.instance);
    izakayaService = IzakayaService(
      repository: izakayaRepository,
      storageService: storageService,
    );
  });

  tearDown(() async {
    // テストデータのクリーンアップ
  });

  group('Izakaya Posting Flow Integration Tests', () {
    test('complete izakaya creation, image upload, and retrieval flow', () async {
      // 1. 居酒屋データ作成
      final izakaya = IzakayaModel(
        name: 'テスト居酒屋',
        address: '東京都渋谷区',
        budget: 3000,
        genre: '和食',
        isPublic: true,
        userId: 'test_user',
      );
      
      // 2. 画像データの準備（テスト用の画像ファイル）
      final testImage = File('test_resources/test_image.jpg');
      
      // 3. 画像アップロード
      final imageUrl = await storageService.uploadIzakayaImage(
        izakayaId: 'temp_id',
        userId: 'test_user',
        imageFile: testImage,
      );
      
      expect(imageUrl, isNotNull);
      expect(imageUrl, contains('izakayas/temp_id'));
      
      // 4. 画像URLを含む居酒屋データの保存
      final updatedIzakaya = izakaya.copyWith(
        images: [imageUrl],
      );
      
      final izakayaId = await izakayaRepository.addIzakaya(updatedIzakaya);
      expect(izakayaId, isNotNull);
      
      // 5. 保存したデータの取得と検証
      final savedIzakaya = await izakayaRepository.getIzakayaById(izakayaId);
      
      expect(savedIzakaya, isNotNull);
      expect(savedIzakaya!.name, 'テスト居酒屋');
      expect(savedIzakaya.images.length, 1);
      expect(savedIzakaya.images.first, imageUrl);
      
      // 6. 公開投稿一覧での確認
      final publicIzakayas = await izakayaRepository.getPublicIzakayas();
      
      expect(publicIzakayas, isNotEmpty);
      expect(publicIzakayas.any((i) => i.id == izakayaId), true);
    });
  });
}
```

## 5. UIテスト仕様

### 5.1. テスト対象

以下の画面とユーザーインタラクションがUIテストの対象となります：

- **認証画面**: サインアップ、ログイン、パスワードリセット
- **ホーム画面**: 投稿一覧表示、タブ切り替え、フィルタリング
- **詳細画面**: 居酒屋詳細表示、画像スワイプ、ブックマーク操作
- **投稿画面**: フォーム入力、バリデーション、画像選択、保存
- **プロフィール画面**: プロフィール表示、編集、投稿一覧
- **検索画面**: 検索条件入力、結果表示

### 5.2. テスト方法

- Flutter Integrationテストフレームワークを使用
- Widget Testingを活用したUIコンポーネントの検証
- ユーザーインタラクションのシミュレーション

### 5.3. テストケース例

#### 5.3.1. ログイン画面UIテスト

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Screen UI Tests', () {
    testWidgets('should show validation errors for empty fields', (WidgetTester tester) async {
      // 1. アプリの起動
      await tester.pumpWidget(const MyApp());
      
      // 2. ログイン画面への遷移（アプリ起動時のデフォルト画面として想定）
      await tester.pumpAndSettle();
      
      // 3. ログインボタンのタップ（空の状態）
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      
      // 4. バリデーションエラーメッセージの確認
      expect(find.text('メールアドレスを入力してください'), findsOneWidget);
      expect(find.text('パスワードを入力してください'), findsOneWidget);
      
      // 5. 無効なメールアドレスの入力
      await tester.enterText(
        find.byKey(const Key('emailField')), 
        'invalid-email'
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      
      expect(find.text('有効なメールアドレスを入力してください'), findsOneWidget);
      
      // 6. 短すぎるパスワードの入力
      await tester.enterText(
        find.byKey(const Key('emailField')), 
        'test@example.com'
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')), 
        '123'
      );
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();
      
      expect(find.text('パスワードは6文字以上必要です'), findsOneWidget);
    });
    
    testWidgets('should navigate to signup page', (WidgetTester tester) async {
      // 1. アプリの起動
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. サインアップへのリンクをタップ
      await tester.tap(find.byKey(const Key('signupLink')));
      await tester.pumpAndSettle();
      
      // 3. サインアップ画面の表示確認
      expect(find.text('アカウント作成'), findsOneWidget);
    });
    
    testWidgets('should navigate to password reset page', (WidgetTester tester) async {
      // 1. アプリの起動
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. パスワードリセットへのリンクをタップ
      await tester.tap(find.byKey(const Key('forgotPasswordLink')));
      await tester.pumpAndSettle();
      
      // 3. パスワードリセット画面の表示確認
      expect(find.text('パスワードのリセット'), findsOneWidget);
    });
  });
}
```

#### 5.3.2. 居酒屋投稿作成UIテスト

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Izakaya Post Creation UI Tests', () {
    testWidgets('should create new izakaya post with validation', (WidgetTester tester) async {
      // 前提条件: ログイン済み状態から開始
      
      // 1. アプリの起動と認証済み状態のセットアップ
      await tester.pumpWidget(const MyApp());
      
      // テスト用の認証状態をセットアップ
      await tester.pumpAndSettle();
      
      // 2. 新規投稿画面への遷移
      await tester.tap(find.byKey(const Key('newPostButton')));
      await tester.pumpAndSettle();
      
      // 3. タイトルが表示されていることを確認
      expect(find.text('居酒屋を投稿'), findsOneWidget);
      
      // 4. 空の状態で保存を試みる
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      
      // 5. バリデーションエラーの確認
      expect(find.text('店名を入力してください'), findsOneWidget);
      expect(find.text('住所を入力してください'), findsOneWidget);
      expect(find.text('予算を入力してください'), findsOneWidget);
      expect(find.text('ジャンルを選択してください'), findsOneWidget);
      
      // 6. 有効なデータの入力
      await tester.enterText(
        find.byKey(const Key('nameField')), 
        'テスト居酒屋'
      );
      await tester.enterText(
        find.byKey(const Key('addressField')), 
        '東京都渋谷区'
      );
      await tester.enterText(
        find.byKey(const Key('budgetField')), 
        '3000'
      );
      
      // 7. ジャンル選択のドロップダウンを開く
      await tester.tap(find.byKey(const Key('genreDropdown')));
      await tester.pumpAndSettle();
      
      // 8. ジャンルを選択
      await tester.tap(find.text('和食').last);
      await tester.pumpAndSettle();
      
      // 9. 公開設定の切り替え
      await tester.tap(find.byKey(const Key('publicSwitch')));
      await tester.pumpAndSettle();
      
      // 10. 画像追加ボタンをタップ（モック対応が必要）
      // 実際のテストでは、画像選択のモックが必要
      
      // 11. 保存ボタンをタップ
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pumpAndSettle();
      
      // 12. 保存成功後のホーム画面への遷移を確認
      expect(find.text('ホーム'), findsOneWidget);
      
      // 13. 作成した投稿が一覧に表示されていることを確認
      expect(find.text('テスト居酒屋'), findsOneWidget);
    });
  });
}
```

#### 5.3.3. 検索機能UIテスト

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Feature UI Tests', () {
    testWidgets('should search izakayas and filter results', (WidgetTester tester) async {
      // 前提条件: いくつかのサンプルデータが存在する状態
      
      // 1. アプリの起動
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      // 2. ログイン処理（省略）
      
      // 3. 検索画面への遷移
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // 4. キーワード検索の実行
      await tester.enterText(
        find.byKey(const Key('searchField')), 
        '和食'
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      
      // 5. 検索結果の確認
      expect(find.byKey(const Key('searchResultsList')), findsOneWidget);
      
      // 6. フィルターの適用
      await tester.tap(find.byKey(const Key('filterButton')));
      await tester.pumpAndSettle();
      
      // 7. 予算フィルター（スライダー）の調整
      final Slider budgetSlider = tester.widget(find.byKey(const Key('budgetSlider')));
      await tester.drag(find.byKey(const Key('budgetSlider')), const Offset(50.0, 0.0));
      await tester.pumpAndSettle();
      
      // 8. ジャンルフィルターの選択
      await tester.tap(find.byKey(const Key('genreChip_和食')));
      await tester.pumpAndSettle();
      
      // 9. フィルター適用ボタンをタップ
      await tester.tap(find.byKey(const Key('applyFiltersButton')));
      await tester.pumpAndSettle();
      
      // 10. フィルター適用後の結果確認
      final resultCount = tester.widgetList(find.byType(IzakayaCard)).length;
      expect(resultCount, isPositive); // 少なくとも1件の結果があること
      
      // 11. 結果クリアボタンのタップ
      await tester.tap(find.byKey(const Key('clearButton')));
      await tester.pumpAndSettle();
      
      // 12. 検索フィールドがクリアされていること
      expect(find.text(''), findsOneWidget);
    });
  });
}
```

## 6. テスト実行環境と自動化

### 6.1. CI/CD パイプラインでのテスト

GitHubワークフローの設定例：

```yaml
name: Flutter Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

### 6.2. 手動テスト実行コマンド

```bash
# 単体テスト実行
flutter test

# 特定のテストファイルを実行
flutter test test/path/to/test_file.dart

# カバレッジレポート生成
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# 統合テスト実行
flutter test integration_test/
```

## 7. テスト結果の評価基準

### 7.1. 受け入れ基準

- **単体テスト**: 80%以上のコードカバレッジ
- **結合テスト**: すべての重要なユースケースフローが成功
- **UIテスト**: すべての主要画面と操作が正常に動作

### 7.2. バグ優先度の定義

| 優先度 | 説明 | 対応期限 |
|-------|------|----------|
| **P0** | クラッシャー、データ損失など致命的な問題 | 即時対応（リリース阻害） |
| **P1** | 主要機能の障害 | 24時間以内 |
| **P2** | 機能の一部が動作しない | 3営業日以内 |
| **P3** | 軽微な問題、UIの乱れなど | 次期リリースまで |

### 7.3. テスト不合格時の手順

1. バグの再現手順と証拠（スクリーンショット、ログなど）を記録
2. Githubイシューの作成と優先度のラベル付け
3. 開発者へのアサイン
4. 修正後の検証テスト実施

## 8. 回帰テスト戦略

### 8.1. 自動回帰テスト

- リリース前に実行する自動テストスイート
- 過去のバグケースを含むテストケース
- パフォーマンス指標の継続的モニタリング

### 8.2. 手動回帰テスト

- チェックリストに基づく重要機能の確認
- 異なるデバイスとOSバージョンでのテスト
- エッジケースとしての特殊なユーザーシナリオテスト

## 9. アクセシビリティテスト

### 9.1. テスト対象

- スクリーンリーダー対応
- コントラスト比
- タッチターゲットサイズ
- キーボードナビゲーション

### 9.2. テスト方法

```dart
testWidgets('Accessibility - screen reader support test', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  
  // すべての重要なコントロールにセマンティックラベルがあることを確認
  final semantics = tester.binding.pipelineOwner.semanticsOwner;
  expect(semantics, isNotNull);
  
  // 特定のウィジェットのセマンティクスをチェック
  final finder = find.byKey(const Key('loginButton'));
  final semanticsNode = tester.getSemantics(finder);
  
  expect(semanticsNode.label, 'ログイン');
  expect(semanticsNode.actions, contains(SemanticsAction.tap));
});
```

## 10. テストメンテナンスガイドライン

### 10.1. テスト資産の管理

- テストコードのリファクタリング頻度: 2ヶ月ごと
- テストデータの更新: 主要リリースごと
- モックとスタブの更新: API仕様変更時

### 10.2. テストの追加タイミング

- 新機能追加時: 対応するテストケースを追加
- バグ修正時: 回帰テストケースを追加
- リファクタリング時: 既存テストの更新

### 10.3. テスト債務の管理

- フラッキーテスト（不安定なテスト）の管理方法
- スキップされているテストの定期的な見直し
- テストカバレッジの継続的なモニタリング 