import 'package:autoservice/src/features/auth/providers/auth_provider.dart';
import 'package:autoservice/src/features/auth/ui/screens/login_screen.dart';
import 'package:autoservice/src/features/home/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // TODO: Рассмотреть возможность инициализации служб здесь (например, Firebase)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Autoservice App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Используем Consumer для отслеживания статуса аутентификации
      home: const AuthWrapper(),
      // TODO: Настроить роутинг для навигации между экранами (например, go_router)
    );
  }
}

// Виджет-обертка для управления отображением экрана в зависимости от статуса аутентификации
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    switch (authStatus) {
      case AuthStatus.authenticated:
        return const HomeScreen(); // Показываем главный экран, если пользователь вошел
      case AuthStatus.unauthenticated:
        return const LoginScreen(); // Показываем экран входа, если пользователь не вошел
      case AuthStatus.unknown:
      default:
        // Показываем индикатор загрузки, пока статус неизвестен (например, при проверке токена)
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
