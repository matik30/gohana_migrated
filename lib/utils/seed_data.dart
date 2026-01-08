import 'package:hive/hive.dart';
import '../models/recipe.dart';

Future<void> seedRecipes() async {
  final box = Hive.box<Recipe>('recipes');

  // ak už sú recepty v Hive, nezasievať znova
  if (box.isNotEmpty) return;

  final List<Recipe> initial = [
    Recipe(
      title: 'Baked Buns',
      imageUrl: 'assets/images/buns.jpg',
      ingredients: [
        '500 g plain flour',
        '40 g yeast',
        '3 dcL milk',
        '½ dcL oil',
        '2 tbsp sugar',
        '1 tsp salt',
        'filling'
      ],
      procedure:
          'Mix all the ingredients for the dough and let the dough rise briefly. Roll out the dough slightly, cut into squares and fill (e.g. with plum jam). Join the filled squares and place them on a greased baking sheet. Brush each bun with melted fat. Bake and sprinkle with sugar.',
      category: null,
      favourite: false,
    ),
    Recipe(
      title: 'Spring Rolls',
      imageUrl: 'assets/images/rolls.jpg',
      ingredients: [
        '1 large avocado',
        '2 cups fresh vegetables',
        '8 rice paper wrappers',
        'Salt',
        'Pepper',
        'Chopped peanuts',
        'Thai Mango Dipping Sauce'
      ],
      procedure: 'Create an assembly line of vegetables such as carrots, bell peppers, butter lettuce and fresh microgreens. Fill a shallow dish with warm water. Add each rice paper sheet, one at a time, for 5 to 10 seconds. Remove and place on a flat surface. Towards one end of the rice wrapper, begin layering with 1-2 slices of avocado, and small handfuls of fresh cilantro + mint, and a handful of veggies. Sprinkle the veggies with salt + pepper. Fold both ends to the center and roll the sheet as tightly as you can without ripping. Serve the spring rolls with the mango dipping sauce and chopped peanuts.',
      category: null,
      favourite: false,
    ),
    Recipe(
      title: 'Indian Dhal',
      imageUrl: 'assets/images/dhal.jpg',
      ingredients: [
        '2 tbsp Ghee',
        '1 cup Yellow lentils',
        '1 Medium onion',
        '8 Fresh curry leaves',
        '½ tsp Turmeric powder',
        '¼ tsp Garam masala',
        '¾ tsp Salt',
        '2 Green cayenne chillies',
        '6 Garlic cloves',
        '1 Tomato',
        '1/2 tsp Ground cumin',
        'Basmati rice'
      ],
      procedure: 'Heat ghee in a pan. Add green chillies and fry for a minute, add chopped onions and fry until softened. Add garlic, ginger and curry leaves, sauté until golden brown. Add tomatoes and ground cumin. Add lentils, water, stir in turmeric and salt. Cover and simmer gently for 1 hour. Remove lid and simmer for 30 minutes until consistency like porrige. Season with garam masala. Serve hot over basmati rice, garnished with a spring of coriander if desired.',
      category: null,
      favourite: false,
    ),
  ];

  for (final r in initial) {
    await box.add(r);
  }
}
