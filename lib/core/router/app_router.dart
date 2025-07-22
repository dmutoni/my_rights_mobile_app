import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/screens/confirm_account_screen.dart';
import 'package:my_rights_mobile_app/screens/forgot_password_screen.dart';
import 'package:my_rights_mobile_app/screens/home_screen.dart';
import 'package:my_rights_mobile_app/screens/login_screen.dart';
import 'package:my_rights_mobile_app/screens/signup_screen.dart';
import 'package:my_rights_mobile_app/screens/splash_screen.dart';
import 'package:my_rights_mobile_app/screens/welcome_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/all_reports_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String confirmAccount = '/confirm-account';
  static const String home = '/home';
  static const String incidentReport = '/incident-report';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
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
      GoRoute(
        path: incidentReport,
        name: 'incidentReport',
        builder: (context, state) => const AllReportsScreen(),
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
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
