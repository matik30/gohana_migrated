import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String imageUrl;

  @HiveField(2)
  List<String> ingredients;

  @HiveField(3)
  String procedure;

  @HiveField(4)
  String? category;

  @HiveField(5)
  bool favourite;

  Recipe({
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.procedure,
    this.category,
    this.favourite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> j) => Recipe(
    title: j['title'] as String,
    imageUrl: j['imageUrl'] as String,
    ingredients: List<String>.from(j['ingredients'] as List),
    procedure: j['procedure'] as String,
    category: j['category'] as String?,
    favourite: j['favourite'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'imageUrl': imageUrl,
    'ingredients': ingredients,
    'procedure': procedure,
    'category': category,
    'favourite': favourite,
  };
}
