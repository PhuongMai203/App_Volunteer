import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:help_connect/components/app_colors.dart';
import '../../../../components/app_gradients.dart';
import '../subPages/account_settings_menu.dart';
import '../subPages/profile_sub/google_calender.dart';
import '../subPages/profile_sub/profile_header.dart';
import '../subPages/profile_sub/user_rank_badge.dart';
import '../widgets/bookmarked.dart';
import '../widgets/campaign/user_event_tab_section.dart';
import '../widgets/certificate_widget.dart';
import '../widgets/user_stats_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  String _userRole = '';
  String _userRank = 'Đồng';
  String _userRankIcon = 'star';
  int userScore = 0;
  Map<String, dynamic> rankData = {};
  List<FeaturedActivity> registeredEvents = [];

  final List<Map<String, dynamic>> ranks = [
    {'label': 'Đồng', 'emoji': '🥉', 'minScore': 0, 'maxScore': 20, 'color': Colors.brown},
    {'label': 'Bạc', 'emoji': '🥈', 'minScore': 21, 'maxScore': 25, 'color': Colors.grey},
    {'label': 'Vàng', 'emoji': '🥇', 'minScore': 26, 'maxScore': 100, 'color': Colors.amber},
    {'label': 'Kim cương', 'emoji': '💎', 'minScore': 101, 'maxScore': 250, 'color': Color(0xFF7388C1)},
    {'label': 'VIP', 'emoji': '👑', 'minScore': 251, 'maxScore': 999999, 'color': Color(0xFFE33539)},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserScore();
    Future.microtask(() {
      context.read<BookmarkProvider>().loadBookmarkedEvents();
    });
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        _userRole = userData?['role'] ?? 'user';
        _userRank = userData?['rank'] ?? 'Đồng';
        _userRankIcon = _getRankIcon(_userRank);
      });
    } else {
      setState(() {
        userData = null;
        _userRole = 'user';
        _userRank = 'Đồng';
        _userRankIcon = _getRankIcon(_userRank);
      });
    }
  }

  Future<void> _loadUserScore() async {
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: user!.uid)
        .get();

    int totalScore = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final types = data['participationTypes'] ?? [];
      final attendanceStatus = data['attendanceStatus'];
      int donationAmount = int.tryParse(data['donationAmount']?.toString() ?? '0') ?? 0;

      for (var type in types) {
        if (type == "Tham gia tình nguyện trực tiếp" && attendanceStatus == "Có mặt") {
          totalScore += 10;
        } else if (type == "Đóng góp tiền") {
          totalScore += 8;
        } else if (type == "Đóng góp vật phẩm") {
          totalScore += 5;
        }
      }
    }

    final determinedRank = ranks.lastWhere(
          (r) => totalScore >= r['minScore'] && totalScore <= r['maxScore'],
      orElse: () => ranks.first,
    );

    setState(() {
      userScore = totalScore;
      rankData = determinedRank;
    });
  }

  String _getRankIcon(String rank) {
    if (rank == 'Gold') return 'star';
    return 'trophy';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "profile_title".tr(),
            style: GoogleFonts.agbalumo(
              fontSize: 35,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          backgroundColor: AppColors.sunrise,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppColors.pureWhite, size: 36),
              onPressed: () => showSettingsMenu(context),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.peachPinkToOrange),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(user: user, userData: userData),
                  UserRankBadge(rank: _userRank, iconName: _userRankIcon),
                  _buildSectionTitle("highlight_activities".tr()),
                  UserStatsWidget(userUid: user?.uid),
                  _buildSectionTitle("interested_events".tr()),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => handleCreateEventsToGoogleCalendar(context, registeredEvents),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pureWhite,
                      foregroundColor: Color(0xFF1A73E8),
                      elevation: 4,
                      shadowColor: Color(0xFFBBDEFB),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFDADCE0), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/google_calendar_icon.png', width: 24, height: 24),
                        const SizedBox(width: 12),
                        Text(
                          "sync_with_google_calendar".tr(),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  UserEventTabSection(user: user),
                  const SizedBox(height: 10),
                  if (rankData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20), // Có thể chỉnh sửa giá trị theo ý bạn
                      child: CertificateWidget(
                        rankData: rankData,
                        userScore: userScore,
                        userName: userData?['name'] ?? "Tình nguyện viên",
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepOcean),
        ),
      ),
    );
  }
}
