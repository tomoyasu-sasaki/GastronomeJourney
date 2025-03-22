// import 'package:flutter/material.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
// import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:gastronomejourney/features/home/presentation/screens/main_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/izakaya/domain/izakaya.dart';
import '../features/izakaya/presentation/izakaya_form_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // 認証関連の画面パスのリスト
      final isAuthRoute = [
        '/sign-in',
        '/auth/sign-up',
        '/auth/reset-password',
      ].contains(state.matchedLocation);

      return authState.when(
        data: (authState) => authState.when(
          initial: () => null,
          loading: () => null,
          authenticated: (_) {
            // 認証済みの場合、認証関連画面にアクセスしようとしたらホームにリダイレクト
            return isAuthRoute ? '/' : null;
          },
          unauthenticated: () {
            // 未認証の場合、認証関連画面以外へのアクセスはサインイン画面にリダイレクト
            return !isAuthRoute ? '/sign-in' : null;
          },
          error: (_) => !isAuthRoute ? '/sign-in' : null,
        ),
        loading: () => null,
        error: (_, __) => !isAuthRoute ? '/sign-in' : null,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/izakaya/new',
        builder: (context, state) => const IzakayaFormScreen(),
      ),
      GoRoute(
        path: '/izakaya/:id/edit',
        builder: (context, state) {
          final izakaya = state.extra as Izakaya;
          return IzakayaFormScreen(izakaya: izakaya);
        },
      ),
    ],
  );
});