import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../components/app_colors.dart';

class HelpRequestFormController extends ChangeNotifier {
  final String userEmail;
  final String userName;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  late TextEditingController maxVolController;

  String? title, description, address, selectedCategory;
  XFile? mainImage;
  DateTime? startDate;
  DateTime? endDate;
  bool agreement = false;
  bool _isSubmitting = false;
  double _currentSliderValue = 1;
  int maxVolunteerCount = 0;
  // Initialize dropdown values to null or a default
  String? supportType;
  String? receivingMethod;
  String? bankAccount;
  String? bankName;
  late String urgency; // This will be set in the constructor based on slider value

  final List<String> supportTypes = ["food".tr(), "cash".tr(), "medical".tr(), "education".tr(), "supplies".tr(), "shelter".tr(), "clothing".tr(), "other".tr()];
  final List<String> urgencyLevels = ["urgencyLow".tr(), "urgencyMedium".tr(), "urgencyHigh".tr()];
  final List<String> receivingMethods = ["onsite".tr(), "bank_transfer".tr(), "relief_center".tr()];
  final List<String> bankNames = [
    'Vietcombank', 'Techcombank', 'BIDV', 'VietinBank', 'Agribank', 'MB Bank', 'Sacombank',
    'ACB', 'VPBank', 'HDBank', 'SHB', 'TPBank', 'Eximbank', 'LienVietPostBank', 'OCB', 'SCB',
    'SeABank', 'Bac A Bank', 'DongA Bank', 'Nam A Bank', 'ABBANK', 'PVcomBank', 'VIB', 'Viet Capital Bank',
    'SaigonBank', 'CBBank', 'GPBank', 'VietBank', 'OceanBank', 'BaoViet Bank', 'KienlongBank', 'NCB',
    'PG Bank', 'VRB', 'HSBC', 'Standard Chartered', 'Shinhan Bank', 'CitiBank', 'ANZ', 'UOB', 'Woori Bank',
    'Public Bank', 'Hong Leong Bank', 'DBS Bank', 'BNP Paribas', 'Deutsche Bank', 'Bank of China'
  ];
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  HelpRequestFormController({required this.userEmail, required this.userName}) {
    maxVolController = TextEditingController(text: '$maxVolunteerCount');
    maxVolController.addListener(_updateMaxVolunteerCount);
    // Initialize dropdowns to null or a sensible default from their lists
    supportType = supportTypes.isNotEmpty ? supportTypes[0] : null; // Set first item as default
    receivingMethod = receivingMethods.isNotEmpty ? receivingMethods[0] : null; // Set first item as default
    bankName = bankNames.isNotEmpty ? bankNames[0] : null; // Set first item as default, will be hidden if not bank transfer
    urgency = urgencyLevels[_currentSliderValue.toInt()];
  }

  void setSupportType(String? type) {
    supportType = type;
    notifyListeners();
  }

  void _updateMaxVolunteerCount() {
    final value = int.tryParse(maxVolController.text) ?? 0;
    if (value != maxVolunteerCount) {
      maxVolunteerCount = value;
      notifyListeners();
    }
  }

  bool get isSubmitting => _isSubmitting;

  double get currentSliderValue => _currentSliderValue;

  String get currentUrgencyLabel => urgencyLevels[_currentSliderValue.toInt()];

