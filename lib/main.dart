import 'package:flutter/material.dart';

import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_user_list_screen.dart';
import 'screens/admin_verification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/user_form_screen.dart';
import 'widgets/admin_theme.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppServices.initialize();
  await AppServices.auth.restore();
  runApp(const RutaSeguraApp());
}

class RutaSeguraApp extends StatefulWidget {
  const RutaSeguraApp({super.key});

  @override
  State<RutaSeguraApp> createState() => _RutaSeguraAppState();
}

class _RutaSeguraAppState extends State<RutaSeguraApp> {
  @override
  void initState() {
    super.initState();
    AppServices.auth.addListener(_handleSessionChange);
  }

  @override
  void dispose() {
    AppServices.auth.removeListener(_handleSessionChange);
    super.dispose();
  }

  void _handleSessionChange() {
    if (!AppServices.auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
      });
    }
  }

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Ruta Segura',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.navy,
          primary: AdminColors.navy,
          secondary: AdminColors.selago,
          surface: AdminColors.surface,
        ),
        scaffoldBackgroundColor: AdminColors.page,
        fontFamily: 'Inter',
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: (settings) {
        final isPublic = settings.name == LoginScreen.routeName;
        if (!isPublic && !AppServices.auth.isAuthenticated) {
          return MaterialPageRoute<void>(
            settings: const RouteSettings(name: LoginScreen.routeName),
            builder: (_) => const LoginScreen(),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (context) {
            return switch (settings.name) {
              LoginScreen.routeName => const LoginScreen(),
              AdminDashboardScreen.routeName => const AdminDashboardScreen(),
              AdminUserListScreen.routeName => const AdminUserListScreen(),
              AdminVerificationScreen.routeName => const AdminVerificationScreen(),
              CreateUserFormScreen.routeName => const CreateUserFormScreen(),
              EditUserFormScreen.routeName => EditUserFormScreen(
                  userId: _routeArgument(settings.arguments),
                ),
              UserDetailsScreen.routeName => UserDetailsScreen(
                  userId: _routeArgument(settings.arguments),
                ),
              _ => const LoginScreen(),
            };
          },
        );
      },
    );
  }

  String _routeArgument(Object? argument) {
    return argument is String ? argument : 'USR-001';
  }
}
