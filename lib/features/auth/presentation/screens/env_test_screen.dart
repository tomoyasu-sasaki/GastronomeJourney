import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EnvTestScreen extends StatelessWidget {
  const EnvTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String?> envVars = {};
    String envLoadError = '';
    
    try {
      envVars['FIREBASE_API_KEY'] = dotenv.env['FIREBASE_API_KEY'];
      envVars['FIREBASE_APP_ID'] = dotenv.env['FIREBASE_APP_ID'];
      envVars['FIREBASE_MESSAGING_SENDER_ID'] = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'];
      envVars['FIREBASE_PROJECT_ID'] = dotenv.env['FIREBASE_PROJECT_ID'];
      envVars['FIREBASE_STORAGE_BUCKET'] = dotenv.env['FIREBASE_STORAGE_BUCKET'];
      envVars['FIREBASE_AUTH_DOMAIN'] = dotenv.env['FIREBASE_AUTH_DOMAIN'];
      envVars['FIREBASE_IOS_API_KEY'] = dotenv.env['FIREBASE_IOS_API_KEY'];
      envVars['FIREBASE_IOS_APP_ID'] = dotenv.env['FIREBASE_IOS_APP_ID'];
      envVars['FIREBASE_IOS_BUNDLE_ID'] = dotenv.env['FIREBASE_IOS_BUNDLE_ID'];
      envVars['APP_ENV'] = dotenv.env['APP_ENV'];
    } catch (e) {
      envLoadError = e.toString();
    }

    bool isInitialized = false;
    String errorMessage = '';
    
    try {
      // ignore: unnecessary_null_comparison
      isInitialized = FirebaseAuth.instance.app != null;
    } catch (e) {
      errorMessage = e.toString();
      isInitialized = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('環境変数テスト'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase認証の初期化状態: ${isInitialized ? "成功" : "失敗"}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (errorMessage.isNotEmpty) 
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  'エラー: $errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              '環境変数の読み込み結果:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (envLoadError.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  '環境変数読み込みエラー: $envLoadError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12),
            ...envVars.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${entry.key}: ${entry.value ?? "未設定"}',
                  style: TextStyle(
                    color: entry.value == null ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '実行環境: ${kIsWeb ? "Web" : "ネイティブ"}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (kIsWeb)
                    Text(
                      '注意: Webモードでは.envファイルを assets フォルダに追加し、pubspec.yamlにアセットとして登録する必要があります。',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 