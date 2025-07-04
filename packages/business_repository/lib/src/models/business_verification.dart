import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessVerification {
  final String email;
  final String companyName;
  final String taxCode;
  final String license;
  final String address;
  final String representativeName;
  final String position;
  final String idNumber;
  final String bankName;
  final String branch;
  final String accountNumber;
  final String accountHolder;
  final String? logoUrl;
  final String? stampUrl;
  final String? idCardFrontUrl;
  final String? idCardBackUrl;
  final String userId;
  final Timestamp submittedAt;

  BusinessVerification({
    required this.email,
    required this.companyName,
    required this.taxCode,
    required this.license,
    required this.address,
    required this.representativeName,
    required this.position,
    required this.idNumber,
    required this.bankName,
    required this.branch,
    required this.accountNumber,
    required this.accountHolder,
    required this.userId,
    required this.submittedAt,
    this.logoUrl,
    this.stampUrl,
    this.idCardFrontUrl,
    this.idCardBackUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'companyName': companyName,
      'taxCode': taxCode,
      'license': license,
      'address': address,
      'representativeName': representativeName,
      'position': position,
      'idNumber': idNumber,
      'bankName': bankName,
      'branch': branch,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      'logoUrl': logoUrl,
      'stampUrl': stampUrl,
      'idCardFrontUrl': idCardFrontUrl,
      'idCardBackUrl': idCardBackUrl,
      'userId': userId,
      'submittedAt': submittedAt,
    };
  }

  factory BusinessVerification.fromMap(Map<String, dynamic> data) {
    return BusinessVerification(
      email: data['email'] ?? '',
      companyName: data['companyName'] ?? '',
      taxCode: data['taxCode'] ?? '',
      license: data['license'] ?? '',
      address: data['address'] ?? '',
      representativeName: data['representativeName'] ?? '',
      position: data['position'] ?? '',
      idNumber: data['idNumber'] ?? '',
      bankName: data['bankName'] ?? '',
      branch: data['branch'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolder: data['accountHolder'] ?? '',
      logoUrl: data['logoUrl'],
      stampUrl: data['stampUrl'],
      idCardFrontUrl: data['idCardFrontUrl'],
      idCardBackUrl: data['idCardBackUrl'],
      userId: data['userId'] ?? '',
      submittedAt: data['submittedAt'] ?? Timestamp.now(),
    );
  }
}
