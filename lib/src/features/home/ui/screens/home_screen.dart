import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:autoservice/src/features/auth/providers/auth_provider.dart'; // Больше не нужен для authNotifier.logout() здесь
import 'package:autoservice/src/shared/providers/data_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authNotifier = ref.read(authProvider.notifier); // Кнопка выхода теперь в MainAppShell
    final brandsAsyncValue = ref.watch(brandsProvider);

    // Убираем Scaffold и AppBar отсюда
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Главный экран'),
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.logout),
    //         tooltip: 'Выйти',
    //         onPressed: () {
    //           authNotifier.logout();
    //         },
    //       ),
    //     ],
    //   ),
      // Возвращаем только тело экрана
      return brandsAsyncValue.when(
        data: (brands) {
          if (brands.isEmpty) {
            return const Center(child: Text('Список брендов пуст.'));
          }
          return ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              return ListTile(
                title: Text(brand.name),
              );
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          print('Error loading brands on HomeScreen: $error\n$stackTrace');
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
      // ),
    );
  }
}