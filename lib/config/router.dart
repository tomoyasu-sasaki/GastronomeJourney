// import 'package:flutter/material.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
// import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_in_screen.dart';
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
      return authState.when(
        data: (authState) => authState.when(
          initial: () => null,
          loading: () => null,
          authenticated: (_) => state.matchedLocation == '/sign-in' ? '/' : null,
          unauthenticated: () => '/sign-in',
          error: (_) => '/sign-in',
        ),
        loading: () => null,
        error: (_, __) => '/sign-in',
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