//XÁC MINH TÀI KHOẢN DOANH NGHIỆP
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../admin/sub_pages/business/legal_information/business_documents.dart';
import '../../admin/sub_pages/business/legal_information/business_info.dart';

class BusinessVerificationScreen extends StatefulWidget {
  @override
  _BusinessVerificationScreenState createState() =>
      _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState
    extends State<BusinessVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _businessLicenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _repNameController = TextEditingController();
  final _repTitleController = TextEditingController();
  final _repIdController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountHolderController = TextEditingController();
  final _logoLinkController = TextEditingController();
  final _stampLinkController = TextEditingController();

  File? cccdFrontImage, cccdBackImage, portraitImage, logoImage, stampImage;
  final List<String> bankName = [
    'Vietcombank', 'Techcombank', 'BIDV', 'VietinBank', 'Agribank', 'MB Bank', 'Sacombank',
    'ACB', 'VPBank', 'HDBank', 'SHB', 'TPBank', 'Eximbank', 'LienVietPostBank', 'OCB', 'SCB',
    'SeABank', 'Bac A Bank', 'DongA Bank', 'Nam A Bank', 'ABBANK', 'PVcomBank', 'VIB', 'Viet Capital Bank',
    'SaigonBank', 'CBBank', 'GPBank', 'VietBank', 'OceanBank', 'BaoViet Bank', 'KienlongBank', 'NCB',
    'PG Bank', 'VRB', 'HSBC', 'Standard Chartered', 'Shinhan Bank', 'CitiBank', 'ANZ', 'UOB', 'Woori Bank',
    'Public Bank', 'Hong Leong Bank', 'DBS Bank', 'BNP Paribas', 'Deutsche Bank', 'Bank of China'
  ];
  Future<String> uploadImage(File image, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
  String? selectedBank;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _emailController.text = args['email'] ?? '';
      _companyNameController.text = args['organizationName'] ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _createAnonymousUser();
    setupFirebaseMessaging();
  }

