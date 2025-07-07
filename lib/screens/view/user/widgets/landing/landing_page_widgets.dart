import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../components/app_colors.dart';
import '../../../../../components/search_bar.dart';

import '../bookmarked.dart';
import '../notifications/notification_icon.dart';

Widget buildHeader(
    BuildContext context, {
      required Function(String) onSearchChanged,
    }) {
  final bookmarkedEvents = context.watch<BookmarkProvider>().bookmarkedEvents;

  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dòng chào
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome".tr(),
                  style: GoogleFonts.agbalumo(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "volunteers_return".tr(),
                  style: GoogleFonts.agbalumo(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            NotificationIcon(),
          ],
        ),
        const SizedBox(height: 24),
        SearchBarWidget(
          onSearchChanged: onSearchChanged,
        ),
      ],
    ),
  );
}


// Sửa: thêm callback onCategorySelected vào đây
Widget buildCategorySection(
    List<Map<String, dynamic>> categories,
    int crossAxisCount,
    int itemsPerPage,
    int totalPages,
    PageController pageController,
    Function(String) onCategorySelected, {
      bool showBackgroundImage = false,
    }) {

  return SizedBox(
    // Điều chỉnh chiều cao tổng thể của section
    height: showBackgroundImage ? 390 : 240, // Đã giảm từ 420/320
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        if (showBackgroundImage)
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
          top: showBackgroundImage ? 160 : 10,
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
                  height: 190, // Đã giảm từ 220 xuống 190 để khung gọn hơn
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: totalPages,
                    itemBuilder: (context, index) {
                      int start = index * itemsPerPage;
                      int end = (index + 1) * itemsPerPage;
                      var pageItems = categories.sublist(
                        start,
                        end > categories.length ? categories.length : end,
                      );

                      return Center( // Bọc Wrap bằng Center để đảm bảo các hàng được căn giữa
                        child: Wrap( // Sử dụng Wrap thay vì GridView.builder
                          alignment: WrapAlignment.center, // Căn giữa các item
                          spacing: 10, // Khoảng cách ngang giữa các item
                          runSpacing: 10, // Khoảng cách dọc giữa các hàng
                          children: pageItems.map((item) {
                            return InkWell(
                              onTap: () {
                                onCategorySelected(item['title']);
                              },
                              child: SizedBox( // Bọc mỗi item trong SizedBox để kiểm soát kích thước
                                width: (MediaQuery.of(context).size.width - 40 - 20) / crossAxisCount - 10, // Tính toán width để mô phỏng cột grid
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Giảm kích thước theo nội dung
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.orange[100],
                                      child: Icon(item['icon'] ?? Icons.category, color: Colors.deepOrange),
                                    ),
                                    const SizedBox(height: 4), // Khoảng cách nhỏ giữa icon và text
                                    Text(
                                      item['title'],
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
                  controller: pageController,
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