  void setAgreement(bool? value) {
    agreement = value ?? false;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setMaxVolunteerCount(int count) {
    maxVolunteerCount = count;
    maxVolController.text = '$maxVolunteerCount';
    notifyListeners();
  }

  void setCurrentSliderValue(double value) {
    _currentSliderValue = value;
    urgency = urgencyLevels[value.toInt()];
    notifyListeners();
  }

  void setReceivingMethod(String? method) {
    receivingMethod = method;
    // Crucial: Reset bank details if receiving method is not bank transfer
    if (receivingMethod != 'Chuyển khoản ngân hàng') { // Ensure this matches the string in receivingMethods
      bankAccount = null;
      bankName = null; // Clear bankName as well
    } else {
      // If switching to bank transfer, ensure bankName has a valid default if it's currently null
      if (bankName == null && bankNames.isNotEmpty) {
        bankName = bankNames[0];
      }
    }
    notifyListeners();
  }

  void setBankName(String? name) {
    bankName = name;
    notifyListeners();
  }

  void setStartDate(DateTime? date) {
    startDate = date;
    if (endDate != null && startDate != null && endDate!.isBefore(startDate!)) {
      endDate = null;
    }
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    endDate = date;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (pickedImage != null) {
      mainImage = pickedImage;
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? now
          : (startDate ?? now),
      firstDate: isStartDate
          ? DateTime(now.year, now.month, now.day)
          : (startDate ?? DateTime(now.year, now.month, now.day)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.peach, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.deepOcean, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.skyMist, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (isStartDate) {
        setStartDate(pickedDate);
      } else {
        setEndDate(pickedDate);
      }
    }
  }

  Future<void> submitForm(BuildContext context) async {
    if (!formKey.currentState!.validate() || !agreement || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("please_fill_all_info_and_category".tr()))
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.orange.withOpacity(0.5), width: 2),
        ),
        backgroundColor: const Color(0xFFFFF8E1),
        title: Text(
          "confirm".tr(),
          style: const TextStyle(
            color: AppColors.deepOcean,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "confirm_send_request".tr(),
          style: const TextStyle(
            color: AppColors.deepOcean,
            fontSize: 16,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr(), style: const TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("send".tr(), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
    if (!confirmed) return;

    if (maxVolunteerCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("volunteer_max_required".tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();
    formKey.currentState!.save();

    String? imageUrl;
    if (mainImage != null) {
      final fileName = 'featured_activities/${DateTime.now().millisecondsSinceEpoch}_${mainImage!.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putFile(File(mainImage!.path));
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    final requestData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': selectedCategory,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'totalDonationAmount': 0.0,
      'participantCount': 0,
      'maxVolunteerCount': maxVolunteerCount,
      'fullName': userName,
      'phoneNumber': phoneController.text,
      'email': userEmail,
      'address': address,
      'supportType': supportType,
      'urgency': urgency, // Use the urgency property
      'receivingMethod': receivingMethod,
      'bankAccount': receivingMethod == 'Chuyển khoản ngân hàng' ? bankAccount : null,
      'bankName': receivingMethod == 'Chuyển khoản ngân hàng' ? bankName : null,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'creatorEmail': userEmail,
      'userId': userId,
    };

    try {
      await FirebaseFirestore.instance.collection('featured_activities').add(requestData);

      final userRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
      await userRef.update({'campaignCount': FieldValue.increment(1)});
    } catch (e) {
      // If the user document doesn't exist, create it
      if (e is FirebaseException && e.code == 'not-found') {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userEmail);
        await userRef.set({
          'campaignCount': 1,
          'email': userEmail,
          'name': userName,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Re-throw other unexpected errors
        rethrow;
      }
    }


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "support_request_created".tr(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    resetForm();
  }

  void resetForm() {
    formKey.currentState?.reset();
    phoneController.clear();
    mainImage = null;
    selectedCategory = null;
    startDate = null;
    endDate = null;
    address = null; // Set to null
    title = null; // Set to null
    description = null; // Set to null
    // Reset dropdown values to their initial state
    supportType = supportTypes.isNotEmpty ? supportTypes[0] : null;
    receivingMethod = receivingMethods.isNotEmpty ? receivingMethods[0] : null;
    bankAccount = null; // Bank account should be null
    bankName = bankNames.isNotEmpty ? bankNames[0] : null; // Reset bankName to default
    agreement = false;
    _currentSliderValue = 1; // Reset slider to default (medium urgency)
    urgency = urgencyLevels[_currentSliderValue.toInt()];
    maxVolunteerCount = 0;
    maxVolController.text = '0';
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    maxVolController.removeListener(_updateMaxVolunteerCount);
    maxVolController.dispose();
    super.dispose();
  }
}