import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../components/app_colors.dart';
import '../avatar.dart';

class TopContributorsWidget extends StatefulWidget {
  const TopContributorsWidget({Key? key}) : super(key: key);

  @override
  State<TopContributorsWidget> createState() => _TopContributorsWidgetState();
}

class _TopContributorsWidgetState extends State<TopContributorsWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> vipUsersStream;
  List<QueryDocumentSnapshot>? cachedData;

  @override
  void initState() {
    super.initState();
    vipUsersStream = _firestore
        .collection('users')
        .where('rank', whereIn: ['vip', 'VIP'])
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.28; // 28% màn hình
    final avatarSize = itemWidth * 0.7;
    final nameFontSize = screenWidth < 360 ? 12.0 : 14.0;
    final rankFontSize = screenWidth < 360 ? 10.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 16),
            child: Text(
              "typical_face".tr(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: itemWidth + 60,
            child: StreamBuilder<QuerySnapshot>(
              stream: vipUsersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && cachedData == null) {
                  return _buildShimmerLoading(itemWidth, avatarSize);
                }

                if (snapshot.hasError || (!snapshot.hasData && cachedData == null)) {
                  return _buildEmptyState();
                }

                if (snapshot.hasData) {
                  cachedData = snapshot.data!.docs;
                }

                final vipUsers = cachedData!;
                if (vipUsers.isEmpty) return _buildEmptyState();

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: vipUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final userDoc = vipUsers[index];
                    final data = userDoc.data()! as Map<String, dynamic>;
                    final avatarUrl = data['avatarUrl'] as String?;
                    final name = data['name']?.toString().trim() ?? 'Ẩn danh';
                    final rank = data['rank']?.toString().toUpperCase() ?? '';

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: avatarSize,
                            height: avatarSize,
                            child: AvatarWithCrown(avatarUrl: avatarUrl),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rank,
                              style: GoogleFonts.poppins(
                                fontSize: rankFontSize,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(double itemWidth, double avatarSize) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(width: 20),
      itemBuilder: (context, index) {
        return SizedBox(
          width: itemWidth,
          child: Column(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 12),
              Container(width: itemWidth * 0.8, height: 16, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Container(
                width: itemWidth * 0.6,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
