import 'package:autoservice/src/features/partner/data/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/home/providers/home_providers.dart';
import 'package:autoservice/src/features/auth/providers/current_partner_id_provider.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';
import 'package:autoservice/src/features/partner/ui/widgets/partner_list_item.dart'; 
import 'package:autoservice/src/features/requests/ui/screens/partner_requests_screen.dart';
import 'package:autoservice/src/shared/providers/navigation_providers.dart';
import 'package:autoservice/src/features/partner/ui/screens/partner_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currentPartnerId = ref.watch(currentPartnerIdProvider);

    if (currentPartnerId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Определение текущего автосервиса...'),
          ],
        ),
      );
    }

    final partnerDetailsAsync = ref.watch(partnerDetailsProvider(currentPartnerId));
    final partnerRequestsAsync = ref.watch(partnerRequestsProvider(currentPartnerId));
    final allPartnersAsync = ref.watch(allPartnersProvider);

    final List<Color> cardColors = [
      Colors.white, // Изменено на белый
      Theme.of(context).colorScheme.secondaryContainer.withAlpha(178),
      Theme.of(context).colorScheme.tertiaryContainer.withAlpha(178),
      Theme.of(context).colorScheme.primaryContainer.withAlpha(178),
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // НОВЫЙ СЛАЙДЕР АВТОСЕРВИСОВ
        _buildPartnerSlider(context, allPartnersAsync, ref),
        const SizedBox(height: 16),

        // 1. Обзор и управление заявками
        _buildSectionCard(
          context: context,
          title: 'Обзор заявок',
          icon: Icons.list_alt_outlined,
          cardColor: cardColors[0], // Используем первый цвет
          content: partnerRequestsAsync.when(
            data: (requests) {
              final newRequestsCount = requests.where((req) => req.status == RequestStatus.pending).length; // Пример фильтрации
              final upcomingRequest = requests.isNotEmpty ? requests.first.serviceName : 'Нет ближайших записей'; // Пример
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Новых заявок: $newRequestsCount'),
                  const SizedBox(height: 8),
                  Text('Ближайшая запись: $upcomingRequest'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Все заявки'),
                    onPressed: () {
                      // Навигация на экран заявок
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PartnerRequestsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Не удалось загрузить заявки:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Проверьте подключение к интернету и повторите попытку.'),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) => ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                    onPressed: () {
                      if (currentPartnerId != null) {
                        ref.refresh(partnerRequestsProvider(currentPartnerId));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // 4. Быстрая навигация (оставляем как есть)
        _buildSectionCard(
          context: context,
          title: 'Быстрый доступ',
          icon: Icons.explore_outlined,
          cardColor: cardColors[0], // Используем тот же первый цвет для консистентности
          content: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('График'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Переход к графику (TODO)')),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Услуги'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Переход к услугам (TODO)')),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.people_alt_outlined),
                label: const Text('Клиенты'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Переход к клиентам (TODO)')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerSlider(BuildContext context, AsyncValue<List<Partner>> allPartnersAsync, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.car_repair, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Мои автосервисы',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        allPartnersAsync.when(
          data: (partners) {
            if (partners.isEmpty) {
              return const SizedBox.shrink(); // Не отображаем ничего, если нет партнеров
            }
            
            // Проверяем, нужно ли добавлять слайд "Посмотреть все"
            final bool showViewAllSlide = partners.length > 3;
            final int totalItems = showViewAllSlide ? partners.length + 1 : partners.length;
            
            return SizedBox(
              height: 180, // Высота слайдера, можно настроить
              child: PageView.builder(
                itemCount: totalItems,
                controller: PageController(
                  viewportFraction: 0.92, // Увеличиваю заполнение экрана
                ),
                padEnds: false, // Отключаю дополнительные отступы для крайних элементов
                itemBuilder: (context, index) {
                  // Если это последний элемент и нужно показать "Посмотреть все"
                  if (showViewAllSlide && index == partners.length) {
                    return Card(
                      color: Colors.white, // Явно устанавливаем белый цвет
                      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.more_horiz, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text(
                              'У вас еще больше автосервисов',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('Посмотреть все'),
                              onPressed: () {
                                // Переключаем вкладку через провайдер (это изменит BottomNavigationBar)
                                ref.read(selectedTabProvider.notifier).state = 1;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Обычный слайд с автосервисом
                  final partner = partners[index];
                  return Card(
                    color: Colors.white, // Явно устанавливаем белый цвет
                    margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Logo or default icon
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: partner.logo != null
                                    ? Image.network(
                                        'https://api.afix.uz/${partner.logo}',
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 60,
                                          height: 60,
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          child: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
                                        ),
                                      )
                                    : Container(
                                        width: 60,
                                        height: 60,
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        child: Icon(Icons.storefront, color: Theme.of(context).colorScheme.primary),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      partner.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      partner.address,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Additional info or buttons
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(partner.phone, style: Theme.of(context).textTheme.bodySmall),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to partner details
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PartnerDetailScreen(partnerId: partner.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: const Text('Подробнее'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 180, // Такая же высота, как у слайдера, для консистентности
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SizedBox(
            height: 180,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    const Text('Ошибка загрузки данных', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, _) => TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Обновить'),
                        onPressed: () => ref.refresh(allPartnersProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget content,
    List<Widget>? actions,
    Color? cardColor, 
  }) {
    return Card(
      elevation: 2.0,
      color: Colors.white, // Явно устанавливаем белый цвет
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
            if (actions != null && actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }
}