# GastronomeJourney API仕様書

## 1. 概要

本ドキュメントは、GastronomeJourneyアプリのバックエンドAPIとデータモデルに関する仕様を定義します。このアプリはFirebaseをバックエンドとして使用し、Firestoreデータベース、Firebase Storage、Firebase Authenticationを主要コンポーネントとしています。

### 1.1. 技術スタック
- **データベース**: Firebase Firestore
- **ストレージ**: Firebase Storage
- **認証**: Firebase Authentication
- **サーバーレス関数**: Firebase Cloud Functions
- **データ形式**: JSON
- **API種類**: REST API / Firebase SDK

## 2. Firestoreデータモデル

### 2.1. コレクション構造

Firestoreデータベースは以下の主要コレクションで構成されます：

```
users/          # ユーザー情報
izakayas/       # 居酒屋情報
bookmarks/      # 気になるリスト（ブックマーク）
```

### 2.2. ドキュメント構造詳細

#### 2.2.1. ユーザー（users）

**コレクション**: `users`  
**ドキュメントID**: Firebase Authentication UID（自動生成）

**フィールド:**

| フィールド名 | 型 | 説明 | 必須 | デフォルト値 |
|------------|------|------|------|------------|
| `displayName` | String | ユーザー表示名 | Yes | - |
| `email` | String | メールアドレス | Yes | - |
| `photoURL` | String | プロフィール画像URL | No | null |
| `createdAt` | Timestamp | 作成日時 | Yes | サーバータイムスタンプ |
| `updatedAt` | Timestamp | 更新日時 | No | null |
| `fcmToken` | String | Firebase Cloud Messaging トークン | No | null |
| `preferences` | Map | ユーザー設定 | No | {} |

**サブコレクション:**
- なし

**インデックス:**
- `email` (昇順)
- `createdAt` (降順)

#### 2.2.2. 居酒屋（izakayas）

**コレクション**: `izakayas`  
**ドキュメントID**: 自動生成

**フィールド:**

| フィールド名 | 型 | 説明 | 必須 | デフォルト値 |
|------------|------|------|------|------------|
| `name` | String | 居酒屋名 | Yes | - |
| `address` | String | 住所 | Yes | - |
| `phone` | String | 電話番号 | No | null |
| `businessHours` | String | 営業時間 | No | null |
| `holidays` | String | 定休日 | No | null |
| `budget` | Number | 予算（円） | Yes | 0 |
| `genre` | String | ジャンル | Yes | - |
| `description` | String | 説明 | No | null |
| `images` | Array<String> | 画像URL配列 | No | [] |
| `isPublic` | Boolean | 公開設定 | Yes | false |
| `userId` | String | 投稿ユーザーID | Yes | - |
| `location` | GeoPoint | 位置情報 | No | null |
| `createdAt` | Timestamp | 作成日時 | Yes | サーバータイムスタンプ |
| `updatedAt` | Timestamp | 更新日時 | Yes | サーバータイムスタンプ |

**サブコレクション:**
- なし

**インデックス:**
- `userId` + `createdAt` (降順) - ユーザーごとの投稿一覧
- `isPublic` + `createdAt` (降順) - 公開投稿一覧
- `genre` + `isPublic` + `createdAt` (降順) - ジャンルごとの公開投稿
- `budget` (昇順) - 予算でのフィルタリング

#### 2.2.3. ブックマーク（bookmarks）

**コレクション**: `bookmarks`  
**ドキュメントID**: 自動生成

**フィールド:**

| フィールド名 | 型 | 説明 | 必須 | デフォルト値 |
|------------|------|------|------|------------|
| `userId` | String | ブックマークしたユーザーID | Yes | - |
| `izakayaId` | String | ブックマークされた居酒屋ID | Yes | - |
| `createdAt` | Timestamp | 作成日時 | Yes | サーバータイムスタンプ |
| `notes` | String | ユーザーのメモ | No | null |

**サブコレクション:**
- なし

**インデックス:**
- `userId` + `createdAt` (降順) - ユーザーごとのブックマークリスト
- `userId` + `izakayaId` (複合一意キー) - 重複ブックマーク防止

### 2.3. スキーマバリデーション

Firestoreのセキュリティルールでスキーマバリデーションを実施します：

