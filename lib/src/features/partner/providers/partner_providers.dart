import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';
import 'package:autoservice/src/features/partner/data/partner_repository.dart';
import 'package:autoservice/src/core/network/dio_provider.dart'; // Для dioProvider
import 'package:autoservice/src/features/auth/providers/current_partner_id_provider.dart'; // Для currentPartnerIdProvider

// Провайдер для PartnerRepository
final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PartnerRepository(dio);
});

// Провайдер для получения деталей о текущем партнере
final partnerDetailsProvider = FutureProvider<Partner?>((ref) async {
  final partnerId = ref.watch(currentPartnerIdProvider);
  if (partnerId == null) {
    // Если ID партнера нет (например, пользователь не аутентифицирован как партнер),
    // возвращаем null или выбрасываем ошибку, в зависимости от логики приложения.
    print('partnerDetailsProvider: Partner ID is null.');
    return null;
  }

  final partnerRepository = ref.watch(partnerRepositoryProvider);
  try {
    print('partnerDetailsProvider: Fetching details for partner ID: $partnerId');
    final partner = await partnerRepository.getPartnerDetails(partnerId);
    print('partnerDetailsProvider: Successfully fetched partner details: ${partner.name}');
    return partner;
  } catch (e, stackTrace) {
    print('partnerDetailsProvider: Error fetching partner details for ID $partnerId: $e');
    print(stackTrace);
    // Можно обработать ошибку более специфично или просто передать ее дальше
    // В UI это будет состояние AsyncError
    rethrow; // Передаем исключение, чтобы FutureProvider перешел в состояние ошибки
  }
});

// Провайдер для получения списка всех партнеров
final allPartnersProvider = FutureProvider<List<Partner>>((ref) async {
  final partnerRepository = ref.watch(partnerRepositoryProvider);
  try {
    print('allPartnersProvider: Fetching all partners.');
    final partners = await partnerRepository.getAllPartners();
    print('allPartnersProvider: Successfully fetched ${partners.length} partners.');
    return partners;
  } catch (e) {
    print('allPartnersProvider: Error fetching all partners: $e');
    // Передаем исключение, чтобы FutureProvider перешел в состояние ошибки
    rethrow;
  }
});

// Провайдер для получения деталей о партнере по ID
final partnerDetailsByIdProvider = FutureProvider.family<Partner?, int>((ref, partnerId) async {
  final partnerRepository = ref.watch(partnerRepositoryProvider);
  try {
    print('partnerDetailsByIdProvider: Fetching details for partner ID: $partnerId');
    final partner = await partnerRepository.getPartnerDetails(partnerId.toString());
    print('partnerDetailsByIdProvider: Successfully fetched partner details: ${partner.name}');
    return partner;
  } catch (e, stackTrace) {
    print('partnerDetailsByIdProvider: Error fetching partner details for ID $partnerId: $e');
    print(stackTrace);
    // Можно обработать ошибку более специфично или просто передать ее дальше
    // В UI это будет состояние AsyncError
    rethrow; // Передаем исключение, чтобы FutureProvider перешел в состояние ошибки
  }
});