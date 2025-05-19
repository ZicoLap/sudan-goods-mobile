import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/category_model.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            backgroundImage: category.imageUrl != null && category.imageUrl!.isNotEmpty
                ? NetworkImage(category.imageUrl!)
                : null,
            child: category.imageUrl == null || category.imageUrl!.isEmpty
                ? const Icon(Icons.category, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
