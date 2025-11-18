import 'package:mongo_dart/mongo_dart.dart';

class Organization {
  ObjectId? id;
  String name;
  String? legalName;
  String? taxId; // Similar to CNPJ in Brazil or EIN in the US.
  String address;
  String city;
  String state;
  String zipCode;
  String country;
  String? phoneNumber;
  String? email;
  String? website;
  DateTime createdAt;
  DateTime updatedAt;

  Organization({
    this.id,
    required this.name,
    this.legalName,
    this.taxId,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.phoneNumber,
    this.email,
    this.website,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'legalName': legalName,
      'taxId': taxId,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static Organization fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['_id'],
      name: map['name'],
      legalName: map['legalName'],
      taxId: map['taxId'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      zipCode: map['zipCode'],
      country: map['country'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      website: map['website'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
