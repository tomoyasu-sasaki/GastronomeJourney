import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gastronomejourney/features/auth/presentation/providers/auth_provider.dart';
import 'package:gastronomejourney/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:gastronomejourney/features/home/presentation/screens/main_screen.dart';
import 'package:go_router/go_router.dart';

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
    ],
  );
}); 