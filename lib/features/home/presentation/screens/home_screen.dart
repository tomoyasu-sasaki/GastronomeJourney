import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastronomejourney/features/auth/domain/models/auth_state.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: authState.when(
        data: (state) => state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          authenticated: (user) => Scaffold(
            appBar: AppBar(
              title: const Text('ホーム'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    // TODO: プロフィール画面への遷移を実装
                    context.push('/profile');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.photoURL!),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName ?? 'ゲスト',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          unauthenticated: () => const Center(child: Text('認証が必要です')),
          error: (message) => Center(child: Text('エラー: $message')),
        ),
        error: (error, stackTrace) => Center(child: Text('エラー: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
} 