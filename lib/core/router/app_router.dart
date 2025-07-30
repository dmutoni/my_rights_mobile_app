import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/screens/auth/confirm_account_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:my_rights_mobile_app/screens/home_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/category_courses_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/course_detail_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/learn_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/login_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/signup_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/lesson_screen.dart';
import 'package:my_rights_mobile_app/screens/learn/quiz_screen.dart';
import 'package:my_rights_mobile_app/screens/splash_screen.dart';
import 'package:my_rights_mobile_app/screens/auth/welcome_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/all_reports_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/report_abuse_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/view_report_screen.dart';
import 'package:my_rights_mobile_app/models/incident_report_model.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String confirmAccount = '/confirm-account';
  static const String home = '/home';
  static const String learn = '/learn';
  static const String aid = '/aid';
  static const String profile = '/profile';
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
          path: learn,
          name: 'learn',
          builder: (context, state) => const LearnScreen(),
          routes: [
            GoRoute(
              path: '/category/:categoryId',
              name: 'courseCategory',
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId'] ?? '';
                return CategoryCoursesScreen(categoryId: categoryId);
              },
            ),
            GoRoute(
              path: '/course/:courseId',
              name: 'course',
              builder: (context, state) {
                final courseId = state.pathParameters['courseId'] ?? '';
                return CourseDetailScreen(courseId: courseId);
              },
              routes: [
                GoRoute(
                  path: 'lesson/:lessonId',
                  name: 'lesson',
                  builder: (context, state) {
                    final courseId = state.pathParameters['courseId'] ?? '';
                    final lessonId = state.pathParameters['lessonId'] ?? '';
                    return LessonScreen(courseId: courseId, lessonId: lessonId);
                  },
                  routes: [
                    GoRoute(
                      path: 'quiz',
                      name: 'quiz',
                      builder: (context, state) {
                        final courseId = state.pathParameters['courseId'] ?? '';
                        final lessonId = state.pathParameters['lessonId'] ?? '';
                        return QuizScreen(
                            courseId: courseId, lessonId: lessonId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ]),
      GoRoute(
        path: incidentReport,
        name: 'incidentReport',
        builder: (context, state) => const AllReportsScreen(),
        routes: [
          GoRoute(
            path: 'report-abuse',
            name: 'reportAbuse',
            builder: (context, state) => const ReportAbuseScreen(),
          ),
          GoRoute(
            path: 'view-report',
            name: 'viewReport',
            builder: (context, state) {
              final report = state.extra as IncidentReport?;
              if (report == null) {
                return Scaffold(
                  body: Center(child: Text('No report provided.')),
                );
              }
              return ViewReportScreen(report: report);
            },
          ),
        ],
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
              color: AppColors.error,
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
