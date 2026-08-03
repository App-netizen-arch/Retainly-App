import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/connectivity_service.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final ConnectivityService _connectivity = ConnectivityService();
  bool _isOnline = false;
  Timer? _offlineBarTimer;
  StreamSubscription<bool>? _subscription;

  void _dismissOfflineBar() {
    _offlineBarTimer?.cancel();
    if (mounted) setState(() => _isOnline = true);
  }

  @override
  void initState() {
    super.initState();
    _subscription = _connectivity.onConnectivityChanged.listen((online) {
      debugPrint('[AppShell] Connectivity stream: online=$online');
      if (online) {
        _connectivity.isOnline.then((reachable) {
          if (mounted) {
            setState(() => _isOnline = reachable);
            debugPrint('[AppShell] Reachability check: reachable=$reachable');
          }
        });
      } else {
        if (mounted) setState(() => _isOnline = false);
        _offlineBarTimer?.cancel();
        _offlineBarTimer = Timer(const Duration(seconds: 4), () {
          _dismissOfflineBar();
        });
      }
    });
    _connectivity.isOnline.then((online) {
      debugPrint('[AppShell] Initial reachability: online=$online');
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _offlineBarTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = widget.state.uri.path;
    int currentIndex = 0;
    if (location == '/') {
      currentIndex = 0;
    } else if (location == '/planner') {
      currentIndex = 1;
    } else if (location.startsWith('/subjects') ||
        location.startsWith('/notes')) {
      currentIndex = 2;
    } else if (location == '/backup') {
      currentIndex = 4;
    } else if (location.startsWith('/settings')) {
      currentIndex = 3;
    } else {
      currentIndex = 0;
    }

    return Column(
      children: [
        if (!_isOnline)
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.error,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Theme.of(context).colorScheme.onError),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are offline. Some features may be limited.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onError),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final errorColor = Theme.of(context).colorScheme.error;
                    final online = await _connectivity.isOnline;
                    if (mounted) {
                      setState(() => _isOnline = online);
                    }
                    if (online) {
                      messenger.hideCurrentSnackBar();
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Still offline. Please check your connection.',
                          ),
                          backgroundColor: errorColor,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'RETRY',
                    style: TextStyle(color: Theme.of(context).colorScheme.onError),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: widget.child),
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
              case 4:
                context.go('/backup');
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
            NavigationDestination(
              icon: Icon(Icons.backup_outlined),
              selectedIcon: Icon(Icons.backup),
              label: 'Backup',
            ),
          ],
        ),
      ],
    );
  }
}
