import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../service/category_model.dart';

class CategorySection extends StatefulWidget {
  final Function(String) onCategorySelected;
  final bool showBackgroundImage;

  const CategorySection({
    Key? key,
    required this.onCategorySelected,
    this.showBackgroundImage = false,
  }) : super(key: key);

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  List<Category> categories = [];
  final PageController _pageController = PageController();
  final int itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final doc = await FirebaseFirestore.instance.collection('system_settings').doc('main').get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['categories'] is List) {
        categories = (data['categories'] as List)
            .map((item) => Category.fromMap(Map<String, dynamic>.from(item)))
            .toList();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (categories.length / itemsPerPage).ceil();
    int crossAxisCount = 4;

    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: widget.showBackgroundImage ? 390 : 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.showBackgroundImage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/bn1.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          Positioned(
            top: widget.showBackgroundImage ? 160 : 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 190,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: totalPages,
                      itemBuilder: (context, index) {
                        int start = index * itemsPerPage;
                        int end = (index + 1) * itemsPerPage;
                        var pageItems = categories.sublist(
                          start,
                          end > categories.length ? categories.length : end,
                        );

                        return Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: pageItems.map((item) {
                              return InkWell(
                                onTap: () {
                                  widget.onCategorySelected(item.name);
                                },
                                child: SizedBox(
                                  width: (MediaQuery.of(context).size.width - 40 - 20) / crossAxisCount - 10,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.orange[100],
                                        child: Icon(
                                          item.iconCode != null
                                              ? IconData(item.iconCode!, fontFamily: 'MaterialIcons')
                                              : Icons.category,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: totalPages,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Colors.orange,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
