# GastronomeJourney データベースマイグレーション戦略

## 1. 概要

このドキュメントでは、GastronomeJourneyアプリケーションのFirestoreデータベースのスキーマ変更やデータマイグレーションを安全かつ効率的に行うための戦略について説明します。アプリケーションの進化に伴い、データモデルの変更は避けられないため、適切なマイグレーション戦略が必要です。

## 2. Firestoreのデータモデル変更の課題

Firestoreは、従来のリレーショナルデータベースと異なり、固定されたスキーマやマイグレーションツールを持たないスキーマレスなデータベースです。これにより、以下の課題が発生します：

1. **スキーマの暗黙的な定義**: スキーマはコード側で定義され、データベース自体には強制されません
2. **既存データの互換性**: 古いバージョンのアプリが新しいデータ構造を読み込めない可能性があります
3. **部分的な更新**: すべてのユーザーが同時にアップデートを行うわけではありません
4. **オフラインサポート**: Firestoreのオフラインキャッシュにより、古いデータ構造が残る可能性があります

## 3. マイグレーション戦略の原則

GastronomeJourneyでは、以下の原則に基づいてデータベースマイグレーションを行います：

### 3.1. 後方互換性の維持

データモデルの変更は、可能な限り後方互換性を維持します。これにより、古いバージョンのアプリでも新しいデータ構造を読み込むことができます。

### 3.2. 段階的なアップグレード

大規模な変更は一度に行わず、複数のリリースにわたって段階的に実施します。

### 3.3. バージョン管理

各データドキュメントにはバージョン情報を含め、クライアントアプリがデータのバージョンを識別できるようにします。

### 3.4. 明示的なマイグレーションコード

データの変換ロジックは明示的に書かれ、テスト可能である必要があります。

### 3.5. セーフティネット

マイグレーション失敗時のロールバック戦略とエラー処理を用意します。

## 4. データモデルのバージョニング

### 4.1. ドキュメントレベルのバージョン管理

各Firestoreドキュメントには、データ構造のバージョンを示す`schemaVersion`フィールドを含めます：

```dart
class IzakayaModel {
  final String id;
  final String name;
  final String address;
  // 他のフィールド
  
  // スキーマバージョン
  final int schemaVersion;
  
  // コンストラクタ
  IzakayaModel({
    required this.id,
    required this.name,
    required this.address,
    // 他のフィールド
    this.schemaVersion = 1, // デフォルト値
  });
  
  // fromJson
  factory IzakayaModel.fromJson(Map<String, dynamic> json) {
    return IzakayaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      // 他のフィールド
      schemaVersion: json['schemaVersion'] as int? ?? 1,
    );
  }
  
  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      // 他のフィールド
      'schemaVersion': schemaVersion,
    };
  }
}
```

### 4.2. アプリケーションのバージョンとの関連付け

アプリケーションのバージョンと、サポートするデータモデルのバージョンの対応関係を明確にします：

| アプリバージョン | サポートするスキーマバージョン |
|--------------|------------------------|
| 1.0.0        | 1                      |
| 1.1.0        | 1, 2                   |
| 2.0.0        | 2, 3                   |

## 5. マイグレーションパターン

### 5.1. フィールド追加（最も安全）

新しいフィールドの追加は最も安全なマイグレーションです。

**例**: `IzakayaModel`に`website`フィールドを追加する場合

```dart
// バージョン1
class IzakayaModelV1 {
  final String id;
  final String name;
  final String address;
  final int schemaVersion = 1;
}

// バージョン2
class IzakayaModelV2 {
  final String id;
  final String name;
  final String address;
  final String? website; // 新規追加フィールド
  final int schemaVersion = 2;
}
```

**マイグレーション戦略**:
1. 新しいモデルでは`website`フィールドを読み込む際に`null`をデフォルト値とする
2. UIでは`website`フィールドが`null`の場合の処理を適切に行う
3. データの保存時には常に最新のスキーマバージョンで保存する

### 5.2. フィールド名の変更

フィールド名の変更は、古いフィールド名と新しいフィールド名の両方をサポートする移行期間を設けます。

**例**: `address`を`location`に変更する場合

