import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/auth_test_screen.dart';
import '../features/auth/presentation/screens/env_test_screen.dart';

/// アプリケーションのルーティング設定
final appRouter = GoRouter(
  initialLocation: '/auth-test',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('ホーム画面'),
        ),
      ),
    ),
    GoRoute(
      path: '/env-test',
      name: 'env-test',
      builder: (context, state) => const EnvTestScreen(),
    ),
    GoRoute(
      path: '/auth-test',
      name: 'auth-test',
      builder: (context, state) => const AuthTestScreen(),
    ),
    // 今後、認証画面、居酒屋一覧画面、詳細画面などを追加予定
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ページが見つかりません',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    ),
  ),
); 