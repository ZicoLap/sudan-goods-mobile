import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/widgets/category_chip.dart';
import 'package:sudan_goods/models/store/category_model.dart';

class CategoriesSection extends StatelessWidget {
  final List<Category> categories;

  const CategoriesSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink(); // Or loading spinner
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        /*   child: Text(
            'Categories',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ), */
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 28),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryChip(
                category: category,
                onTap: () {
                  // TODO: Handle navigation or filtering
                  print("Tapped on category: ${category.name}");
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
