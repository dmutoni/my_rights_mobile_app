import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed report types automatically
  await SeedData.seedReportTypes();

  runApp(
    const ProviderScope(
      child: MyRightsApp(),
    ),
  );
}

class MyRightsApp extends ConsumerWidget {
  const MyRightsApp({super.key});

  static bool _hasBeenBuilt = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skipSplash = kDebugMode && _hasBeenBuilt;
    _hasBeenBuilt = true;

    final router = AppRouter.createRouter(ref, skipSplash: skipSplash);

    return MaterialApp.router(
      title: 'MyRights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
