import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider.notifier);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
            },
          ),
        ],
      ),
      body: authState.when(
        data: (state) => state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          authenticated: (user) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          // TODO: プロフィール画像の更新機能を実装
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.displayName ?? 'ゲスト'),
                subtitle: const Text('表示名'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  // TODO: 表示名の編集機能を実装
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(user.email),
                subtitle: const Text('メールアドレス'),
                trailing: user.emailVerified
                    ? const Icon(Icons.verified, color: Colors.green)
                    : TextButton(
                        onPressed: () {
                          // TODO: メール認証機能を実装
                        },
                        child: const Text('認証する'),
                      ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('アカウントを削除'),
                textColor: Colors.red,
                iconColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('アカウントを削除'),
                      content: const Text('本当にアカウントを削除しますか？\nこの操作は取り消せません。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            authController.deleteAccount();
                          },
                          child: const Text(
                            '削除',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          unauthenticated: () => const Center(child: Text('サインインが必要です')),
          error: (message) => Center(child: Text('エラー: $message')),
        ),
        error: (error, stackTrace) => Center(child: Text('エラー: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
} 