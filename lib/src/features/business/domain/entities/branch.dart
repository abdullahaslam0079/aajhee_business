import 'package:equatable/equatable.dart';

class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.businessId,
    required this.name,
    this.address,
    this.city,
    this.isActive = true,
    this.scanCount = 0,
    this.uniqueUsers = 0,
  });

  final String id;
  final String businessId;
  final String name;
  final String? address;
  final String? city;
  final bool isActive;
  final int scanCount;
  final int uniqueUsers;

  Branch copyWith({
    String? id,
    String? businessId,
    String? name,
    String? address,
    String? city,
    bool? isActive,
    int? scanCount,
    int? uniqueUsers,
  }) {
    return Branch(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
      scanCount: scanCount ?? this.scanCount,
      uniqueUsers: uniqueUsers ?? this.uniqueUsers,
    );
  }

  @override
  List<Object?> get props =>
      [id, businessId, name, address, city, isActive, scanCount, uniqueUsers];
}