```dart
// バージョン2
class IzakayaModelV2 {
  final String id;
  final String name;
  final String address;
  final String? website;
  final int schemaVersion = 2;
}

// バージョン3（移行期）
class IzakayaModelV3 {
  final String id;
  final String name;
  final String? address; // 古いフィールド（廃止予定）
  final String location; // 新しいフィールド
  final String? website;
  final int schemaVersion = 3;
  
  // fromJson - 両方のフィールドをサポート
  factory IzakayaModelV3.fromJson(Map<String, dynamic> json) {
    return IzakayaModelV3(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String? ?? json['address'] as String, // 新旧両方のフィールドに対応
      website: json['website'] as String?,
      schemaVersion: json['schemaVersion'] as int? ?? 2, // デフォルトはV2とする
    );
  }
  
  // toJson - 新しい形式で保存
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location, // 新しいフィールド名で保存
      // 'address': location, // オプション：下位互換性のために残す
      'website': website,
      'schemaVersion': schemaVersion,
    };
  }
}

// バージョン4（完全移行後）
class IzakayaModelV4 {
  final String id;
  final String name;
  final String location; // addressフィールドは完全に廃止
  final String? website;
  final int schemaVersion = 4;
}
```

**マイグレーション戦略**:
1. 移行期間では、旧フィールド（address）と新フィールド（location）の両方からデータを読み込む
2. 新たに保存する際は、新フィールド（location）を使用
3. 十分な時間が経過した後（全ユーザーが新バージョンにアップデートした後）、旧フィールドのサポートを終了

### 5.3. データ構造の変更

データ構造の大きな変更（例：ネストされたオブジェクトの追加）は、より複雑なマイグレーション戦略が必要です。

**例**: 居酒屋の営業時間を構造化データとして追加する場合

```dart
// バージョン3
class IzakayaModelV3 {
  final String id;
  final String name;
  final String location;
  final String? website;
  final String? businessHours; // 単純な文字列
  final int schemaVersion = 3;
}

// 新しい構造化データ
class BusinessHours {
  final Map<String, DailyHours> weekdayHours;
  final List<SpecialHoliday> holidays;
  
  // ...構造化されたデータのメソッド
}

class DailyHours {
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;
  final bool isClosed;
  
  // ...
}

// バージョン4
class IzakayaModelV4 {
  final String id;
  final String name;
  final String location;
  final String? website;
  final String? businessHours; // 古い形式を保持
  final BusinessHours? structuredBusinessHours; // 新しい構造化データ
  final int schemaVersion = 4;
  
  // fromJson - 古いデータから新しいデータへの変換
  factory IzakayaModelV4.fromJson(Map<String, dynamic> json) {
    final int version = json['schemaVersion'] as int? ?? 3;
    
    // 構造化営業時間の処理
    BusinessHours? structuredHours;
    if (json['structuredBusinessHours'] != null) {
      // 構造化データが存在する場合はそのまま読み込む
      structuredHours = BusinessHours.fromJson(json['structuredBusinessHours']);
    } else if (json['businessHours'] != null) {
      // 古い形式の文字列から構造化データへ変換を試みる
      structuredHours = BusinessHoursConverter.fromString(json['businessHours']);
    }
    
    return IzakayaModelV4(
      // ...他のフィールド
      businessHours: json['businessHours'] as String?,
      structuredBusinessHours: structuredHours,
      schemaVersion: version,
    );
  }
  
  // toJson - 新しい形式で保存しつつ、下位互換性も維持
  Map<String, dynamic> toJson() {
    return {
      // ...他のフィールド
      'businessHours': businessHours ?? structuredBusinessHours?.toSimpleString(),
      'structuredBusinessHours': structuredBusinessHours?.toJson(),
      'schemaVersion': schemaVersion,
    };
  }
}
```

**マイグレーション戦略**:
1. 古いデータ形式と新しいデータ形式の両方をサポート
2. 古いデータから新しいデータへの変換ロジックを実装
3. 新しいデータを保存する際は古いフィールドも更新（下位互換性のため）
4. ユーザーがデータを編集したタイミングでマイグレーションを完了

## 6. マイグレーション実行方法

### 6.1. オンザフライマイグレーション

各ドキュメントを読み込むタイミングでマイグレーションを実行します。

