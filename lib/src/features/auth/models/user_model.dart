// Модель данных для пользователя
class User {
  final int? id; // Делаем id nullable, так как API может не возвращать его при регистрации
  final String username;
  final String? email; // Может быть необязательным
  final String? firstName; // Имя
  final String? lastName; // Фамилия
  final String? phone; // Телефон

  User({
    this.id, // Убираем required, так как id может быть null
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
  });

  // Фабричный конструктор для создания из JSON (пример)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Проверяем, что id не null
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'] ?? json['firstname'], // Проверяем оба возможных ключа
      lastName: json['last_name'],
      phone: json['phone'],
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

    return data;
  }
}