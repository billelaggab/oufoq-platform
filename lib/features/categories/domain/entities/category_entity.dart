import 'package:equatable/equatable.dart';

/// كيان قسم ووردبريس.
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.count = 0,
    this.parentId = 0,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
  final int count;
  final int parentId;

  @override
  List<Object?> get props => <Object?>[id, name];
}
