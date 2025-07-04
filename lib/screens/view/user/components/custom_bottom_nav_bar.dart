import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../providers/auth_provider.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    // Chỉ load once khi widget khởi tạo
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final role = await getUserRoleFromFirestore(uid);
        if (mounted) {
          setState(() {
            _userRole = role;
          });
        }
      } catch (_) {
        if (mounted) setState(() {
          _userRole = 'user';
        });
      }
    } else {
      // Chưa đăng nhập
      _userRole = 'user';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa load xong, có thể trả về SizedBox hoặc placeholder
    if (_userRole == null) {
      return SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final userRole = _userRole!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: "home_title".tr(),
            isActive: widget.currentIndex == 0,
            onTap: () => widget.onTap(0),
          ),
          _buildNavItem(
            icon: Icons.volunteer_activism,
            label: "support".tr(),
            isActive: widget.currentIndex == 1,
            onTap: () => widget.onTap(1),
          ),
          _buildNavItem(
            icon: Icons.newspaper,
            label: "news_feed".tr(),
            isActive: widget.currentIndex == 2,
            onTap: () => widget.onTap(2),
          ),
          _buildNavItem(
            icon: Icons.forum,
            label: "message".tr(),
            isActive: widget.currentIndex == 3,
            onTap: () => widget.onTap(3),
          ),
          _buildNavItem(
            icon: Icons.person,
            label: "account".tr(),
            isActive: widget.currentIndex ==4,
            onTap: () => widget.onTap(4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Color(0xFFFF8C00) : Colors.grey,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Color(0xFFFF8C00) : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
