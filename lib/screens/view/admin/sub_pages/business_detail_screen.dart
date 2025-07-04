// business_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../../components/app_colors.dart';
import 'business/business_detail_body.dart';
import 'business/legal_information/business_verification_service.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({Key? key, required this.businessId}) : super(key: key);

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  late Future<Map<String, dynamic>?> _businessDataFuture;

  @override
  void initState() {
    super.initState();
    _businessDataFuture = _fetchBusinessData();
  }

  Future<Map<String, dynamic>?> _fetchBusinessData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('businessVerifications')
          .doc(widget.businessId)
          .get();

      if (!doc.exists) return null; // Kiểm document tồn tại
      final data = doc.data() ?? {}; // Tránh dùng !

      final storagePaths = {
        'logoUrl': 'logo',
        'stampUrl': 'stamp',
        'idCardFrontUrl': 'cccd_front',
        'idCardBackUrl': 'cccd_back',
      };

      Map<String, Future<String?>> imageFutures = {};
      for (final entry in storagePaths.entries) {
        final key = entry.key;
        final pathSegment = entry.value;
        final imagePath = data[key] is String ? data[key] as String? : null; // Kiểm tra kiểu
        imageFutures[key] = _getImageUrl(
          imagePath,
          'verifications/${widget.businessId}/$pathSegment.jpg',
        );
      }

      final urls = await Future.wait(imageFutures.values);
      final updatedData = Map<String, dynamic>.from(data);
      int idx = 0;
      for (final key in imageFutures.keys) {
        updatedData[key] = urls[idx++];
      }
      return updatedData;

    } catch (e) {
      rethrow; // Cho phép FutureBuilder bắt lỗi
    }
  }

  Future<String?> _getImageUrl(String? existingUrl, String storagePath) async {
    try {
      if (existingUrl != null && existingUrl.isNotEmpty) return existingUrl;
      return await FirebaseStorage.instance.ref(storagePath).getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') debugPrint('Storage error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return null;
    }
  }

  Future<void> _updateApprovalStatus(bool isApproved) async {
    try {
      if (isApproved) {
        await BusinessVerificationService.approveBusinessVerification(
          verificationId: widget.businessId,
        );
      } else {
        final rejectionReason = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final controller = TextEditingController();
            return StatefulBuilder(
              builder: (context, setState) {
                bool showError = false;

                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.sunrise, width: 2),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: controller,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: "enter_reject_reason_hint".tr(),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.sunrise),
                          ),
                          errorText: showError ? 'Vui lòng nhập lý do' : null,
                        ),
                        maxLines: 3,
                        onChanged: (value) => setState(() => showError = value.isEmpty),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("cancel".tr(), style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: controller.text.trim().isEmpty
                          ? null
                          : () => Navigator.pop(context, controller.text.trim()),
                      child: Text(
                        "confirm".tr(),
                        style: TextStyle(
                          color: controller.text.trim().isEmpty ? Colors.grey : Colors.green,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );

        if (rejectionReason == null || rejectionReason.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("enter_reject_reason".tr()),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        await BusinessVerificationService.rejectVerification(
          verificationId: widget.businessId,
          rejectionReason: rejectionReason,
        );
      }

      if (mounted) {
        final newFuture = _fetchBusinessData();
        setState(() {
          _businessDataFuture = newFuture;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"error".tr()} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: Text(
          "verification_request".tr(),
          style: TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.sunrise,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: _businessDataFuture,
        builder: (context, snap) {
          if (snap.hasError) { // Xử lý lỗi tổng thể
            return Center(child: Text('${"error".tr()} ${snap.error.toString()}'));
          }

          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data;
          if (data == null) {
            return Center(child: Text( "no_data_found".tr()));
          }

          return BusinessDetailBody(
            businessId: widget.businessId,
            data: data,
            onApproved: () => _updateApprovalStatus(true),
            onRejected: () => _updateApprovalStatus(false),
          );
        },
      ),
    );
  }
}