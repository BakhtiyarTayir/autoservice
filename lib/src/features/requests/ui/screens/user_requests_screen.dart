import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/home/providers/home_providers.dart';
import 'package:autoservice/src/features/requests/data/user_request_model.dart';
import 'package:intl/intl.dart';

class UserRequestsScreen extends ConsumerWidget {
  const UserRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем заявки текущего пользователя
    final requestsAsync = ref.watch(currentUserRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заявки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Invalidate the cache and refresh
              ref.invalidate(currentUserRequestsProvider);
            },
          ),
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'У вас нет заявок',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Вы можете создать новую заявку, нажав на кнопку внизу',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(context, request);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Extract the most relevant error message
          String errorMessage = 'Не удалось загрузить заявки';
          if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
            errorMessage = 'Необходимо повторно войти в систему';
          } else if (error.toString().contains('network') || error.toString().contains('timeout')) {
            errorMessage = 'Проблема с сетевым подключением';
          }
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                  onPressed: () {
                    // Invalidate the cache and refresh
                    ref.invalidate(currentUserRequestsProvider);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Создание новой заявки
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Создание новой заявки (будет реализовано позже)')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, UserRequest request) {
    // Функция для форматирования даты
    String formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty || dateString == '0000-00-00') {
        return 'Не указано';
      }
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
            if (request.preferredDate != null || request.preferredTime != null) ...[
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
            ],
            if (request.partnerId != null) ...[
              Row(
                children: [
                  const Icon(Icons.business, size: 16),
                  const SizedBox(width: 4),
                  Text('Автосервис #${request.partnerId}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (request.carId != null) ...[
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16),
                  const SizedBox(width: 4),
                  Text('Автомобиль #${request.carId}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (request.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              const Text(
                'Описание:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.description),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Позвонить'),
                  onPressed: () {
                    // TODO: Позвонить в автосервис
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Звонок в автосервис')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Отменить'),
                  onPressed: () {
                    // TODO: Отмена заявки
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Отмена заявки #${request.id}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 