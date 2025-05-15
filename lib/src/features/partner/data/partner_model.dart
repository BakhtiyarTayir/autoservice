// lib/src/core/models/partner.dart

class PartnerService {
  final int id;
  final String name;
  final String price;
  final int serviceCategoryId;

  PartnerService({
    required this.id,
    required this.name,
    required this.price,
    required this.serviceCategoryId,
  });

  factory PartnerService.fromJson(Map<String, dynamic> json) {
    return PartnerService(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as String,
      serviceCategoryId: json['service_category_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'service_category_id': serviceCategoryId,
    };
  }
}

class PartnerPhoto {
  final int id;
  final String url;

  PartnerPhoto({
    required this.id,
    required this.url,
  });

  factory PartnerPhoto.fromJson(Map<String, dynamic> json) {
    return PartnerPhoto(
      id: json['id'] as int,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class Partner {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String address;
  final int region;
  final String location;
  final String phone;
  final int status;

  Partner({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    required this.address,
    required this.region,
    required this.location,
    required this.phone,
    required this.status,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      address: json['adress'] as String, // Note: API uses "adress" not "address"
      region: json['region'] as int,
      location: json['location'] as String,
      phone: json['phone'] as String,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'adress': address, // Note: API uses "adress" not "address"
      'region': region,
      'location': location,
      'phone': phone,
      'status': status,
    };
  }
  
  // Helper getters
  String get phoneNumber => phone;
  String? get imageUrl => logo;
  
  // Parse location string "longitude:latitude" into individual components
  double? get latitude {
    final parts = location.split(':');
    if (parts.length == 2) {
      return double.tryParse(parts[1]);
    }
    return null;
  }
  
  double? get longitude {
    final parts = location.split(':');
    if (parts.length == 2) {
      return double.tryParse(parts[0]);
    }
    return null;
  }
}