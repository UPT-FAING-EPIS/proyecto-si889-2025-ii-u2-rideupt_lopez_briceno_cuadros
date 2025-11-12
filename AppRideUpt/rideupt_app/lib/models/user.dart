// lib/models/user.dart

class Vehicle {
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final int totalSeats; // NUEVO: Total de asientos del vehículo

  Vehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.totalSeats,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 0,
      color: json['color'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      totalSeats: json['totalSeats'] ?? 4, // Por defecto 4 asientos
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'licensePlate': licensePlate,
      'totalSeats': totalSeats,
    };
  }
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String phone;
  final String university;
  final String studentId; // NUEVO: Código de estudiante
  final String profilePhoto; // NUEVO: URL de foto de perfil
  final int? age; // NUEVO: Edad (opcional)
  final String? gender; // NUEVO: Sexo (opcional)
  final String? bio; // NUEVO: Biografía (opcional)
  final Vehicle? vehicle;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phone,
    required this.university,
    required this.studentId,
    this.profilePhoto = 'default_avatar.png',
    this.age,
    this.gender,
    this.bio,
    this.vehicle,
  });

  /// Obtiene el nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Obtiene las iniciales del usuario
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  /// Verifica si es conductor
  bool get isDriver => role == 'driver';

  /// Verifica si es pasajero
  bool get isPassenger => role == 'passenger';

  /// Verifica si el perfil está completo
  bool get isProfileComplete {
    return phone != 'Pendiente' && 
           phone.isNotEmpty && 
           age != null;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? 'Usuario',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'passenger',
      phone: json['phone'] ?? 'Pendiente',
      university: json['university'] ?? 'UPT',
      studentId: json['studentId'] ?? _extractStudentIdFromEmail(json['email'] ?? ''),
      profilePhoto: json['profilePhoto'] ?? 'default_avatar.png',
      age: json['age'],
      gender: json['gender'],
      bio: json['bio'],
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phone': phone,
      'university': university,
      'studentId': studentId,
      'profilePhoto': profilePhoto,
      'age': age,
      'gender': gender,
      'bio': bio,
      'vehicle': vehicle?.toJson(),
    };
  }

  /// Extrae el código de estudiante del email
  /// Ejemplo: jb2017059611@virtual.upt.pe -> 2017059611
  static String _extractStudentIdFromEmail(String email) {
    if (email.isEmpty) return 'N/A';
    
    // Patrón: letras + números + @
    // Ejemplo: jb2017059611@virtual.upt.pe
    final regex = RegExp(r'[a-z]+(\d+)@', caseSensitive: false);
    final match = regex.firstMatch(email);
    
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? 'N/A';
    }
    
    return 'N/A';
  }

  /// Copia el usuario con campos actualizados
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phone,
    String? university,
    String? studentId,
    String? profilePhoto,
    int? age,
    String? gender,
    String? bio,
    Vehicle? vehicle,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      studentId: studentId ?? this.studentId,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}
