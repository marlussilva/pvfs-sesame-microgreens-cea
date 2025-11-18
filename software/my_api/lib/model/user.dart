import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId? id;
  String? name;
  String? cpf;
  String? phone;
  String? email;
  String? password;
  String? urlPhoto;
  String? salt;

  DateTime? createdAt; // Novo campo
  DateTime? updatedAt; // Novo campo
  DateTime? deletedAt; // Novo campo

  User(
      {this.id,
      this.name,
      this.cpf,
      this.phone,
      this.email,
      this.password,
      this.urlPhoto,
      this.salt,
      this.createdAt, // Novo campo no construtor
      this.updatedAt, // Novo campo no construtor
      this.deletedAt}); // Novo campo no construtor

  User copyWith({
    ObjectId? id,
    String? name,
    String? cpf,
    String? phone,
    String? email,
    String? password,
    String? urlPhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      urlPhoto: urlPhoto ?? this.urlPhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'email': email,
      'password': password,
      'urlPhoto': urlPhoto,
      'createdAt': createdAt?.toIso8601String(), // Novo campo no toMap
      'updatedAt': updatedAt?.toIso8601String(), // Novo campo no toMap
      'deletedAt': deletedAt?.toIso8601String(), // Novo campo no toMap
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String?,
      cpf: map['cpf'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      password: map['password'] as String?,
      urlPhoto: map['urlPhoto'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null, // Novo campo no fromMap
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null, // Novo campo no fromMap
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'])
          : null, // Novo campo no fromMap
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, cpf: $cpf, phone: $phone, email: $email, password: $password, urlPhoto: $urlPhoto, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt}';
  }
}
