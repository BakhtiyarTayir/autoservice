import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';
import 'package:autoservice/src/features/requests/data/user_request_repository.dart';
import 'package:autoservice/src/core/network/dio_provider.dart'; // Для dioProvider
import 'package:autoservice/src/features/auth/providers/current_partner_id_provider.dart'; // Для currentPartnerIdProvider

// Провайдер для UserRequestRepository
final userRequestRepositoryProvider = Provider<UserRequestRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UserRequestRepository(dio);
});

// Провайдер для получения списка заявок для текущего партнера
final partnerUserRequestsProvider = FutureProvider<List<UserRequest>>((ref) async {
  final partnerId = ref.watch(currentPartnerIdProvider);
  if (partnerId == null) {
    // Если ID партнера нет, возвращаем пустой список или выбрасываем ошибку.
    // Для списка заявок, вероятно, лучше вернуть пустой список, чтобы UI мог отобразить "Нет заявок".
    print('partnerUserRequestsProvider: Partner ID is null. Returning empty list.');
    return [];
  }

  final userRequestRepository = ref.watch(userRequestRepositoryProvider);
  try {
    print('partnerUserRequestsProvider: Fetching requests for partner ID: $partnerId');
    final requests = await userRequestRepository.getPartnerRequests(partnerId);
    print('partnerUserRequestsProvider: Successfully fetched ${requests.length} requests.');
    return requests;
  } catch (e, stackTrace) {
    print('partnerUserRequestsProvider: Error fetching requests for partner ID $partnerId: $e');
    print(stackTrace);
    // Передаем исключение, чтобы FutureProvider перешел в состояние ошибки
    rethrow;
  }
});