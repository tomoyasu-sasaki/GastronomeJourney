/// アプリケーション全体で使用する定数を定義するクラス
class AppConstants {
  /// アプリ名
  static const appName = 'GastronomeJourney';
  
  /// デフォルトアバター画像URL
  static const defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/gastronomejourney.appspot.com/o/defaults%2Fdefault_avatar.png?alt=media';
  
  /// デフォルト居酒屋画像URL
  static const defaultIzakayaImageUrl = 'https://firebasestorage.googleapis.com/v0/b/gastronomejourney.appspot.com/o/defaults%2Fdefault_izakaya.png?alt=media';
  
  /// 居酒屋ジャンルリスト
  static const izakayaGenres = [
    '和食',
    '洋食',
    '中華',
    '居酒屋',
    'バー',
    'イタリアン',
    'フレンチ',
    'アジア料理',
    'その他',
  ];
  
  /// 予算範囲リスト
  static const budgetRanges = [
    '~2,000円',
    '2,000円~3,000円',
    '3,000円~5,000円',
    '5,000円~8,000円',
    '8,000円~10,000円',
    '10,000円~',
  ];
}

/// Firestoreコレクション名を定義するクラス
class FirestoreCollections {
  static const users = 'users';
  static const izakayas = 'izakayas';
  static const bookmarks = 'bookmarks';
}

/// Firebaseストレージパスを定義するクラス
class StoragePaths {
  static const userAvatars = 'user_avatars';
  static const izakayaImages = 'izakaya_images';
} 