import 'package:autoservice/src/features/partner/data/partner_model.dart';
import 'package:autoservice/src/features/partner/data/partner_repository.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';
import 'package:autoservice/src/features/requests/data/user_request_repository.dart';
import 'package:autoservice/src/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для PartnerRepository
final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PartnerRepository(dio);
});

// Провайдер для UserRequestRepository
final userRequestRepositoryProvider = Provider<UserRequestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRequestRepository(dio);
});

// Провайдер для получения деталей конкретного партнера
// Мы передаем ID партнера как family параметр
final partnerDetailsProvider = FutureProvider.family<Partner, String>((ref, partnerId) async {
  final partnerRepository = ref.watch(partnerRepositoryProvider);
  return partnerRepository.getPartnerDetails(partnerId);
});

// Провайдер для получения списка заявок конкретного партнера
// Мы передаем ID партнера как family параметр
final partnerRequestsProvider = FutureProvider.family<List<UserRequest>, String>((ref, partnerId) async {
  final userRequestRepository = ref.watch(userRequestRepositoryProvider);
  return userRequestRepository.getPartnerRequests(partnerId);
});

// Провайдер для получения списка заявок конкретного пользователя
// Мы передаем ID пользователя как family параметр
final userRequestsByUserIdProvider = FutureProvider.family<List<UserRequest>, String>((ref, userId) async {
  final userRequestRepository = ref.watch(userRequestRepositoryProvider);
  return userRequestRepository.getUserRequestsByUserId(userId);
});

// Провайдер для получения списка заявок текущего пользователя
final currentUserRequestsProvider = FutureProvider<List<UserRequest>>((ref) async {
  final userRequestRepository = ref.watch(userRequestRepositoryProvider);
  return userRequestRepository.getCurrentUserRequests();
});

// TODO: Если у вас есть ID текущего пользователя/партнера, который нужно использовать по умолчанию,
// вы можете создать дополнительные провайдеры, которые инкапсулируют этот ID.
// Например:
// final currentPartnerIdProvider = StateProvider<String?>((ref) => null); // или получить из auth state

// final currentPartnerDetailsProvider = FutureProvider<Partner?>((ref) async {
//   final partnerId = ref.watch(currentPartnerIdProvider);
//   if (partnerId == null) return null;
//   return ref.watch(partnerDetailsProvider(partnerId).future);
// });

// Провайдер для получения списка всех партнеров
final allPartnersProvider = FutureProvider<List<Partner>>((ref) async {
  final partnerRepository = ref.watch(partnerRepositoryProvider);
  return partnerRepository.getAllPartners(); // Предполагаем, что такой метод существует или будет создан
});

// final currentPartnerRequestsProvider = FutureProvider<List<UserRequest>?>((ref) async {
//   final partnerId = ref.watch(currentPartnerIdProvider);
//   if (partnerId == null) return [];
//   return ref.watch(partnerRequestsProvider(partnerId).future);
// });