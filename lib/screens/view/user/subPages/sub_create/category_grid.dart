import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryGrid({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth >= 800) {
      // Tablet lớn, màn hình to
      crossAxisCount = 5;
      childAspectRatio = 1.6;
    } else if (screenWidth >= 600) {
      // Tablet nhỏ
      crossAxisCount = 4;
      childAspectRatio = 1.4;
    } else {
      // Điện thoại
      crossAxisCount = 3;
      childAspectRatio = 0.7;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            "categorys".tr(),
            style: TextStyle(fontSize: 16, color: AppColors.deepOcean),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['title'];
            return GestureDetector(
              onTap: () => onCategorySelected(category['title']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.peach : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.sunrise : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: screenWidth > 400 ? 20 : 18,
                      color: isSelected ? Colors.orange : Colors.grey[700],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth > 400 ? 14 : 13,
                        color: isSelected ? Colors.orange : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "select_a_category".tr(),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
