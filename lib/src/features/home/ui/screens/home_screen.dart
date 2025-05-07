import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/auth/providers/auth_provider.dart';
import 'package:autoservice/src/shared/providers/data_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    // Следим за состоянием провайдера брендов
    final brandsAsyncValue = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () {
              authNotifier.logout();
              // После выхода, навигация обычно обрабатывается слушателем состояния authProvider
            },
          ),
        ],
      ),
      // Используем .when для обработки состояний FutureProvider
      body: brandsAsyncValue.when(
        data: (brands) {
          // Данные успешно загружены
          if (brands.isEmpty) {
            return const Center(child: Text('Список брендов пуст.'));
          }
          // Отображаем список брендов
          return ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return ListTile(
                title: Text(brand.name),
                // Можно добавить onTap для перехода к моделям этого бренда
                // onTap: () { /* Навигация или другое действие */ },
              );
            },
          );
        },
        loading: () {
          // Идет загрузка
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          // Произошла ошибка
          print('Error loading brands on HomeScreen: $error\n$stackTrace');
          // Показываем пользователю сообщение об ошибке
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Не удалось загрузить бренды. Пожалуйста, попробуйте позже.\nОшибка: ${error.toString()}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}