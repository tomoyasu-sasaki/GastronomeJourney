import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:gastronomejourney/features/auth/presentation/widgets/auth_text_field.dart';

class PasswordResetScreen extends HookConsumerWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isEmailSent = useState(false);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        unauthenticated: () {
          isEmailSent.value = true;
        },
      );
    });

    if (isEmailSent.value) {
      return AuthScaffold(
        title: 'パスワードリセット',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'パスワードリセットのメールを送信しました。\nメールの指示に従ってパスワードを再設定してください。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('サインイン画面に戻る'),
              ),
            ),
          ],
        ),
      );
    }

    return AuthScaffold(
      title: 'パスワードリセット',
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'パスワードをリセットするメールアドレスを入力してください。',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AuthTextField(
              controller: emailController,
              labelText: 'メールアドレス',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    await ref
                        .read(authControllerProvider.notifier)
                        .sendPasswordResetEmail(emailController.text);
                  }
                },
                child: const Text('パスワードリセットメールを送信'),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('サインイン画面に戻る'),
            ),
          ],
        ),
      ),
    );
  }
} 