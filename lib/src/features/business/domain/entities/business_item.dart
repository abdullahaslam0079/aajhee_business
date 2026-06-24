import 'package:equatable/equatable.dart';

class BusinessItem extends Equatable {
  const BusinessItem({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    this.description,
    this.category,
    this.isActive = true,
  });

  final String id;
  final String businessId;
  final String name;
  final double price;
  final String? description;
  final String? category;
  final bool isActive;

  BusinessItem copyWith({
    String? id,
    String? businessId,
    String? name,
    double? price,
    String? description,
    String? category,
    bool? isActive,
  }) {
    return BusinessItem(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, businessId, name, price, description, category, isActive];
}
