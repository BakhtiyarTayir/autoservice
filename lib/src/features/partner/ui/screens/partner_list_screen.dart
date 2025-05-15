import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/home/providers/home_providers.dart';
import 'package:autoservice/src/features/partner/ui/widgets/partner_list_item.dart';
import 'package:autoservice/src/features/partner/data/partner_model.dart';

class PartnerListScreen extends ConsumerStatefulWidget {
  const PartnerListScreen({super.key});

  @override
  ConsumerState<PartnerListScreen> createState() => _PartnerListScreenState();
}

class _PartnerListScreenState extends ConsumerState<PartnerListScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    // Используем существующий провайдер для получения списка всех партнеров
    final allPartnersAsync = ref.watch(allPartnersProvider);
    
    return Column(
      children: [
        // Поисковая строка
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск автосервисов...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        
        // Основной контент - список или сообщения об ошибках/загрузке
        Expanded(
          child: allPartnersAsync.when(
            data: (partners) {
              // Фильтрация по поисковому запросу
              final filteredPartners = partners.where((partner) => 
                partner.name.toLowerCase().contains(_searchQuery) ||
                (partner.description != null && partner.description!.toLowerCase().contains(_searchQuery)) ||
                partner.address.toLowerCase().contains(_searchQuery)
              ).toList();
              
              // Если нет партнеров после фильтрации, показываем сообщение
              if (filteredPartners.isEmpty) {
                return _buildEmptyState(
                  icon: _searchQuery.isEmpty ? Icons.car_repair : Icons.search_off,
                  title: _searchQuery.isEmpty 
                      ? 'Автосервисы не найдены' 
                      : 'По запросу "$_searchQuery" ничего не найдено',
                  subtitle: _searchQuery.isEmpty
                      ? 'В данный момент список автосервисов пуст'
                      : 'Попробуйте изменить поисковый запрос',
                );
              }
              
              // Отображаем список партнеров
              return RefreshIndicator(
                onRefresh: () async {
                  // Перезагружаем данные при свайпе вниз
                  ref.refresh(allPartnersProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredPartners.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final partner = filteredPartners[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: PartnerListItem(partner: partner),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorState(error, () {
              ref.refresh(allPartnersProvider);
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(Object error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Ошибка загрузки автосервисов',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
} 