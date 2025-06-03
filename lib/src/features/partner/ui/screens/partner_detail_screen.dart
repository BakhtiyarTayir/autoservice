import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';
import 'package:autoservice/src/features/partner/providers/partner_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PartnerDetailScreen extends ConsumerWidget {
  final int partnerId;

  const PartnerDetailScreen({
    super.key,
    required this.partnerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Используем новый провайдер для получения деталей партнера по ID
    final partnerDetailsAsync = ref.watch(partnerDetailsByIdProvider(partnerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали автосервиса'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: partnerDetailsAsync.when(
        data: (partner) {
          if (partner == null) {
            return const Center(
              child: Text('Информация о партнере не найдена'),
            );
          }
          return _buildPartnerDetails(context, partner);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Ошибка загрузки данных',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
                onPressed: () {
                  ref.refresh(partnerDetailsByIdProvider(partnerId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerDetails(BuildContext context, Partner partner) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Шапка с логотипом и основной информацией
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Логотип
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: partner.logo != null
                          ? Image.network(
                              'https://api.afix.uz/${partner.logo}',
                              width: 100,
                              height: 100,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 100,
                                height: 100,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.storefront, size: 48, color: Theme.of(context).colorScheme.primary),
                              ),
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              child: Icon(Icons.storefront, size: 48, color: Theme.of(context).colorScheme.primary),
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Название и адрес
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partner.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  partner.address,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                partner.phone,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Кнопки действий
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.phone,
                      label: 'Позвонить',
                      onPressed: () {
                        _makePhoneCall(partner.phoneNumber);
                      },
                    ),
                    _buildActionButton(
                      context: context,
                      icon: Icons.location_on,
                      label: 'На карте',
                      onPressed: () {
                        _openMap(partner.latitude, partner.longitude);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Описание
        if (partner.description != null && partner.description!.isNotEmpty) ...[  
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Описание',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    partner.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Услуги (заглушка)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Услуги',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Все услуги (TODO)')),
                        );
                      },
                      child: const Text('Все услуги'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Заглушка для списка услуг
                const Text('Список услуг будет доступен в ближайшее время'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Фотографии (заглушка)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Фотографии',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Все фотографии (TODO)')),
                        );
                      },
                      child: const Text('Все фото'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Заглушка для фотографий
                const Text('Фотографии будут доступны в ближайшее время'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // Метод для совершения звонка
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Не удалось совершить звонок: $phoneNumber');
    }
  }

  // Метод для открытия карты с использованием map_launcher и параметром zoom
  Future<void> _openMap(double? latitude, double? longitude) async {
    // Получаем BuildContext из текущего состояния виджета
    final BuildContext? currentContext = _getCurrentContext();
    
    if (latitude != null && longitude != null) {
      try {
        // Получаем список доступных карт
        final availableMaps = await MapLauncher.installedMaps;
        
        if (availableMaps.isNotEmpty) {
          if (availableMaps.length == 1) {
            // Если доступна только одна карта, используем её
            await availableMaps.first.showMarker(
              coords: Coords(latitude, longitude),
              title: 'Автосервис',
              zoom: 16, // Устанавливаем уровень масштабирования
            );
          } else if (currentContext != null) {
            // Если доступно несколько карт и есть контекст, показываем диалог выбора
            await _showMapSelectionDialog(currentContext, availableMaps, latitude, longitude);
          } else {
            // Если нет контекста, используем первую доступную карту
            await availableMaps.first.showMarker(
              coords: Coords(latitude, longitude),
              title: 'Автосервис',
              zoom: 16,
            );
          }
        } else {
          // Если нет доступных карт, используем старый метод
          MapsLauncher.launchCoordinates(latitude, longitude);
        }
      } catch (e) {
        // В случае ошибки используем старый метод
        MapsLauncher.launchCoordinates(latitude, longitude);
      }
    }
  }
  
  // Вспомогательный метод для получения текущего контекста
  BuildContext? _getCurrentContext() {
    // В данном случае мы не можем получить контекст напрямую
    // Этот метод будет возвращать null, что обрабатывается в _openMap
    return null;
  }

  // Метод для отображения диалога выбора карты
  Future<void> _showMapSelectionDialog(BuildContext context, List<AvailableMap> availableMaps, double latitude, double longitude) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                ListTile(
                  title: const Text('Выберите приложение'),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(),
                ...availableMaps.map((map) => ListTile(
                  title: Text(map.mapName),
                  // Преобразуем строку SVG в виджет с помощью SvgPicture.string
                  leading: SvgPicture.string(
                    map.icon,
                    height: 30.0,
                    width: 30.0,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    map.showMarker(
                      coords: Coords(latitude, longitude),
                      title: 'Автосервис',
                      zoom: 16,
                    );
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}