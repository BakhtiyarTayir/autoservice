enum RequestStatus {
  pending,      // Ожидает рассмотрения
  confirmed,    // Подтверждено
  inProgress,   // В работе
  completed,    // Завершена
  cancelled,    // Отменена
  requiresAttention; // Требует внимания (например, доп. информация от пользователя)

  // Helper to convert string to enum and vice-versa
  static RequestStatus fromString(String status) {
    return RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
      orElse: () => RequestStatus.pending, // Default or throw error
    );
  }

  // Helper для преобразования числового статуса в enum
  static RequestStatus fromInt(int statusCode) {
    switch (statusCode) {
      case 0:
        return RequestStatus.pending;
      case 1:
        return RequestStatus.confirmed;
      case 2:
        return RequestStatus.inProgress;
      case 3:
        return RequestStatus.completed;
      case 4:
        return RequestStatus.cancelled;
      case 5:
        return RequestStatus.requiresAttention;
      default:
        return RequestStatus.pending;
    }
  }

  String toJson() => name;
}

class UserRequest {
  final int id;
  final int userId;
  final int? partnerId;
  final int? serviceId; // Может быть null, если заявка общая
  final int? brandId;
  final int? modelId;
  final int? carId; // Новое поле для ID автомобиля
  final String? userCarYear;
  final String? userCarVin;
  final String? userCarMileage;
  final String description;
  final String? preferredDate;
  final String? preferredTime;
  final String contactPhone;
  final RequestStatus status; // Используем enum
  final String createdAt;
  final String updatedAt;
  final String? partnerComment;
  final String? clientComment;
  final String? serviceName;
  final List<String>? attachments; // Ссылки на прикрепленные файлы (фото, видео)
  final String? vehicleInfo; // Дополнительная информация о ТС

  UserRequest({
    required this.id,
    required this.userId,
    this.partnerId,
    this.serviceId,
    this.brandId,
    this.modelId,
    this.carId,
    this.userCarYear,
    this.userCarVin,
    this.userCarMileage,
    required this.description,
    this.preferredDate,
    this.preferredTime,
    required this.contactPhone,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.partnerComment,
    this.clientComment,
    this.serviceName,
    this.attachments,
    this.vehicleInfo,
  });

  // Существующий конструктор для старого формата API
  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      partnerId: json['partner_id'] as int?,
      serviceId: json['service_id'] as int?,
      brandId: json['brand_id'] as int?,
      modelId: json['model_id'] as int?,
      userCarYear: json['user_car_year'] as String?,
      userCarVin: json['user_car_vin'] as String?,
      userCarMileage: json['user_car_mileage'] as String?,
      description: json['description'] as String,
      preferredDate: json['preferred_date'] as String?,
      preferredTime: json['preferred_time'] as String?,
      contactPhone: json['contact_phone'] as String,
      status: RequestStatus.fromString(json['status'] as String),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      partnerComment: json['partner_comment'] as String?,
      clientComment: json['client_comment'] as String?,
      serviceName: json['service_name'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      vehicleInfo: json['vehicle_info'] as String?,
    );
  }
  
  // Новый конструктор для нового формата API
  factory UserRequest.fromJsonV2(Map<String, dynamic> json) {
    // Преобразование числового статуса в enum
    RequestStatus requestStatus;
    if (json['status'] is int) {
      requestStatus = RequestStatus.fromInt(json['status'] as int);
    } else if (json['status'] is String) {
      requestStatus = RequestStatus.fromString(json['status'] as String);
    } else {
      requestStatus = RequestStatus.pending;
    }
    
    // Телефон по умолчанию
    const defaultPhone = "+7 (XXX) XXX-XX-XX";
    
    // Устанавливаем текущие даты для createdAt/updatedAt, так как их нет в новом API
    final currentDate = DateTime.now().toIso8601String();
    
    return UserRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      partnerId: json['partner_id'] as int?,
      serviceId: json['partner_service_id'] as int?, // Другое название поля
      carId: json['car_id'] as int?, // Новое поле
      description: json['comment'] as String? ?? 'Не указано', // Другое название поля
      preferredDate: json['visit_day'] as String?, // Другое название поля
      preferredTime: json['visit_time'] as String?, // Другое название поля
      contactPhone: defaultPhone, // В новом API нет contactPhone, используем заглушку
      status: requestStatus,
      createdAt: currentDate, // Заглушка, так как нет даты создания
      updatedAt: currentDate, // Заглушка, так как нет даты обновления
      // Дополнительные поля не присутствуют в новом API
      serviceName: 'Услуга #${json['partner_service_id']}', // Заглушка для имени услуги
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'partner_id': partnerId,
      'service_id': serviceId,
      'car_id': carId,
      'brand_id': brandId,
      'model_id': modelId,
      'user_car_year': userCarYear,
      'user_car_vin': userCarVin,
      'user_car_mileage': userCarMileage,
      'description': description,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'contact_phone': contactPhone,
      'status': status.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'partner_comment': partnerComment,
      'client_comment': clientComment,
      'service_name': serviceName,
      'attachments': attachments,
      'vehicle_info': vehicleInfo,
    };
  }

  // Опционально: метод copyWith
  UserRequest copyWith({
    int? id,
    int? userId,
    int? partnerId,
    int? serviceId,
    int? brandId,
    int? modelId,
    int? carId,
    String? userCarYear,
    String? userCarVin,
    String? userCarMileage,
    String? description,
    String? preferredDate,
    String? preferredTime,
    String? contactPhone,
    RequestStatus? status,
    String? createdAt,
    String? updatedAt,
    String? partnerComment,
    String? clientComment,
    String? serviceName,
    List<String>? attachments,
    String? vehicleInfo,
    bool clearPartnerId = false,
    bool clearServiceId = false,
  }) {
    return UserRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      partnerId: clearPartnerId ? null : (partnerId ?? this.partnerId),
      serviceId: clearServiceId ? null : (serviceId ?? this.serviceId),
      brandId: brandId ?? this.brandId,
      modelId: modelId ?? this.modelId,
      carId: carId ?? this.carId,
      userCarYear: userCarYear ?? this.userCarYear,
      userCarVin: userCarVin ?? this.userCarVin,
      userCarMileage: userCarMileage ?? this.userCarMileage,
      description: description ?? this.description,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      partnerComment: partnerComment ?? this.partnerComment,
      clientComment: clientComment ?? this.clientComment,
      serviceName: serviceName ?? this.serviceName,
      attachments: attachments ?? this.attachments,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
    );
  }
}