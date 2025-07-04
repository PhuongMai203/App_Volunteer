import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../components/app_colors.dart';

class StatisticsWidget extends StatefulWidget {
  final int volunteerCount;
  final int businessCount;
  final int campaignCount;
  final int cityCount;

  const StatisticsWidget({
    Key? key,
    required this.volunteerCount,
    required this.businessCount,
    required this.campaignCount,
    required this.cityCount,
  }) : super(key: key);

  @override
  State<StatisticsWidget> createState() => _StatisticsWidgetState();
}

class _StatisticsWidgetState extends State<StatisticsWidget> {
  late Future<int> _cityCountFuture;

  final List<String> cities = [
    'Hà Nội', 'Hải Phòng', 'Đà Nẵng', 'TP. Hồ Chí Minh', 'Cần Thơ',
    'Hà Giang', 'Cao Bằng', 'Bắc Kạn', 'Lạng Sơn', 'Tuyên Quang',
    'Lào Cai', 'Yên Bái', 'Thái Nguyên', 'Phú Thọ', 'Bắc Giang',
    'Quảng Ninh', 'Vĩnh Phúc', 'Bắc Ninh', 'Điện Biên', 'Lai Châu',
    'Sơn La', 'Hòa Bình', 'Hải Dương', 'Hưng Yên', 'Thái Bình',
    'Nam Định', 'Ninh Bình', 'Hà Nam', 'Thanh Hóa', 'Nghệ An',
    'Hà Tĩnh', 'Quảng Bình', 'Quảng Trị', 'Thừa Thiên Huế', 'Quảng Nam',
    'Quảng Ngãi', 'Bình Định', 'Phú Yên', 'Khánh Hòa', 'Ninh Thuận',
    'Bình Thuận', 'Kon Tum', 'Gia Lai', 'Đắk Lắk', 'Đăk Nông', 'Lâm Đồng',
    'Bình Phước', 'Bình Dương', 'Đồng Nai', 'Tây Ninh', 'Bà Rịa - Vũng Tàu',
    'Long An', 'Tiền Giang', 'Bến Tre', 'Trà Vinh', 'Vĩnh Long', 'Đồng Tháp',
    'An Giang', 'Kiên Giang', 'Hậu Giang', 'Sóc Trăng', 'Bạc Liêu', 'Cà Mau'
  ];

  @override
  void initState() {
    super.initState();
    _cityCountFuture = getCityCount();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final cardWidth = isTablet ? screenWidth * 0.4 : screenWidth * 0.42;
    final cardHeight = isTablet ? 130.0 : 110.0;
    final countFontSize = isTablet ? 32.0 : 28.0;
    final labelFontSize = isTablet ? 18.0 : 16.0;

    return FutureBuilder<int>(
      future: _cityCountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("error_occurred".tr());
        } else {
          return Column(
            children: [
              Text(
                "statistics_title".tr(),
                style: TextStyle(
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepOcean,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStyledStatCard('${widget.volunteerCount}', "volunteer".tr(), Colors.blue, cardWidth, cardHeight, countFontSize, labelFontSize),
                    _buildStyledStatCard('${widget.businessCount}', "organization".tr(), Colors.orange, cardWidth, cardHeight, countFontSize, labelFontSize),
                    _buildStyledStatCard('${widget.campaignCount}', "campaign".tr(), Colors.purple, cardWidth, cardHeight, countFontSize, labelFontSize),
                    _buildStyledStatCard('${snapshot.data}', "city".tr(), Colors.green, cardWidth, cardHeight, countFontSize, labelFontSize),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStyledStatCard(
      String count,
      String label,
      Color color,
      double width,
      double height,
      double countFontSize,
      double labelFontSize,
      ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: countFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<int> getCityCount() async {
    var snapshot = await FirebaseFirestore.instance.collection('featured_activities').get();
    var addresses = snapshot.docs
        .where((doc) => doc.data().containsKey('address'))
        .map((doc) => doc['address'].toString().toLowerCase())
        .toSet();

    int cityCount = 0;
    for (var address in addresses) {
      for (var city in cities) {
        if (address.contains(city.toLowerCase())) {
          cityCount++;
          break;
        }
      }
    }
    return cityCount;
  }
}
