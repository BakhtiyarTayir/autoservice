import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/home/providers/home_providers.dart';
import 'package:autoservice/src/features/auth/providers/current_partner_id_provider.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';
import 'package:intl/intl.dart';

class PartnerRequestsScreen extends ConsumerStatefulWidget {
  const PartnerRequestsScreen({super.key});

  @override
  ConsumerState<PartnerRequestsScreen> createState() => _PartnerRequestsScreenState();
}

class _PartnerRequestsScreenState extends ConsumerState<PartnerRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _filterStatus;
  final List<String> _filterOptions = [
    'Все',
    'Ожидают',
    'Подтверждены',
    'В работе',
    'Завершены',
    'Отменены',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Преобразует строку фильтра в RequestStatus
  RequestStatus? _getStatusFromFilter(String? filter) {
    if (filter == null || filter == 'Все') return null;
    
    switch (filter) {
      case 'Ожидают':
        return RequestStatus.pending;
      case 'Подтверждены':
        return RequestStatus.confirmed;
      case 'В работе':
        return RequestStatus.inProgress;
      case 'Завершены':
        return RequestStatus.completed;
      case 'Отменены':
        return RequestStatus.cancelled;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentPartnerId = ref.watch(currentPartnerIdProvider);

    if (currentPartnerId == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Определение текущего автосервиса...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заявки клиентов'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Активные'),
            Tab(text: 'Архив'),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: _filterStatus ?? 'Все',
            items: _filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _filterStatus = newValue != 'Все' ? newValue : null;
              });
            },
            underline: Container(), // Убираем подчеркивание
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (currentPartnerId != null) {
                ref.refresh(partnerRequestsProvider(currentPartnerId));
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Активные заявки: в ожидании, подтвержденные, в процессе
          _buildRequestsList(
            context,
            currentPartnerId,
            (request) {
              // Фильтрация по статусу, если выбран
              final RequestStatus? filterStatus = _getStatusFromFilter(_filterStatus);
              if (filterStatus != null) {
                return request.status == filterStatus && 
                       request.status != RequestStatus.completed && 
                       request.status != RequestStatus.cancelled;
              }
              // Все активные (не завершенные и не отмененные)
              return request.status != RequestStatus.completed && 
                     request.status != RequestStatus.cancelled;
            },
          ),
          
          // Архивные заявки: завершенные и отмененные
          _buildRequestsList(
            context,
            currentPartnerId,
            (request) {
              // Фильтрация по статусу, если выбран
              final RequestStatus? filterStatus = _getStatusFromFilter(_filterStatus);
              if (filterStatus != null) {
                return request.status == filterStatus && 
                      (request.status == RequestStatus.completed || 
                       request.status == RequestStatus.cancelled);
              }
              // Все архивные (завершенные или отмененные)
              return request.status == RequestStatus.completed || 
                     request.status == RequestStatus.cancelled;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Создание новой заявки вручную
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Функция создания заявки в разработке')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    String partnerId,
    bool Function(UserRequest) filter,
  ) {
    final requestsAsync = ref.watch(partnerRequestsProvider(partnerId));

    return requestsAsync.when(
      data: (allRequests) {
        // Применяем фильтр
        final filteredRequests = allRequests.where(filter).toList();

        if (filteredRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Нет заявок',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text('Здесь будут отображаться заявки клиентов'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final request = filteredRequests[index];
            return _buildRequestCard(context, request);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Не удалось загрузить заявки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ошибка: ${err.toString()}',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              onPressed: () {
                ref.refresh(partnerRequestsProvider(partnerId));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, UserRequest request) {
    // Функция для форматирования даты
    String formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return 'Не указано';
      try {
        final date = DateTime.parse(dateString);
        return DateFormat('dd.MM.yyyy').format(date);
      } catch (e) {
        return dateString;
      }
    }

    // Цвет для статуса
    Color getStatusColor(RequestStatus status) {
      switch (status) {
        case RequestStatus.pending:
          return Colors.orange;
        case RequestStatus.confirmed:
          return Colors.blue;
        case RequestStatus.inProgress:
          return Colors.indigo;
        case RequestStatus.completed:
          return Colors.green;
        case RequestStatus.cancelled:
          return Colors.red;
        case RequestStatus.requiresAttention:
          return Colors.deepPurple;
        default:
          return Colors.grey;
      }
    }

    // Текст для статуса
    String getStatusText(RequestStatus status) {
      switch (status) {
        case RequestStatus.pending:
          return 'Ожидает';
        case RequestStatus.confirmed:
          return 'Подтверждена';
        case RequestStatus.inProgress:
          return 'В работе';
        case RequestStatus.completed:
          return 'Завершена';
        case RequestStatus.cancelled:
          return 'Отменена';
        case RequestStatus.requiresAttention:
          return 'Требует внимания';
        default:
          return 'Неизвестно';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.serviceName ?? request.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getStatusColor(request.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: getStatusColor(request.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    getStatusText(request.status),
                    style: TextStyle(
                      color: getStatusColor(request.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('Дата: ${formatDate(request.preferredDate)}'),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('Время: ${request.preferredTime ?? 'Не указано'}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text('Телефон: ${request.contactPhone}'),
              ],
            ),
            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Описание:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.description),
            ],
            if (request.clientComment != null && request.clientComment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Комментарий клиента:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.clientComment!),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Позвонить'),
                  onPressed: () {
                    // TODO: Позвонить клиенту
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Звонок клиенту: ${request.contactPhone}')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Обработать'),
                  onPressed: () {
                    // TODO: Навигация на экран обработки заявки
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Обработка заявки #${request.id}')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 