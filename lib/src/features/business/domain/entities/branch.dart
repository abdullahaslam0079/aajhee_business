import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.name,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.businessId = '',
    this.isActive = true,
    this.scanCount = 0,
    this.uniqueUsers = 0,
  });

  final String id;
  final String businessId;
  final String name;
  final String street;
  final String houseNumber;
  final String postalCode;
  final String city;
  final double latitude;
  final double longitude;
  final bool isActive;
  final int scanCount;
  final int uniqueUsers;

  String get formattedAddress => '$street $houseNumber, $postalCode $city';

  /// Legacy alias used by list screens.
  String? get address => '$street $houseNumber';

  Branch copyWith({
    String? id,
    String? businessId,
    String? name,
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
    double? latitude,
    double? longitude,
    bool? isActive,
    int? scanCount,
    int? uniqueUsers,
  }) {
    return Branch(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      scanCount: scanCount ?? this.scanCount,
      uniqueUsers: uniqueUsers ?? this.uniqueUsers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        street,
        houseNumber,
        postalCode,
        city,
        latitude,
        longitude,
        isActive,
        scanCount,
        uniqueUsers,
      ];
}