```javascript
// users コレクションのバリデーション
function isValidUser(user) {
  return user.size() >= 3
      && 'displayName' in user && user.displayName is string
      && 'email' in user && user.email is string
      && 'createdAt' in user && user.createdAt is timestamp;
}

// izakayas コレクションのバリデーション
function isValidIzakaya(izakaya) {
  return izakaya.size() >= 7
      && 'name' in izakaya && izakaya.name is string && izakaya.name.size() > 0
      && 'address' in izakaya && izakaya.address is string
      && 'budget' in izakaya && izakaya.budget is number && izakaya.budget >= 0
      && 'genre' in izakaya && izakaya.genre is string
      && 'isPublic' in izakaya && izakaya.isPublic is bool
      && 'userId' in izakaya && izakaya.userId is string
      && 'createdAt' in izakaya && izakaya.createdAt is timestamp;
}

// bookmarks コレクションのバリデーション
function isValidBookmark(bookmark) {
  return bookmark.size() >= 3
      && 'userId' in bookmark && bookmark.userId is string
      && 'izakayaId' in bookmark && bookmark.izakayaId is string
      && 'createdAt' in bookmark && bookmark.createdAt is timestamp;
}
```

## 3. Firebase Storageの構造

### 3.1. ディレクトリ構造

```
/
├── users/
│   └── {userId}/
│       └── profile.jpg       # プロフィール画像
│
└── izakayas/
    └── {izakayaId}/
        ├── main.jpg         # メイン画像
        └── images/
            ├── 1.jpg        # 追加画像
            ├── 2.jpg
            └── ...
```

### 3.2. 画像のメタデータ

各画像ファイルに付与するメタデータ：

```javascript
{
  "contentType": "image/jpeg",
  "customMetadata": {
    "uploadedBy": "{userId}",
    "uploadedAt": "{timestamp}",
    "originalName": "{originalFileName}",
    "isCompressed": "true",
    "width": "{width}",
    "height": "{height}"
  }
}
```

### 3.3. 画像アップロード仕様

- **最大ファイルサイズ**: 10MB
- **許可フォーマット**: JPEG, PNG, WebP
- **推奨解像度**: 最大辺 1920px
- **圧縮設定**: クライアント側で圧縮処理（品質: 85%）

## 4. Cloud Functions API

### 4.1. ユーザー関連API

#### 4.1.1. ユーザープロフィール作成/更新

**関数名**: `createOrUpdateUserProfile`  
**トリガー**: Firebase Auth ユーザー作成/更新  
**説明**: ユーザーが認証した際に自動的にFirestoreにユーザープロフィールを作成/更新する

**処理内容**:
```javascript
exports.createOrUpdateUserProfile = functions.auth.user().onCreate((user) => {
  const userProfile = {
    displayName: user.displayName || '',
    email: user.email,
    photoURL: user.photoURL || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  return admin.firestore().collection('users').doc(user.uid).set(userProfile);
});
```

### 4.2. 居酒屋関連API

#### 4.2.1. 居酒屋画像リサイズ処理

**関数名**: `resizeIzakayaImage`  
**トリガー**: Firebase Storage ファイルアップロード  
**説明**: 居酒屋画像がアップロードされた際に、サムネイルと最適化画像を自動生成する

**処理内容**:
```javascript
exports.resizeIzakayaImage = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  if (!filePath.startsWith('izakayas/') || !filePath.match(/\.(jpe?g|png|webp)$/i)) {
    return null;
  }
  
  // サムネイル生成処理
  const thumbnail = await generateThumbnail(filePath, 400);
  
  // 最適化画像生成処理
  const optimized = await optimizeImage(filePath, 1200);
  
  return {
    thumbnail: thumbnail,
    optimized: optimized
  };
});
```

#### 4.2.2. 居酒屋検索API

**関数名**: `searchIzakayas`  
**HTTPエンドポイント**: `https://us-central1-[project-id].cloudfunctions.net/searchIzakayas`  
**メソッド**: GET  
**説明**: キーワード、ジャンル、予算などで居酒屋を検索する

**クエリパラメータ**:

| パラメータ | 型 | 説明 | 必須 | デフォルト値 |
|-----------|------|------|------|------------|
| `keyword` | String | 検索キーワード | No | null |
| `genre` | String | ジャンル | No | null |
| `minBudget` | Number | 最低予算 | No | 0 |
| `maxBudget` | Number | 最高予算 | No | null |
| `limit` | Number | 取得件数 | No | 20 |
| `lastVisible` | String | ページネーションカーソル | No | null |

**レスポンス**:
```json
{
  "izakayas": [
    {
      "id": "izakaya123",
      "name": "居酒屋サンプル",
      "address": "東京都渋谷区",
      "budget": 3000,
      "genre": "和食",
      "images": ["https://example.com/image1.jpg"],
      "isPublic": true,
      "createdAt": "2023-05-01T12:34:56Z"
    }
  ],
  "lastVisible": "encodedCursor123",
  "total": 42
}
```

