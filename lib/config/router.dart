// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/password_reset_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/profile_screen.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/home/presentation/screens/home_screen.dart';

part 'router.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/auth/sign-in',
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (state) => state.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        ),
        error: (_, __) => false,
        loading: () => false,
      );

      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      // 認証済みの場合、認証関連ページにアクセスするとホームにリダイレクト
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }

      // 未認証の場合、認証関連ページ以外にアクセスするとサインインページにリダイレクト
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/sign-in';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/sign-in',
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
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
} 