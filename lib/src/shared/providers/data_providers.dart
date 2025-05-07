import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/shared/models/brand_model.dart';
import 'package:autoservice/src/shared/services/data_service.dart'; // Импортируем сервис

// Провайдер для экземпляра DataService
// Используем Provider, так как сервис сам по себе не изменяет состояние
final dataServiceProvider = Provider<DataService>((ref) {
  return DataService();
});

// FutureProvider для получения списка брендов
// Он автоматически обработает состояния загрузки, ошибки и данных
// Мы передаем `ref`, чтобы получить доступ к dataServiceProvider
final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  // Получаем экземпляр DataService из другого провайдера
  final dataService = ref.watch(dataServiceProvider);
  // Вызываем метод getBrands для загрузки данных
  // Пагинация пока не реализована в провайдере, загружаем первую страницу или все
  return dataService.getBrands();
});

// Если понадобится пагинация в будущем, можно будет использовать StateNotifierProvider
// или передавать параметр page в FutureProvider:
// final brandsProvider = FutureProvider.family<List<Brand>, int?>((ref, page) async {
//   final dataService = ref.watch(dataServiceProvider);
//   return dataService.getBrands(page: page);
// });