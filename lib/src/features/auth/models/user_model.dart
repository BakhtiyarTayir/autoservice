// Модель данных для пользователя
class User {
  final int? id; // Делаем id nullable, так как API может не возвращать его при регистрации
  final String username;
  final String? email; // Может быть необязательным
  final String? firstName; // Имя
  final String? lastName; // Фамилия
  final String? phone; // Телефон
  final String? partnerId; // ID связанного партнера (автосервиса)

  User({
    this.id, // Убираем required, так как id может быть null
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.partnerId,
  });

  // Фабричный конструктор для создания из JSON (пример)
  factory User.fromJson(Map<String, dynamic> json) {
    // Проверяем наличие обязательных полей и их типы
    if (json['username'] == null || json['username'] is! String) {
      throw FormatException('Invalid JSON: "username" is missing or not a String. Received: ${json['username']}');
    }

    return User(
      id: json['id'] as int?, // Проверяем, что id не null и является int
      username: json['username'] as String,
      email: json['email'] as String?,
      firstName: (json['first_name'] ?? json['firstname']) as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      partnerId: json['partner_id'] as String?, // Предполагаем, что API возвращает partner_id
    );
  }

  // Метод для преобразования в JSON (если нужно отправлять данные)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
    };

    // Добавляем поля только если они не null
    if (id != null) data['id'] = id;
    if (email != null) data['email'] = email;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (partnerId != null) data['partner_id'] = partnerId;

    return data;
  }
}