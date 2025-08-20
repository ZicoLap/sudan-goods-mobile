import 'package:flutter/material.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';

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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: DesignTokens.shadowSmall,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                  ? Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.category,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.category,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: AppTypography.small.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