### 4.3. ブックマーク関連API

#### 4.3.1. ブックマーク追加/削除

**関数名**: `toggleBookmark`  
**HTTPエンドポイント**: `https://us-central1-[project-id].cloudfunctions.net/toggleBookmark`  
**メソッド**: POST  
**説明**: 居酒屋を気になるリストに追加または削除する

**リクエストボディ**:
```json
{
  "izakayaId": "izakaya123",
  "status": true  // true: 追加, false: 削除
}
```

**レスポンス**:
```json
{
  "success": true,
  "bookmarkId": "bookmark123",  // 追加時のみ
  "status": true
}
```

## 5. セキュリティルール

### 5.1. Firestore セキュリティルール

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーがログインしているか確認
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // リクエストユーザーがドキュメント所有者か確認
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // ドキュメントが公開されているか確認
    function isPublic(resource) {
      return resource.data.isPublic == true;
    }
    
    // ユーザードキュメント
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create, update: if isOwner(userId) && isValidUser(request.resource.data);
      allow delete: if isOwner(userId);
    }
    
    // 居酒屋ドキュメント
    match /izakayas/{izakayaId} {
      allow read: if isPublic(resource) || isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isValidIzakaya(request.resource.data) && isOwner(request.resource.data.userId);
      allow update: if isOwner(resource.data.userId) && isValidIzakaya(request.resource.data);
      allow delete: if isOwner(resource.data.userId);
    }
    
    // ブックマークドキュメント
    match /bookmarks/{bookmarkId} {
      allow read: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && isValidBookmark(request.resource.data) && isOwner(request.resource.data.userId);
      allow delete: if isOwner(resource.data.userId);
    }
  }
}
```

### 5.2. Storage セキュリティルール

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // ユーザープロフィール画像
    match /users/{userId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId && 
                    request.resource.size < 5 * 1024 * 1024 &&
                    request.resource.contentType.matches('image/.*');
    }
    
    // 居酒屋画像
    match /izakayas/{izakayaId}/{allImages=**} {
      // 公開画像は誰でも読み取り可能
      allow read: if true;
      
      // 所有者のみが書き込み可能、10MB制限
      allow write: if request.auth != null && 
                    request.resource.size < 10 * 1024 * 1024 &&
                    request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 6. データアクセスパターン

### 6.1. パフォーマンス最適化

最適なデータアクセスパターンとクエリ例：

#### 6.1.1. ユーザーの居酒屋一覧取得

```dart
// ユーザーの投稿一覧（最新順）
final userPostsQuery = FirebaseFirestore.instance
    .collection('izakayas')
    .where('userId', isEqualTo: currentUserId)
    .orderBy('createdAt', descending: true)
    .limit(20);