  Future<void> setupFirebaseMessaging() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    }

    String? token = await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    });
  }

  Future<void> _createAnonymousUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'createdAt': Timestamp.now(),
          'isAnonymous': true,
          'email': _emailController.text.isNotEmpty
              ? _emailController.text
              : null,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("session_init_failed".tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> submitVerification() async {
    try {
      // 1. Lấy user hiện tại (không dùng anonymous nữa)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("not_logged_in".tr());
      }
      final userId = currentUser.uid;

      // 2. Lấy email từ Firestore users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception("user_not_found".tr());
      }

      final userData = userDoc.data()!;
      final userEmail = userData['email'] ?? '';

      // 3. Tạo đường dẫn file unique cho từng user
      String generateFilePath(String type) => 'verifications/$userId/${DateTime.now().millisecondsSinceEpoch}_$type.jpg';
      // 4. Xử lý upload ảnh với try-catch riêng
      Future<String?> uploadWithRetry(File? file, String type) async {
        if (file == null) return null;
        try {
          return await uploadImage(file, generateFilePath(type));
        } catch (e) {
          throw Exception('upload_failed'.tr(namedArgs: {'type': 'ảnh'}));
        }
      }

      // 5. Upload song song các ảnh bắt buộc
      final results = await Future.wait([
        uploadWithRetry(cccdFrontImage, 'cccd_front'),
        uploadWithRetry(cccdBackImage, 'cccd_back'),
        uploadWithRetry(portraitImage, 'portrait'),
      ]);

      // 6. Xử lý ảnh optional
      final logoUrl = await uploadWithRetry(logoImage, 'logo') ?? _logoLinkController.text;
      final stampUrl = await uploadWithRetry(stampImage, 'stamp') ?? _stampLinkController.text;

      // 7. Chuẩn bị dữ liệu cho Firestore
      final verificationData = {
        'companyName': _companyNameController.text.trim(),
        'email': _emailController.text.trim(), // Thêm dòng này
        'taxCode': _taxIdController.text.trim(),
        'license': _businessLicenseController.text.trim(),
        'address': _addressController.text.trim(),
        'representativeName': _repNameController.text.trim(),
        'position': _repTitleController.text.trim(),
        'idNumber': _repIdController.text.trim(),
        'bankName': selectedBank ?? '',
        'branch': _bankBranchController.text.trim(),
        'accountNumber': _bankAccountNumberController.text.trim(),
        'accountHolder': _bankAccountHolderController.text.trim(),
        'logoUrl': logoUrl,
        'stampUrl': stampUrl,
        'idCardFrontUrl': results[0] ?? '',
        'idCardBackUrl': results[1] ?? '',
        'portraitUrl': results[2] ?? '',
        'submittedAt': Timestamp.now(),
        'userId': userId,
        'userEmail': userEmail,
        'status': 'pending',
      };

      // 8. Lưu dữ liệu xác minh
      final verificationRef = await FirebaseFirestore.instance
          .collection('businessVerifications')
          .add(verificationData);

      // 9. Tạo thông báo gửi cho Admin
      const adminId = '9Hkkbif9GSRYW7oZhKFG5HSpLf33';
      if (adminId.isEmpty) throw Exception("Admin ID chưa được cấu hình");

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'business_verification',
        'message': '${"New_verification".tr()} ${_companyNameController.text}',
        'isRead': false,
        'targetUserId': adminId,
        'createdAt': Timestamp.now(),
        'relatedId': verificationRef.id,
        'metadata': {
          'company': _companyNameController.text,
          'userId': userId,
          'userEmail': userEmail,
          'timestamp': DateTime.now().toIso8601String(),
        }
      });

      // 10. Hiển thị thông báo thành công và điều hướng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("verification_request_sent_successfully".tr()),
          backgroundColor: Colors.green,
        ),
      ).closed.whenComplete(() {
        Navigator.pushReplacementNamed(context, '/first');
      });

    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🔥 ${"firebase_error".tr()}: ${e.code}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ ${"system_error".tr()}: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Định nghĩa lại _buildTextField trong _BusinessVerificationScreenState
  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textPrimary),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.deepOrange, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightOrange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true, // Bật chế độ đổ màu nền
        fillColor: Colors.white, // Đặt màu nền là trắng
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _companyNameController.dispose();
    _taxIdController.dispose();
    _businessLicenseController.dispose();
    _addressController.dispose();
    _repNameController.dispose();
    _repTitleController.dispose();
    _repIdController.dispose();
    _bankBranchController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountHolderController.dispose();
    _logoLinkController.dispose();
    _stampLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite, // Hoặc một màu nền khác cho toàn bộ màn hình
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26.0, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "verification_request".tr(),
          style: GoogleFonts.poppins(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.sunrise,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BusinessInfoSection(
                companyNameController: _companyNameController,
                taxIdController: _taxIdController,
                businessLicenseController: _businessLicenseController,
                addressController: _addressController,
                emailController: _emailController,
              ),

              Card(
                color: Colors.yellow.shade50, // Màu nền của Card vẫn là vàng nhạt
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("section_legal_representative".tr(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_repNameController, "full_name".tr()),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_repTitleController, "position".tr()),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_repIdController, "id_number".tr()),
                    ],
                  ),
                ),
              ),

              BusinessDocumentsSection(
                cccdFrontImage: cccdFrontImage,
                cccdBackImage: cccdBackImage,
                portraitImage: portraitImage,
                logoImage: logoImage,
                stampImage: stampImage,
                onCccdFrontPicked: (file) => setState(() => cccdFrontImage = file),
                onCccdBackPicked: (file) => setState(() => cccdBackImage = file),
                onPortraitPicked: (file) => setState(() => portraitImage = file),
                onLogoPicked: (file) => setState(() => logoImage = file),
                onStampPicked: (file) => setState(() => stampImage = file),
              ),

              Card(
                color: Colors.yellow.shade50, // Màu nền của Card vẫn là vàng nhạt
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("section_bank_info".tr(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),
                      // DropdownButtonFormField không phải là TextField, nên không dùng _buildTextField trực tiếp.
                      // Tuy nhiên, bạn có thể truyền InputDecoration từ _buildTextField vào nó.
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "bank_name".tr(),
                          labelStyle: TextStyle(color: AppColors.textPrimary),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.deepOrange, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.lightOrange, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: selectedBank,
                        items: bankName
                            .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedBank = value!),
                      ),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_bankBranchController, "bank_branch".tr()),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_bankAccountNumberController, "account_number".tr()),
                      const SizedBox(height: 18),
                      // Áp dụng _buildTextField
                      _buildTextField(_bankAccountHolderController, "account_holder_uppercase".tr()),
                    ],
                  ),
                ),
              ),

              Center(
                child: ElevatedButton(
                  onPressed: submitVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child:  Text("submit_verification".tr()),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}