import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';

// Import screens
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_selection_screen.dart';
import 'screens/login/admin_login_screen.dart';
import 'screens/login/operator_login_screen.dart';
import 'screens/login/operator_signup_screen.dart';
import 'screens/login/hof_login_screen.dart';
import 'screens/form/form_stepper_screen.dart';
import 'screens/form/family_details_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/operator/operator_home_screen.dart';
import 'screens/hof/hof_home_screen.dart';
import 'models/family_model.dart';

class FamilyRegistryApp extends StatefulWidget {
  const FamilyRegistryApp({super.key});

  @override
  State<FamilyRegistryApp> createState() => _FamilyRegistryAppState();
}

class _FamilyRegistryAppState extends State<FamilyRegistryApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final path = state.uri.path;
        final isSplash = path == '/splash';
        final isLogin = path.startsWith('/login') || path.startsWith('/signup');
        
        final isLoggedIn = authProvider.role != UserRole.unauthenticated;

        if (isSplash) return null; // Let splash screen handle its own initial logic

        if (!isLoggedIn && !isLogin && !isSplash) {
          return '/login'; // Unauthenticated trying to access protected route
        }

        if (isLoggedIn && isLogin) {
          // Logged in trying to access login page, redirect to correct dashboard
          switch (authProvider.role) {
            case UserRole.admin:
              return '/admin/dashboard';
            case UserRole.operator:
              return '/operator/home';
            case UserRole.hof:
              return '/hof/home';
            default:
              return '/login';
          }
        }

        // Restrict access based on role
        if (isLoggedIn && !isLogin && !isSplash) {
          if (path.startsWith('/admin') && authProvider.role != UserRole.admin) {
            return '/login';
          }
          if (path.startsWith('/operator') && authProvider.role != UserRole.operator && path != '/operator/new_entry') {
            return '/login';
          }
          if (path.startsWith('/hof') && authProvider.role != UserRole.hof) {
            return '/login';
          }
        }

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/signup/operator',
          builder: (context, state) => const OperatorSignupScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginSelectionScreen(),
        ),
        GoRoute(
          path: '/login/admin',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/login/operator',
          builder: (context, state) => const OperatorLoginScreen(),
        ),
        GoRoute(
          path: '/login/hof',
          builder: (context, state) => const HOFLoginScreen(),
        ),
        GoRoute(
          path: '/operator/new_entry',
          builder: (context, state) => const FormStepperScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/operator/home',
          builder: (context, state) => const OperatorHomeScreen(),
        ),
        GoRoute(
          path: '/hof/home',
          builder: (context, state) => const HOFHomeScreen(),
        ),
        GoRoute(
          path: '/family_details',
          builder: (context, state) {
            final family = state.extra as FamilyModel;
            return FamilyDetailsScreen(family: family);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Family Registry System',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
