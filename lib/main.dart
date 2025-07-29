import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyRightsApp(),
    ),
  );
}

class MyRightsApp extends ConsumerWidget {
  const MyRightsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create router with authentication awareness
    final router = AppRouter.createRouter(ref);

    return MaterialApp.router(
      title: 'MyRights',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
