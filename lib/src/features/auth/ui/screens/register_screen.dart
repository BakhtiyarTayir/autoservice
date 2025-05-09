import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // Контроллеры для полей ввода
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final phoneController = TextEditingController();
    final firstNameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Добавляем возможность прокрутки
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
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Подтвердите пароль',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),
              // Отображение ошибки, если есть
              if (authState.errorMessage != null && authState.status != AuthStatus.authenticated) // Показываем ошибку регистрации
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              // Кнопка регистрации
              ElevatedButton(
                // Блокируем кнопку во время выполнения запроса (статус unknown)
                onPressed: authState.status == AuthStatus.unknown
                    ? null
                    : () async { // Делаем колбэк асинхронным
                        final username = usernameController.text.trim();
                        final password = passwordController.text.trim();
                        final confirmPassword = confirmPasswordController.text.trim();
                        final phone = phoneController.text.trim();
                        final firstName = firstNameController.text.trim();

                        if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Заполните обязательные поля: имя пользователя и пароль')),
                          );
                          return;
                        }

                        if (password != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пароли не совпадают')),
                          );
                          return;
                        }

                        // Вызываем метод регистрации и ждем завершения
                        await authNotifier.register(
                          username: username,
                          password: password,
                          phone: phone.isNotEmpty ? phone : null,
                          firstName: firstName.isNotEmpty ? firstName : null,
                        );

                        // Проверяем состояние после регистрации
                        final newState = ref.read(authProvider);
                        if (newState.errorMessage == null && context.mounted) {
                          // Показываем сообщение об успехе
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Регистрация прошла успешно! Теперь вы можете войти.')),
                          );
                          // Возвращаемся на экран входа
                          Navigator.of(context).pop();
                        } else if (context.mounted) {
                          // Ошибка уже отображается через authState.errorMessage
                          // Можно добавить дополнительную логику при необходимости
                        }
                      },
                child: authState.status == AuthStatus.unknown
                    ? const SizedBox( // Используем SizedBox для сохранения размера кнопки
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Зарегистрироваться'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  // TODO: Реализовать навигацию назад на LoginScreen
                  Navigator.of(context).pop(); // Пример возврата назад
                  print('Переход на экран входа');
                },
                child: const Text('Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}