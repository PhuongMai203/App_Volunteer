import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';
import '../business/chat/chat_bn.dart';
import 'main_pages/SystemSettingsPage.dart';
import 'main_pages/admin_account.dart';
import 'main_pages/campaign.dart';
import 'main_pages/users_and_businesses_page.dart';
import 'sub_pages/tab/home/business_page.dart';
import 'sub_pages/tab/campaign/campaign_completed_page.dart';
import 'sub_pages/tab/campaign/campaign_ongoing_page.dart';
import 'main_pages/create_helpconnect.dart';
import 'sub_pages/tab/home/users_page.dart';

import 'widgets/bottom_navigation_bar.dart';
import 'widgets/notification_icon_admin.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  String _selectedFilter = '';
  List<String> registeredEvents = [];

  Widget _buildPage() {
    switch (_currentIndex) {
      case 0:
        return UsersAndBusinessesPage(
        );
      case 1:
        return Campaign(
          searchQuery: _searchQuery,
          selectedFilter: _selectedFilter,
          registeredEvents: registeredEvents,
        );
      case 2:
        return CreateHelpConnectPage(
          userEmail: 'admin1@gmail.com',
          userName: 'Admin HelpConnect',
          onSubmit: (Map<String, dynamic> requestData) {
          },
          onCampaignCreated: () {
          },
        );
      case 3:
        return ChatBn();
      case 4:
        return AdminAccountPage( );
      case 5:
        return SystemSettingsScreen( );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_currentIndex == 2 || _currentIndex == 3)
          ? null // Ẩn AppBar khi ở trang ChatBn
          : AppBar(

      backgroundColor: AppColors.sunrise,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // 1) Search field
            Expanded(
              child: Container(
                height: kToolbarHeight,
                alignment: Alignment.center,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: "search_placeholder".tr(),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),

            // 2) Filter button
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_alt,
                  color: Colors.white, size: 30),
              onSelected: (v) => setState(() => _selectedFilter = v),
              itemBuilder: (_) => [
                PopupMenuItem(value: '', child: Text("filter_default".tr())),
                PopupMenuItem(value: 'A-Z', child: Text("A-Z")),
                PopupMenuItem(value: "filter_expiring".tr(), child: Text("filter_expiring".tr())),
              ],
            ),

            // 3) Notification icon + badge + popup
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white, size: 30),
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "notifications".tr(),
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (context, animation1, animation2) {
                    return const SizedBox.shrink(); // Không dùng ở đây
                  },
                  transitionBuilder: (context, animation, secondaryAnimation, child) {
                    final curvedValue = Curves.easeInOut.transform(animation.value);
                    final size = MediaQuery.of(context).size;

                    return Transform.translate(
                      offset: Offset(size.width * (1 - curvedValue), 0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: size.height * 0.8,
                          width: size.width * (4 / 5),
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const NotificationsScreen(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: _buildPage(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
