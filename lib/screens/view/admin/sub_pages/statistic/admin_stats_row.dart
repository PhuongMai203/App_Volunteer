import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đếm số lượng người dùng, loại trừ những người có role là admin
  Stream<int> getVolunteerCount() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      int count = 0;
      for (var doc in snapshot.docs) {
        final role = doc.data()['role'];
        if (role != 'admin') {
          count++;
        }
      }
      return count;
    });
  }

  /// Đếm số lượng chiến dịch chưa kết thúc (endDate sau thời điểm hiện tại)
  Stream<int> getCampaignCount() {
    final now = Timestamp.now();
    return _firestore
        .collection('featured_activities')
        .where('endDate', isGreaterThan: now)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Tính tổng số giờ tình nguyện từ startDate đến endDate của tất cả chiến dịch
  Stream<int> getTotalVolunteerHours() {
    return _firestore.collection('featured_activities').snapshots().map((snapshot) {
      int totalHours = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp? startTimestamp = data['startDate'];
        final Timestamp? endTimestamp = data['endDate'];

        if (startTimestamp != null && endTimestamp != null) {
          final startDate = startTimestamp.toDate();
          final endDate = endTimestamp.toDate();
          final duration = endDate.difference(startDate).inHours;
          if (duration > 0) {
            totalHours += duration;
          }
        }
      }
      return totalHours;
    });
  }
}

class AdminStatsRow extends StatelessWidget {
  final AdminRepository repository;

  const AdminStatsRow({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    final List<Color> pastelColors = [
      Colors.lightBlue.shade300, // Tình nguyện viên
      Colors.green.shade300,    // Chiến dịch
      Colors.purple.shade300,   // Tổng giờ tình nguyện
    ];

    return IntrinsicHeight(
      child: Row(
        children: [
          _buildStatCard(context, "total_user".tr(), repository.getVolunteerCount(), pastelColors[0]),
          const SizedBox(width: 12),
          _buildStatCard(context, "campaign".tr(), repository.getCampaignCount(), pastelColors[1]),
          const SizedBox(width: 12),
          _buildStatCard(context, "total_hours".tr(), repository.getTotalVolunteerHours(), pastelColors[2]),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, Stream<int> stream, Color cardColor) {
    return Expanded(
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Card(
            color: cardColor,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(25),
              elevation: 0,
              shadowColor: Colors.black.withOpacity(0.3),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
                constraints: const BoxConstraints(
                  minHeight: 140,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      count.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.5, 1.5),
                            blurRadius: 4.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
