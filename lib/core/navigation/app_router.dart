import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/presentation/providers/auth_provider.dart';
import 'package:star_frontend/presentation/screens/auth/login_screen.dart';
import 'package:star_frontend/presentation/screens/home/home_screen.dart';
import 'package:star_frontend/presentation/screens/challenges/challenges_screen.dart';
import 'package:star_frontend/presentation/screens/challenges/challenge_detail_screen.dart';
import 'package:star_frontend/presentation/screens/challenges/user_participations_screen.dart';
import 'package:star_frontend/presentation/screens/leaderboard/leaderboard_screen.dart';
import 'package:star_frontend/presentation/screens/profile/profile_screen.dart';
import 'package:star_frontend/presentation/screens/splash/splash_screen.dart';
import 'package:star_frontend/core/utils/logger.dart';

/// Application router configuration
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      redirect: _handleRedirect,
      routes: [
        // Splash Screen
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Main App Shell with Bottom Navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainShell(child: child);
          },
          routes: [
            // Home
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),

            // Challenges
            GoRoute(
              path: '/challenges',
              name: 'challenges',
              builder: (context, state) => const ChallengesScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  name: 'challenge-detail',
                  builder: (context, state) {
                    final challengeId = state.pathParameters['id']!;
                    return ChallengeDetailScreen(challengeId: challengeId);
                  },
                ),
                GoRoute(
                  path: 'my-participations',
                  name: 'my-participations',
                  builder: (context, state) => const UserParticipationsScreen(),
                ),
              ],
            ),

            // Leaderboard
            GoRoute(
              path: '/leaderboard',
              name: 'leaderboard',
              builder: (context, state) => const LeaderboardScreen(),
            ),

            // Profile
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => ErrorScreen(error: state.error),
    );
  }

  /// Handle route redirects based on authentication state
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    final isInitialized = authProvider.isInitialized;
    final currentLocation = state.uri.toString();

    AppLogger.navigation(
      'Route redirect check',
      'Location: $currentLocation, Authenticated: $isAuthenticated, Initialized: $isInitialized',
    );

    // If not initialized, stay on splash
    if (!isInitialized && currentLocation != '/splash') {
      AppLogger.navigation('Redirecting to splash', 'Not initialized');
      return '/splash';
    }

    // If initialized but not authenticated, redirect to login
    if (isInitialized && !isAuthenticated && currentLocation != '/login') {
      AppLogger.navigation('Redirecting to login', 'Not authenticated');
      return '/login';
    }

    // If authenticated and on auth screens, redirect to home
    if (isAuthenticated &&
        (currentLocation == '/login' || currentLocation == '/splash')) {
      AppLogger.navigation('Redirecting to home', 'Authenticated');
      return '/home';
    }

    // No redirect needed
    return null;
  }

  /// Navigate to home screen
  static void goHome(BuildContext context) {
    context.goNamed('home');
  }

  /// Navigate to login screen
  static void goLogin(BuildContext context) {
    context.goNamed('login');
  }

  /// Navigate to challenges screen
  static void goChallenges(BuildContext context) {
    context.goNamed('challenges');
  }

  /// Navigate to challenge detail screen
  static void goChallengeDetail(BuildContext context, String challengeId) {
    context.goNamed('challenge-detail', pathParameters: {'id': challengeId});
  }

  /// Navigate to user participations screen
  static void goMyParticipations(BuildContext context) {
    context.goNamed('my-participations');
  }

  /// Navigate to leaderboard screen
  static void goLeaderboard(BuildContext context) {
    context.goNamed('leaderboard');
  }

  /// Navigate to profile screen
  static void goProfile(BuildContext context) {
    context.goNamed('profile');
  }

  /// Navigate back
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goHome(context);
    }
  }

  /// Get current route name
  static String? getCurrentRouteName(BuildContext context) {
    final routerDelegate = GoRouter.of(context).routerDelegate;
    final routeMatch = routerDelegate.currentConfiguration.last;
    return routeMatch.route.name;
  }

  /// Check if current route is
  static bool isCurrentRoute(BuildContext context, String routeName) {
    return getCurrentRouteName(context) == routeName;
  }
}

/// Main app shell with bottom navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const BottomNavBar());
  }
}

/// Bottom navigation bar
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (currentLocation.startsWith('/challenges')) {
      selectedIndex = 1;
    } else if (currentLocation.startsWith('/leaderboard')) {
      selectedIndex = 2;
    } else if (currentLocation.startsWith('/profile')) {
      selectedIndex = 3;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Challenges',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.leaderboard),
          label: 'Classement',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        AppRouter.goHome(context);
        break;
      case 1:
        AppRouter.goChallenges(context);
        break;
      case 2:
        AppRouter.goLeaderboard(context);
        break;
      case 3:
        AppRouter.goProfile(context);
        break;
    }
  }
}

/// Error screen for navigation errors
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Une erreur est survenue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Erreur inconnue',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => AppRouter.goHome(context),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
