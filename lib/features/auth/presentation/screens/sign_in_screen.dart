import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:gastronomejourney/features/auth/presentation/widgets/auth_text_field.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });

    return AuthScaffold(
      title: 'サインイン',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthTextField(
              controller: emailController,
              labelText: 'メールアドレス',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!value.contains('@')) {
                  return '有効なメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: passwordController,
              labelText: 'パスワード',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                if (value.length < 6) {
                  return 'パスワードは6文字以上で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    await ref.read(authControllerProvider.notifier).signInWithEmail(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                  }
                },
                child: const Text('サインイン'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.push('/auth/reset-password');
              },
              child: const Text('パスワードをお忘れの方'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signInWithGoogle();
                },
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Googleでサインイン'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signInWithApple();
                },
                icon: const Icon(Icons.apple),
                label: const Text('Appleでサインイン'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('アカウントをお持ちでない場合は'),
                TextButton(
                  onPressed: () {
                    context.push('/auth/sign-up');
                  },
                  child: const Text('新規登録'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 