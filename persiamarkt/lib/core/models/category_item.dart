import 'package:equatable/equatable.dart';

class CategoryItem extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String? description;
  final String? iconUrl;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.nameEn,
    this.description,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name];

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      // FIXED: Safely convert the integer ID from the API to a String.
      id: json['id'].toString(),
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }
}
