import 'package:flutter/material.dart';
import 'package:sudan_goods/Home/widgets/category_chip.dart';
import 'package:sudan_goods/Home/widgets/shimmer_components.dart';
import 'package:sudan_goods/models/store/category_model.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class CategoriesSection extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  const CategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return ShimmerComponents.categoriesSectionShimmer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: DesignTokens.paddingPageHorizontal,
          child: Text(
            AppLocalizations.of(context)!.browseCategories,
            style: AppTypography.sectionTitle.copyWith(
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: DesignTokens.paddingPageHorizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: DesignTokens.space20),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryChip(
                category: category,
                isSelected: category.id == selectedCategoryId,
                onTap: () {
                  onCategorySelected(category.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