```dart
class IzakayaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<IzakayaModel> getIzakaya(String id) async {
    final doc = await _firestore.collection('izakayas').doc(id).get();
    final data = doc.data()!;
    
    // バージョンチェックとマイグレーション
    final IzakayaModel izakaya = await migrateIzakayaIfNeeded(data);
    
    // 必要に応じてマイグレーション結果を保存
    if (izakaya.schemaVersion != data['schemaVersion']) {
      await _firestore.collection('izakayas').doc(id).update(izakaya.toJson());
    }
    
    return izakaya;
  }
  
  // マイグレーションロジック
  Future<IzakayaModel> migrateIzakayaIfNeeded(Map<String, dynamic> data) async {
    final int version = data['schemaVersion'] as int? ?? 1;
    
    // バージョンに応じたマイグレーション
    switch (version) {
      case 1:
        data = migrateFromV1ToV2(data);
        continue v2;
      v2:
      case 2:
        data = migrateFromV2ToV3(data);
        continue v3;
      v3:
      case 3:
        data = migrateFromV3ToV4(data);
        break;
      case 4:
        // 最新バージョン、何もしない
        break;
      default:
        // 未知のバージョン、エラーハンドリング
        throw UnknownSchemaVersionException(version);
    }
    
    return IzakayaModel.fromJson(data);
  }
  
  // 各バージョン間のマイグレーション関数
  Map<String, dynamic> migrateFromV1ToV2(Map<String, dynamic> data) {
    // V1からV2へのマイグレーションロジック
    return {
      ...data,
      'website': null, // 新規フィールド
      'schemaVersion': 2,
    };
  }
  
  Map<String, dynamic> migrateFromV2ToV3(Map<String, dynamic> data) {
    // V2からV3へのマイグレーションロジック
    return {
      ...data,
      'location': data['address'], // addressをlocationにリネーム
      'schemaVersion': 3,
    };
  }
  
  Map<String, dynamic> migrateFromV3ToV4(Map<String, dynamic> data) {
    // V3からV4へのマイグレーションロジック
    final String? businessHours = data['businessHours'] as String?;
    final structuredHours = businessHours != null
        ? BusinessHoursConverter.fromString(businessHours)
        : null;
    
    return {
      ...data,
      'structuredBusinessHours': structuredHours?.toJson(),
      'schemaVersion': 4,
    };
  }
}
```

### 6.2. バッチマイグレーション

Cloud Functions を使用して、バックグラウンドでデータベース全体または一部をマイグレーションします。

```typescript
// Cloud Functions example (TypeScript)
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const firestore = admin.firestore();

exports.migrateIzakayasToV2 = functions.runWith({
  timeoutSeconds: 540, // 9分のタイムアウト
  memory: '2GB',
}).https.onRequest(async (req, res) => {
  // 認証チェック
  // ...
  
  const batch = firestore.batch();
  let count = 0;
  let batchCount = 0;
  
  // V1のドキュメントを検索
  const snapshot = await firestore.collection('izakayas')
    .where('schemaVersion', '==', 1)
    .limit(500) // 一度に処理する最大数
    .get();
  
  if (snapshot.empty) {
    res.send('No documents to migrate');
    return;
  }
  
  // 各ドキュメントをマイグレーション
  for (const doc of snapshot.docs) {
    const data = doc.data();
    
    // V1からV2へのマイグレーション
    const migratedData = {
      ...data,
      website: null, // 新規フィールド
      schemaVersion: 2,
    };
    
    batch.update(doc.ref, migratedData);
    count++;
    
    // 500件ごとにバッチを実行
    if (count >= 500) {
      await batch.commit();
      batchCount++;
      count = 0;
    }
  }
  
  // 残りのドキュメントを処理
  if (count > 0) {
    await batch.commit();
    batchCount++;
  }
  
  res.send(`Migration completed. Processed ${snapshot.size} documents in ${batchCount} batches.`);
});
```

### 6.3. アプリ起動時のマイグレーション

アプリのバージョンアップ時に、ローカルデータベースやリモートデータベースのマイグレーションを実行します。

```dart
class MigrationService {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  
  MigrationService(this._prefs, this._firestore);
  
  Future<void> checkAndMigrateIfNeeded() async {
    final String? lastVersion = _prefs.getString('last_app_version');
    final String currentVersion = '2.0.0'; // アプリの現在のバージョン
    
    if (lastVersion == null) {
      // 初回インストール、マイグレーション不要
      await _prefs.setString('last_app_version', currentVersion);
      return;
    }
    
    if (lastVersion != currentVersion) {
      // バージョンが異なる場合はマイグレーションを実行
      await _migrateFromVersion(lastVersion, currentVersion);
      await _prefs.setString('last_app_version', currentVersion);
    }
  }
  
  Future<void> _migrateFromVersion(String fromVersion, String toVersion) async {
    // バージョンに応じたマイグレーション
    if (fromVersion == '1.0.0' && toVersion == '2.0.0') {
      await _migrateFrom1To2();
    }
  }
  
  Future<void> _migrateFrom1To2() async {
    // 例: ユーザーが作成したローカルデータをマイグレーション
    // 例: ユーザー所有のリモートデータをマイグレーション
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userIzakayas = await _firestore
          .collection('izakayas')
          .where('createdBy', '==', userId)
          .get();
      
      final batch = _firestore.batch();
      for (final doc in userIzakayas.docs) {
        final data = doc.data();
        if (data['schemaVersion'] == 1) {
          batch.update(doc.reference, {
            'website': null,
            'schemaVersion': 2,
          });
        }
      }
      
      await batch.commit();
    }
  }
}
```

