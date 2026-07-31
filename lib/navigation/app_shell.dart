import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/connectivity_service.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = state.uri.path;
    int currentIndex = 0;
    if (location == '/') {
      currentIndex = 0;
    } else if (location == '/planner') {
      currentIndex = 1;
    } else if (location.startsWith('/subjects') || location.startsWith('/notes')) {
      currentIndex = 2;
    } else if (location.startsWith('/settings')) {
      currentIndex = 3;
    } else {
      currentIndex = 0;
    }

    return StreamBuilder<bool>(
      stream: ConnectivityService().onConnectivityChanged,
      initialData: true,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        return Column(
          children: [
            if (!isOnline)
              Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You are offline. Some features may be limited.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final online =
                            await ConnectivityService().isOnline;
                        if (online) {
                          messenger.hideCurrentSnackBar();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Still offline. Please check your connection.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'RETRY',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
            NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/planner');
                    break;
                  case 2:
                    context.go('/notes');
                    break;
                  case 3:
                    context.go('/settings');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'Planner',
                ),
                NavigationDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: 'Notes',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
