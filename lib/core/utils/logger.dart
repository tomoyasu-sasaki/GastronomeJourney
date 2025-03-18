import 'package:logger/logger.dart';

/// アプリケーション全体で使用するロガー
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2, // 呼び出し元のスタックトレースを表示する行数
    errorMethodCount: 8, // エラー発生時のスタックトレースを表示する行数
    lineLength: 120, // ログの幅
    colors: true, // カラー表示
    printEmojis: true, // 絵文字表示
    printTime: true, // タイムスタンプ表示
  ),
  level: Level.debug, // 最小出力レベル（リリースビルドでは変更予定）
);

/// リリースモード用のロガー設定を返す
Logger getReleaseLogger() {
  return Logger(
    printer: PrettyPrinter(methodCount: 0, lineLength: 80, colors: false, printEmojis: false),
    level: Level.warning, // リリースモードでは警告以上のログのみ表示
  );
}

/// ロガーレベルに応じて適切なログを出力するユーティリティメソッド
class AppLog {
  static void v(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.v('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.v(message);
    }
  }

  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.d('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.d(message);
    }
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.i('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.i(message);
    }
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.w('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.w(message);
    }
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.e('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.e(message);
    }
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      appLogger.wtf('$message\nError: $error${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
    } else {
      appLogger.wtf(message);
    }
  }
} 