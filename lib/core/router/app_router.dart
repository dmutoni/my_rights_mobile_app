import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/screens/auth/confirm_account_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:my_rights_mobile_app/screens/home_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/category_courses_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/course_detail_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/learn_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/login_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/signup_screen.dart';
import 'package:my_rights_mobile_app/screens/splash_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/welcome_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String confirmAccount = '/confirm-account';
  static const String home = '/home';
  static const String learn = '/learn';
  static const String report = '/report';
  static const String aid = '/aid';
  static const String profile = '/profile';

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
        path: learn,
        name: 'learn',
        builder: (context, state) => const LearnScreen(),
      ),
      GoRoute(
        path: '$learn/category/:categoryId',
        name: 'courseCategory',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return CategoryCoursesScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '$learn/course/:courseId',
        name: 'course',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return CourseDetailScreen(courseId: courseId);
        },
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
