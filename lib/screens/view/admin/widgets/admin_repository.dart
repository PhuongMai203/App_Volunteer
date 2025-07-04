import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getVolunteerCount() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getOrganizationCount() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'organization')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getCampaignCount() {
    return _firestore
        .collection('featured_activities')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Phương thức để lấy thống kê theo tháng cho một năm cụ thể
  Future<List<Map<String, dynamic>>> getYearlyMonthlyStats(int selectedYear) async {
    final firstDayOfYearLocal = DateTime(selectedYear, 1, 1);
    final lastDayOfYearLocal = DateTime(selectedYear, 12, 31, 23, 59, 59);

    final firstDayOfYearUtc = firstDayOfYearLocal.subtract(const Duration(hours: 7));
    final lastDayOfYearUtc = lastDayOfYearLocal.subtract(const Duration(hours: 7));

    try {
      // Lấy tất cả các chiến dịch trong năm đã chọn
      final campaignsSnapshot = await _firestore
          .collection('featured_activities')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfYearUtc))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfYearUtc))
          .get();

      // Lấy tất cả các khoản thanh toán trong năm đã chọn
      final paymentsSnapshot = await _firestore
          .collection('payments')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfYearUtc))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfYearUtc))
          .get();

      // Khởi tạo thống kê hàng tháng cho 12 tháng với giá trị 0
      Map<int, Map<String, double>> monthlyStats = {};
      for (int m = 1; m <= 12; m++) {
        monthlyStats[m] = {
          'created': 0.0,
          'completed': 0.0,
          'users': 0.0, // Đổi từ 'volunteers' thành 'users' để khớp với AdminChart
          'donation': 0.0,
        };
      }

      // Xử lý dữ liệu chiến dịch
      for (var doc in campaignsSnapshot.docs) {
        final data = doc.data();
        final createdRaw = data['createdAt'];
        final endRaw = data['endDate'];

        if (createdRaw == null) continue;

        final createdDate = (createdRaw as Timestamp).toDate();
        final createdMonth = createdDate.month;

        // Đếm chiến dịch được tạo
        monthlyStats[createdMonth]!['created'] = monthlyStats[createdMonth]!['created']! + 1;

        // Đếm tình nguyện viên (participantCount) cho tháng tạo chiến dịch
        final participants = (data['participantCount'] ?? 0).toDouble();
        monthlyStats[createdMonth]!['users'] = monthlyStats[createdMonth]!['users']! + participants;

        // Đếm chiến dịch đã hoàn thành nếu endDate nằm trong năm đã chọn và đã qua
        if (endRaw != null) {
          final endDate = (endRaw as Timestamp).toDate();
          if (endDate.year == selectedYear && endDate.isBefore(DateTime.now())) {
            final completedMonth = endDate.month;
            monthlyStats[completedMonth]!['completed'] = monthlyStats[completedMonth]!['completed']! + 1;
          }
        }
      }

      // Xử lý dữ liệu thanh toán
      final Map<String, double> campaignDonations = {}; // Để tổng hợp quyên góp theo campaignId
      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        final campaignId = data['campaignId'] as String?;
        final amount = (data['amount'] ?? 0).toDouble();
        final paymentCreatedRaw = data['createdAt'];

        if (campaignId != null && paymentCreatedRaw != null) {
          final paymentCreatedDate = (paymentCreatedRaw as Timestamp).toDate();
          if (paymentCreatedDate.year == selectedYear) {
            campaignDonations[campaignId] = (campaignDonations[campaignId] ?? 0) + amount;
          }
        }
      }

      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data();
        final paymentCreatedRaw = data['createdAt'];
        final amount = (data['amount'] ?? 0).toDouble();
        if (paymentCreatedRaw != null) {
          final paymentDate = (paymentCreatedRaw as Timestamp).toDate();
          if (paymentDate.year == selectedYear) {
            monthlyStats[paymentDate.month]!['donation'] = monthlyStats[paymentDate.month]!['donation']! + amount;
          }
        }
      }

      // Chuyển đổi map thống kê hàng tháng thành List<Map<String, dynamic>>
      List<Map<String, dynamic>> result = [];
      for (int m = 1; m <= 12; m++) {
        result.add({
          'month': m,
          'created': monthlyStats[m]!['created'],
          'completed': monthlyStats[m]!['completed'],
          'users': monthlyStats[m]!['users'], // 'users' trong biểu đồ sẽ là 'volunteers' từ repo
          'donation': monthlyStats[m]!['donation'],
        });
      }

      return result;

    } catch (e, s) {

      return [];
    }
  }
}
