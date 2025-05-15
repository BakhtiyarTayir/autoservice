import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/providers/auth_provider.dart';
import 'package:autoservice/src/features/auth/ui/screens/register_screen.dart'; // Добавлен импорт

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    // Контроллеры для полей ввода
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Имя пользователя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true, // Скрыть пароль
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            // Отображение ошибки, если есть
            if (authState.status == AuthStatus.unauthenticated && authState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            // Кнопка входа
            ElevatedButton(
              onPressed: authState.status == AuthStatus.unknown // Блокируем кнопку во время загрузки
                  ? null
                  : () {
                      final username = usernameController.text;
                      final password = passwordController.text;
                      if (username.isNotEmpty && password.isNotEmpty) {
                        authNotifier.login(username, password);
                      } else {
                        // Можно показать сообщение о необходимости заполнить поля
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Заполните имя пользователя и пароль')),
                        );
                      }
                    },
              child: authState.status == AuthStatus.unknown
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Войти'),
            ),
            const SizedBox(height: 16.0),
            // TODO: Добавить кнопку для перехода на экран регистрации
            TextButton(
              onPressed: () {
                // Переходим на экран регистрации
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Нет аккаунта? Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}