```

#### 6.1.2. 公開居酒屋の一覧取得

```dart
// 公開投稿一覧（最新順）
final publicPostsQuery = FirebaseFirestore.instance
    .collection('izakayas')
    .where('isPublic', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(20);
```

#### 6.1.3. ジャンル別居酒屋の一覧取得

```dart
// 特定ジャンルの公開投稿一覧
final genrePostsQuery = FirebaseFirestore.instance
    .collection('izakayas')
    .where('genre', isEqualTo: selectedGenre)
    .where('isPublic', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(20);
```

#### 6.1.4. ユーザーのブックマーク一覧取得

```dart
// 2段階クエリ方式（推奨）
// 1. ユーザーのブックマーク取得
final bookmarksQuery = FirebaseFirestore.instance
    .collection('bookmarks')
    .where('userId', isEqualTo: currentUserId)
    .orderBy('createdAt', descending: true)
    .limit(20);

// 2. ブックマークから居酒屋データを取得
final bookmarkDocs = await bookmarksQuery.get();
final izakayaIds = bookmarkDocs.docs.map((doc) => doc.data()['izakayaId']).toList();

// 居酒屋データの一括取得（配列には最大10個までの値しか指定できないため注意）
final izakayaQuery = FirebaseFirestore.instance
    .collection('izakayas')
    .where(FieldPath.documentId, whereIn: izakayaIds.take(10).toList());
```

### 6.2. ページネーション実装

```dart
// 初回ロード
var query = FirebaseFirestore.instance
    .collection('izakayas')
    .where('isPublic', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(20);

var snapshot = await query.get();
var lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

// 次のページ取得
if (lastVisible != null) {
  query = FirebaseFirestore.instance
      .collection('izakayas')
      .where('isPublic', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .startAfterDocument(lastVisible)
      .limit(20);
  
  snapshot = await query.get();
  lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : lastVisible;
}
```

## 7. エラー処理

### 7.1. エラーコード定義

| エラーコード | 説明 | HTTP ステータス |
|------------|------|----------------|
| `auth/user-not-found` | ユーザーが見つかりません | 404 |
| `auth/wrong-password` | パスワードが間違っています | 401 |
| `auth/email-already-in-use` | メールアドレスは既に使用されています | 409 |
| `firestore/permission-denied` | アクセス権限がありません | 403 |
| `storage/unauthorized` | ストレージアクセス権限がありません | 403 |
| `izakaya/not-found` | 指定された居酒屋が見つかりません | 404 |
| `izakaya/validation-failed` | 居酒屋データのバリデーションに失敗しました | 400 |
| `bookmark/already-exists` | 既にブックマークされています | 409 |
| `bookmark/not-found` | ブックマークが見つかりません | 404 |

### 7.2. クライアント側でのエラーハンドリング例

```dart
try {
  await FirebaseFirestore.instance
      .collection('izakayas')
      .doc(izakayaId)
      .update({'name': newName});
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      // 権限エラー処理
      showErrorDialog('この操作を行う権限がありません');
      break;
    case 'not-found':
      // 存在しないドキュメント
      showErrorDialog('指定された居酒屋情報が見つかりません');
      break;
    default:
      // その他のFirebaseエラー
      showErrorDialog('エラーが発生しました: ${e.message}');
  }
} catch (e) {
  // その他の例外
  showErrorDialog('予期せぬエラーが発生しました');
}
```

## 8. リアルタイム更新

### 8.1. リアルタイムリスナーの実装例

```dart
// 居酒屋データのリアルタイム監視
StreamSubscription<QuerySnapshot>? _subscription;

void subscribeToIzakayas() {
  final query = FirebaseFirestore.instance
      .collection('izakayas')
      .where('isPublic', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(20);
  
  _subscription = query.snapshots().listen((snapshot) {
    final izakayas = snapshot.docs.map((doc) => 
        Izakaya.fromFirestore(doc)).toList();
    
    // UIを更新
    setState(() {
      this.izakayas = izakayas;
    });
  }, onError: (error) {
    // エラー処理
    print('Firestore listening error: $error');
  });
}

@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### 8.2. オフライン対応

```dart
// オフライン永続化の有効化
Future<void> setupFirestoreOfflineMode() async {
  await FirebaseFirestore.instance.settings = 
      Settings(persistenceEnabled: true, cacheSizeBytes: 10485760);
}
```

## 9. API バージョン管理

### 9.1. Cloud Functions APIバージョニング

```javascript
// v1 API
exports.apiV1SearchIzakayas = functions.https.onCall((data, context) => {
  // バージョン1の実装
});

// v2 API（新機能）
exports.apiV2SearchIzakayas = functions.https.onCall((data, context) => {
  // バージョン2の実装
});
```

### 9.2. クライアント側での呼び出し

```dart
// バージョン選択ロジック
final String apiVersion = AppConfig.useNewApi ? 'v2' : 'v1';

// 動的なAPIエンドポイント構築
final HttpsCallable callable = FirebaseFunctions.instance
    .httpsCallable('api${apiVersion}SearchIzakayas');

// API呼び出し
final result = await callable.call({
  'keyword': searchKeyword,
  'genre': selectedGenre,
});
```

## 10. 外部API連携（オプション）

### 10.1. Google Maps API

店舗の地図表示や位置情報取得のために使用：

```dart
// Google Maps APIキー設定
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

// 住所から位置情報（緯度・経度）を取得
Future<GeoPoint?> getGeoPointFromAddress(String address) async {
  final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey');
  
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['results'].length > 0) {
      final location = data['results'][0]['geometry']['location'];
      return GeoPoint(location['lat'], location['lng']);
    }
  }
  return null;
}
```

### 10.2. 画像認識API（将来拡張）

料理や店内の写真から自動タグ付けを行うための拡張：

```dart
// Vision APIを使用した画像分析
Future<List<String>> analyzeImage(String imageUrl) async {
  final functions = FirebaseFunctions.instance;
  final result = await functions.httpsCallable('analyzeImageContent').call({
    'imageUrl': imageUrl
  });
  
  final tags = List<String>.from(result.data['tags'] ?? []);
  return tags;
}
``` 