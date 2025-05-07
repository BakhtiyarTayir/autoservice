// Модель данных для марки автомобиля (Brand)
class Brand {
  final int id;
  final String name;
  // Добавьте другие поля, если они есть в API (например, logoUrl)

  Brand({
    required this.id,
    required this.name,
    // required this.logoUrl,
  });

  // Фабричный конструктор для создания экземпляра Brand из JSON
  factory Brand.fromJson(Map<String, dynamic> json) {
    // Проверяем наличие и тип ключей перед доступом
    final id = json['id'];
    final name = json['name'];

    if (id is! int) {
      throw FormatException('Invalid JSON: "id" is not an int or is missing.');
    }
    if (name is! String) {
      throw FormatException('Invalid JSON: "name" is not a String or is missing.');
    }
    // Добавьте проверки для других полей

    return Brand(
      id: id,
      name: name,
      // logoUrl: json['logo_url'] as String?, // Пример необязательного поля
    );
  }

  // Метод для преобразования экземпляра Brand в JSON (если потребуется)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'logo_url': logoUrl,
    };
  }

  // Переопределение для удобного вывода и сравнения
  @override
  String toString() => 'Brand(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Brand &&
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}