## 7. テストとデバッグ

### 7.1. マイグレーションテスト

各マイグレーションロジックは、単体テストでテストする必要があります。

```dart
void main() {
  group('IzakayaModel Migration Tests', () {
    test('should migrate from V1 to V2', () {
      // サンプルV1データ
      final v1Data = {
        'id': '123',
        'name': 'テスト居酒屋',
        'address': '東京都新宿区',
        'schemaVersion': 1,
      };
      
      // マイグレーション
      final repository = IzakayaRepository();
      final v2Data = repository.migrateFromV1ToV2(v1Data);
      
      // アサーション
      expect(v2Data['id'], '123');
      expect(v2Data['name'], 'テスト居酒屋');
      expect(v2Data['address'], '東京都新宿区');
      expect(v2Data['website'], null); // 新規フィールド
      expect(v2Data['schemaVersion'], 2); // バージョン更新
    });
    
    // 他のマイグレーションテスト
  });
}
```

### 7.2. マイグレーションモニタリング

本番環境でのマイグレーションをモニタリングするためのログとメトリクスを実装します。

```dart
class MigrationLoggingService {
  final FirebaseAnalytics _analytics;
  
  MigrationLoggingService(this._analytics);
  
  Future<void> logMigration(
    String fromVersion,
    String toVersion,
    bool success,
    {String? errorMessage}
  ) async {
    await _analytics.logEvent(
      name: 'schema_migration',
      parameters: {
        'from_version': fromVersion,
        'to_version': toVersion,
        'success': success,
        'error_message': errorMessage ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
```

## 8. ロールバック戦略

マイグレーション失敗時のロールバック戦略を定義します。

### 8.1. データバックアップ

重要なマイグレーション前にバックアップを取得します。

```dart
Future<void> backupBeforeMigration(String collectionName, String migrationName) async {
  final collection = FirebaseFirestore.instance.collection(collectionName);
  final snapshot = await collection.get();
  
  // バックアップコレクションにデータを保存
  final batch = FirebaseFirestore.instance.batch();
  final backupCollection = FirebaseFirestore.instance
    .collection('backups')
    .doc(migrationName)
    .collection(collectionName);
  
  for (final doc in snapshot.docs) {
    batch.set(backupCollection.doc(doc.id), {
      ...doc.data(),
      '_backup_timestamp': FieldValue.serverTimestamp(),
    });
  }
  
  await batch.commit();
}
```

### 8.2. 段階的なロールアウト

マイグレーションは、最初は一部のユーザーに対してのみ実行し、問題がないことを確認してから全ユーザーに展開します。

```dart
bool shouldPerformMigration() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;
  
  // ユーザーIDの最初の文字を使用して、約10%のユーザーに対してのみマイグレーションを実行
  final firstChar = userId[0].toLowerCase();
  return firstChar == 'a' || firstChar == 'b';
}
```

### 8.3. リモート構成

Firebase Remote Configを使用して、マイグレーションの有効化/無効化を動的に制御します。

```dart
Future<bool> isMigrationEnabled(String migrationName) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  
  return remoteConfig.getBool('migration_${migrationName}_enabled');
}
```

## 9. ベストプラクティス

### 9.1. 追加のみの変更を優先する

可能な限り、既存のフィールドは変更せず、新しいフィールドの追加を優先します。

### 9.2. 移行期間を設ける

古いフィールドと新しいフィールドを並行してサポートする移行期間を設けます。

### 9.3. データ検証を実装する

マイグレーション後のデータが期待通りであることを検証するためのバリデーションを実装します。

### 9.4. 段階的にリリースする

マイグレーションを含むアプリのアップデートは、段階的にリリースします。

### 9.5. パフォーマンスを考慮する

大規模なマイグレーションはバックグラウンドで実行し、ユーザー体験に影響を与えないようにします。

## 10. 更新履歴

| 日付 | バージョン | 更新内容 | 担当者 |
|-----|-----------|---------|-------|
| 2023-XX-XX | 1.0 | 初版作成 | XXX | 