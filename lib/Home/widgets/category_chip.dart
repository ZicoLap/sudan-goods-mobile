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
    final hasImage =
        (category.imageThumbUrl ?? category.imageUrl)?.isNotEmpty ?? false;
    final imageUrl =
        category.imageThumbUrl?.isNotEmpty == true
            ? category.imageThumbUrl!
            : (category.imageUrl ?? '');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color:
                    isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : Colors.white,
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : DesignTokens.shadowSmall,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or icon fallback
                    hasImage
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.category_rounded,
                                  color: Colors.grey.shade300,
                                  size: 26,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.08)
                                        : Colors.grey.shade100,
                                child: Icon(
                                  Icons.category_rounded,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade400,
                                  size: 26,
                                ),
                              ),
                        )
                        : Container(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.08)
                                  : Colors.grey.shade100,
                          child: Icon(
                            Icons.category_rounded,
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade400,
                            size: 26,
                          ),
                        ),
                    // Selected gradient overlay
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            // Name
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Selection dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 16 : 0,
              height: isSelected ? 3 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
