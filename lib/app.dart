import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/auth/login_page.dart';
import 'screens/home/home_page.dart';
import 'screens/tasks/task_form_page.dart';
import 'services/theme_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) => MaterialApp(
          title: 'Focus.Me',
          themeMode: themeService.theme,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: const RootPage(),
          routes: {
            '/task_form': (context) => const TaskFormPage(),
          },
        ),
      ),
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (auth.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (auth.user == null) {
          return const LoginPage();
        }
        return const HomePage();
      },
    );
  }
}
