import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) => _navigate(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Reminders',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Family',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(AppRoutes.documents)) return 1;
    if (location.startsWith(AppRoutes.reminders)) return 2;
    if (location.startsWith(AppRoutes.familyVault)) return 3;
    if (location.startsWith(AppRoutes.profile) || location.startsWith(AppRoutes.settings)) return 4;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.documents);
        break;
      case 2:
        context.go(AppRoutes.reminders);
        break;
      case 3:
        context.go(AppRoutes.familyVault);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }
}
