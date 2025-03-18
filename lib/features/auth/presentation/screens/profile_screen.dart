import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: authState.when(
        data: (state) => state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          authenticated: (user) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white),
                            onPressed: () {
                              // TODO: プロフィール画像の更新機能を実装
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ユーザー名',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: user.displayName,
                  decoration: const InputDecoration(
                    hintText: 'ユーザー名を入力',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // TODO: ユーザー名の更新機能を実装
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'メールアドレス',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: user.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (!user.emailVerified)
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: メール認証機能を実装
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('メールアドレスを認証'),
                  ),
              ],
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