import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
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
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: ((category.imageThumbUrl ?? category.imageUrl)?.isNotEmpty ?? false)
                  ? CachedNetworkImage(
                      imageUrl: category.imageThumbUrl?.isNotEmpty == true
                          ? category.imageThumbUrl!
                          : (category.imageUrl ?? ''),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.category,
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          size: 24,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.category,
                          color: isSelected ? AppColors.primary : Colors.grey.shade400,
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.category,
                        color: isSelected ? AppColors.primary : Colors.grey.shade400,
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
              color: isSelected ? AppColors.primary : Colors.black,
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
