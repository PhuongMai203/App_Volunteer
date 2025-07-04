import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeaturedActivity {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final double totalDonationAmount;
  final int participantCount;
  final int maxVolunteerCount;
  final int directVolunteerCount;
  final String category;
  final String userId; // <--- THAY THẾ ownerId bằng userId

  // Các thuộc tính khác cho trang chi tiết
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final String avatarUrl;
  final String supportType;
  final String urgency;
  final List<String> imageUrls;
  final List<String> verificationDocs;
  final String receivingMethod;
  final String? bankAccount;
  final String? bankName;
  final Timestamp createdAt;
  final String status;

  FeaturedActivity({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.totalDonationAmount,
    required this.participantCount,
    required this.maxVolunteerCount,
    required this.directVolunteerCount,
    required this.category,
    required this.userId, // <--- THAY THẾ ownerId bằng userId trong constructor
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.avatarUrl,
    required this.supportType,
    required this.urgency,
    required this.imageUrls,
    required this.verificationDocs,
    required this.receivingMethod,
    this.bankAccount,
    this.bankName,
    required this.createdAt,
    required this.status,
  });

  factory FeaturedActivity.fromMap(Map<String, dynamic> data, String documentId) {
    return FeaturedActivity(
      id: documentId,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      description: data['description'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalDonationAmount: _parseDouble(data['totalDonationAmount']),
      participantCount: _parseInt(data['participantCount']),
      maxVolunteerCount: _parseInt(data['maxVolunteerCount']),
      directVolunteerCount: _parseInt(data['directVolunteerCount']),
      category: data['category'] as String? ?? '',
      userId: data['userId'] as String? ?? '', // <--- Đọc userId từ dữ liệu Firestore
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      supportType: data['supportType'] as String? ?? '',
      urgency: data['urgency'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      verificationDocs: List<String>.from(data['verificationDocs'] ?? []),
      receivingMethod: data['receivingMethod'] as String? ?? '',
      bankAccount: data['bankAccount'] as String?,
      bankName: data['bankName'] as String?,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'isActive': isActive,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalDonationAmount': totalDonationAmount,
      'participantCount': participantCount,
      'maxVolunteerCount': maxVolunteerCount,
      'directVolunteerCount': directVolunteerCount,
      'category': category,
      'userId': userId, // <--- Ghi userId vào Map
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'avatarUrl': avatarUrl,
      'supportType': supportType,
      'urgency': urgency,
      'imageUrls': imageUrls,
      'verificationDocs': verificationDocs,
      'receivingMethod': receivingMethod,
      'bankAccount': bankAccount,
      'bankName': bankName,
      'createdAt': createdAt,
      'status': status,
    };
  }


  factory FeaturedActivity.fromDocument(DocumentSnapshot doc) {
    return FeaturedActivity.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }


  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String get formattedDateRange {
    return '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}';
  }

  String get formattedDonation {
    return NumberFormat.currency(locale: 'vi', symbol: '₫').format(totalDonationAmount);
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}