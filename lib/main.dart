import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gastronomejourney/config/firebase_config.dart';
import 'package:gastronomejourney/config/router.dart';
import 'package:gastronomejourney/core/utils/env_helper.dart';
import 'package:gastronomejourney/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 環境変数の読み込み
  try {
    await dotenv.load(fileName: '.env');
    AppLog.i('環境変数の読み込みに成功しました');
    
    // 環境変数の検証（Web以外のプラットフォームの場合）
    if (!kIsWeb && !EnvHelper.validateFirebaseConfig()) {
      AppLog.w('一部の環境変数が設定されていないか、不正な値です。デフォルト値を使用します。');
    }
  } catch (e) {
    AppLog.e('環境変数の読み込みに失敗しました: $e');
    AppLog.i('デフォルト値を使用して処理を続行します');
  }
  
  // Firebaseの初期化
  try {
    await Firebase.initializeApp(
      options: await FirebaseConfig.getOptions(),
    );
    AppLog.i('Firebaseの初期化に成功しました');
    // Firebaseのリモート構成設定やクラッシュ解析の有効化などを追加予定
  } catch (e) {
    AppLog.e('Firebase初期化エラー: $e');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GastronomeJourney',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
