import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "home_title".tr(),
          style: TextStyle(fontSize: isTablet ? 22 : 18),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            HomeWidgets().buildPartnersSection(context),
          ],
        ),
      ),
    );
  }
}

class HomeWidgets {
  final List<Map<String, String>> partners = [
    {'name': "partner_red_cross".tr(), 'logo': 'assets/partner1.png'},
    {'name': "partner_vietnam_charity".tr(), 'logo': 'assets/partner2.png'},
    {'name': "partner_ward_office".tr(), 'logo': 'assets/partner3.png'},
  ];

  Widget buildPartnersSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final imageSize = isTablet ? 120.0 : 100.0;
    final fontSize = isTablet ? 16.0 : 14.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 40 : 30,
        horizontal: isTablet ? 28 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "home_partners_section_title".tr(),
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = isTablet ? 24.0 : 16.0;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: partners.map((p) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 20.0 : 15.0),
                          child: Image.asset(
                            p['logo']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p['name']!,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 18 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.handshake),
                  label: Text(
                    "home_join_now".tr(),
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/newsfeed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 18 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.campaign),
                  label: Text(
                    "home_create_campaign".tr(),
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/create-request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsFeedPage extends StatelessWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NewsFeed')),
    );
  }
}

class CreateCampaignPage extends StatelessWidget {
  const CreateCampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("home_create_campaign".tr())),
    );
  }
}
