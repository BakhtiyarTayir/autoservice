import 'package:autoservice/src/features/auth/providers/auth_provider.dart';
import 'package:autoservice/src/features/auth/ui/screens/login_screen.dart';
// import 'package:autoservice/src/features/home/ui/screens/home_screen.dart'; // Больше не нужен прямой импорт HomeScreen здесь
import 'package:autoservice/src/shared/widgets/main_app_shell.dart'; // Импортируем новый MainAppShell
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Autoservice App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'MontserratAce', 
      ),
      home: const AuthWrapper(),
    );
  }
}


class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    switch (authStatus) {
      case AuthStatus.authenticated:
        return const MainAppShell(); 
      case AuthStatus.unauthenticated:
        return const LoginScreen(); 
      case AuthStatus.unknown:
      default:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}

// Стандартный MyHomePage больше не нужен, так как у нас есть AuthWrapper
/*
class MyHomePage extends StatefulWidget { ... }
class _MyHomePageState extends State<MyHomePage> { ... }
*/
