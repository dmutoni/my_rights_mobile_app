import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/learn')) return 1;
    if (location.startsWith('/incident-report')) return 2;
    if (location.startsWith('/aid')) return 3;
    if (location.startsWith('/profile')) return 4;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.learn);
        break;
      case 2:
        context.go(AppRouter.incidentReport);
        break;
      case 3:
        context.go(AppRouter.aid);
        break;
      case 4:
        context.go(AppRouter.profile);
        break;
    }
  }
}
