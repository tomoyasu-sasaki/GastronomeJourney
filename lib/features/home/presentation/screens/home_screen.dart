import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) => state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        authenticated: (user) => Scaffold(
          appBar: AppBar(
            title: const Text('ホーム'),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName ?? 'ゲスト',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(user.email),
              ],
            ),
          ),
        ),
        unauthenticated: () => const Center(
          child: Text('認証が必要です'),
        ),
        error: (message) => Center(
          child: Text('エラー: $message'),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Text('エラー: $error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 