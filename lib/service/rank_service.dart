import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankService {
  static final List<Map<String, dynamic>> ranks = [
    {'label': 'Đồng', 'emoji': '🥉', 'minScore': 0, 'maxScore': 30},
    {'label': 'Bạc', 'emoji': '🥈', 'minScore': 31, 'maxScore': 55},
    {'label': 'Vàng', 'emoji': '🥇', 'minScore': 56, 'maxScore': 100},
    {'label': 'Kim cương', 'emoji': '💎', 'minScore': 101, 'maxScore': 250},
    {'label': 'VIP', 'emoji': '👑', 'minScore': 251, 'maxScore': 999999},
  ];

  /// Hàm tính điểm, xét rank, cập nhật Firestore và ghi lịch sử nếu rank thay đổi
  static Future<Map<String, dynamic>> calculateAndUpdateRank() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Người dùng chưa đăng nhập");

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userSnapshot = await userDocRef.get();
    final currentRank = userSnapshot.data()?['rank'] ?? '';

    final querySnapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: user.uid)
        .get();

    int totalScore = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final types = data['participationTypes'] ?? [];
      final attendanceStatus = data['attendanceStatus'];

      if (types.contains("Tham gia tình nguyện trực tiếp") && attendanceStatus == "Có mặt") {
        totalScore += 10;
      }
      if (types.contains("Đóng góp tiền")) {
        totalScore += 8;
      }
      if (types.contains("Đóng góp vật phẩm")) {
        totalScore += 5;
      }
    }

    final determinedRank = ranks.lastWhere(
          (r) => totalScore >= r['minScore'] && totalScore <= r['maxScore'],
      orElse: () => ranks.first,
    );

    /// Nếu rank mới khác rank cũ => cập nhật và lưu lịch sử
    if (determinedRank['label'] != currentRank) {
      await userDocRef.update({
        'rank': determinedRank['label'],
      });

      await FirebaseFirestore.instance.collection('user_rank_history').add({
        'userId': user.uid,
        'newRank': determinedRank['label'],
        'score': totalScore,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    return {
      'score': totalScore,
      'rank': determinedRank['label'],
      'emoji': determinedRank['emoji'],
    };
  }
}
