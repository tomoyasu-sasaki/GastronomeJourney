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
    final isLoading = useState(false);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        loading: () {
          isLoading.value = true;
        },
        authenticated: (_) {
          isLoading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('サインインしました'),
              backgroundColor: Colors.green,
            ),
          );
        },
        error: (message) {
          isLoading.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
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
              enabled: !isLoading.value,
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
              enabled: !isLoading.value,
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
                onPressed: isLoading.value
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await ref.read(authControllerProvider.notifier).signInWithEmail(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                        }
                      },
                child: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('サインイン'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading.value ? null : () {
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
                onPressed: isLoading.value
                    ? null
                    : () {
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
                onPressed: isLoading.value
                    ? null
                    : () {
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
                  onPressed: isLoading.value ? null : () {
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