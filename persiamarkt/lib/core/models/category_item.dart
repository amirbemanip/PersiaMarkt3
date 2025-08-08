// lib/core/models/category_item.dart
import 'package:equatable/equatable.dart';

class CategoryItem extends Equatable {
  final String categoryID;
  final String name;
  final String nameEn;
  final String description;
  final String icon;

  const CategoryItem({
    required this.categoryID,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.icon,
  });

  @override
  List<Object> get props => [categoryID, name];

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      categoryID: json['categoryID'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}