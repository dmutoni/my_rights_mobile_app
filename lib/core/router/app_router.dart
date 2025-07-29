import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/screens/confirm_account_screen.dart';
import 'package:my_rights_mobile_app/screens/forgot_password_screen.dart';
import 'package:my_rights_mobile_app/screens/home_screen.dart';
import 'package:my_rights_mobile_app/screens/login_screen.dart';
import 'package:my_rights_mobile_app/screens/signup_screen.dart';
import 'package:my_rights_mobile_app/screens/splash_screen.dart';
import 'package:my_rights_mobile_app/screens/welcome_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String confirmAccount = '/confirm-account';
  static const String home = '/home';

  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: splash,
      refreshListenable: GoRouterRefreshStream(
        ref.watch(authProvider.notifier).stream,
      ),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = ref.read(authProvider);
        final currentPath = state.uri.path;

        print('🗺️ Router redirect check:');
        print('   Current path: $currentPath');
        print('   Is authenticated: ${authState.isAuthenticated}');
        print('   Is loading: ${authState.isLoading}');
        print('   User: ${authState.user?.email ?? "null"}');

        // Don't redirect if we're on splash (let splash handle navigation)
        if (currentPath == splash) {
          print('   ➡️ Staying on splash');
          return null;
        }

        // If we're loading auth state, stay where we are
        if (authState.isLoading) {
          print('   ⏳ Auth loading, staying on current path');
          return null;
        }

        // Define public routes (accessible without authentication)
        final publicRoutes = [welcome, login, signup, forgotPassword];
        final isPublicRoute = publicRoutes.contains(currentPath);

        if (authState.isAuthenticated) {
          // User is authenticated
          if (isPublicRoute) {
            // Redirect authenticated users away from auth pages to home
            print(
                '   ✅ Authenticated user on public route → redirecting to home');
            return home;
          }
          // Let authenticated users access protected routes
          print('   ✅ Authenticated user on protected route → allowing access');
          return null;
        } else {
          // User is not authenticated
          if (isPublicRoute || currentPath == confirmAccount) {
            // Allow access to public routes and confirm account
            print(
                '   🔓 Unauthenticated user on public route → allowing access');
            return null;
          }
          // Redirect unauthenticated users to welcome
          print(
              '   ❌ Unauthenticated user on protected route → redirecting to welcome');
          return welcome;
        }
      },
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: signup,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: confirmAccount,
          name: 'confirmAccount',
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return ConfirmAccountScreen(email: email);
          },
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found: ${state.uri}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(welcome),
                child: const Text('Go to Welcome'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom refresh stream for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
