import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/theme/app_colors.dart';
import 'package:my_rights_mobile_app/provider/auth_provider.dart';
import 'package:my_rights_mobile_app/screens/Incident_report/report_incident_screen.dart';
import 'package:my_rights_mobile_app/screens/aid/lawyer_profile_screen.dart';
import 'package:my_rights_mobile_app/screens/aid/lawyers_screen.dart';
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
import 'package:my_rights_mobile_app/screens/aid/organizations_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/all_reports_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/report_abuse_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/view_report_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/review_report_screen.dart';
import 'package:my_rights_mobile_app/screens/incident_report/submission_confirmation_screen.dart';

import 'package:my_rights_mobile_app/screens/profile/profile_screen.dart';
import 'package:my_rights_mobile_app/screens/profile/edit_profile_screen.dart';
import 'package:my_rights_mobile_app/screens/profile/help_screen.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_button.dart';
import 'package:my_rights_mobile_app/shared/widgets/main_scaffold.dart';

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
  static const String help = '/help';
  static const String incidentReport = '/incident-report';

  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(WidgetRef ref, {bool skipSplash = false}) {
    return GoRouter(
      initialLocation: skipSplash ? home : splash,
      refreshListenable: _AuthChangeNotifier(ref),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = ref.read(authProvider);
        final currentPath = state.uri.path;

        // Don't redirect if we're on splash (let splash handle navigation)
        if (currentPath == splash && !skipSplash) {
          return null;
        }

        // If we're skipping splash and on splash, redirect based on auth state
        if (currentPath == splash && skipSplash) {
          if (authState.isAuthenticated) {
            return home;
          } else {
            return welcome;
          }
        }

        // Don't redirect while loading unless we're sure about the state
        if (authState.isLoading && currentPath != welcome) {
          return null;
        }

        final publicRoutes = [welcome, login, signup, forgotPassword];
        final isPublicRoute = publicRoutes.contains(currentPath);

        if (authState.isAuthenticated) {
          if (isPublicRoute) {
            return home;
          }
          return null;
        } else {
          if (isPublicRoute || currentPath == confirmAccount) {
            return null;
          }
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

        // Main app routes with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
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
                        return LessonScreen(
                            courseId: courseId, lessonId: lessonId);
                      },
                      routes: [
                        GoRoute(
                          path: 'quiz',
                          name: 'quiz',
                          builder: (context, state) {
                            final courseId =
                                state.pathParameters['courseId'] ?? '';
                            final lessonId =
                                state.pathParameters['lessonId'] ?? '';
                            return QuizScreen(
                                courseId: courseId, lessonId: lessonId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: aid,
              name: 'aid',
              builder: (context, state) => const OrganizationScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    name: 'lawyers',
                    builder: (context, state) {
                      final organization = state.pathParameters['id'];
                      return LawyersScreen(organization: organization);
                    },
                    routes: [
                      GoRoute(
                        path: ':lawyerId',
                        name: 'lawyer',
                        builder: (context, state) {
                          final id = state.pathParameters['lawyerId'] ?? '';
                          return LawyerProfileScreen(
                            lawyerId: id,
                          );
                        },
                      )
                    ]),
              ],
            ),
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
                  path: 'report-incident',
                  name: 'reportIncident',
                  builder: (context, state) => const ReportIncidentScreen(),
                ),
                GoRoute(
                  path: 'view-report',
                  name: 'viewReport',
                  builder: (context, state) => ViewReportScreen(),
                ),
                GoRoute(
                  path: 'review-report',
                  name: 'reviewReport',
                  builder: (context, state) => const ReviewReportScreen(),
                ),
                GoRoute(
                  path: 'submission-confirmation',
                  name: 'submissionConfirmation',
                  builder: (context, state) =>
                      const SubmissionConfirmationScreen(),
                ),
              ],
            ),
            GoRoute(
              path: profile,
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: '/edit-profile',
                  name: 'editProfile',
                  builder: (context, state) => const EditProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // Standalone routes (no bottom nav)
        GoRoute(
          path: help,
          name: 'help',
          builder: (context, state) => const HelpScreen(),
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
              CustomButton(
                width: 150,
                text: 'Go to Home',
                onPressed: () {
                  context.go(home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated ||
          previous?.isLoading != next.isLoading) {
        notifyListeners();
      }
    });
  }

  final WidgetRef _ref;
}
