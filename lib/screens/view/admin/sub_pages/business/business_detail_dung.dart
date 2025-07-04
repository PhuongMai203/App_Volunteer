import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../components/app_colors.dart';
import '../../widgets/legal_info_section.dart';
import 'basic_info_section.dart';
import 'activity_stats_section.dart';
import 'header_business.dart';
import 'legal_information/business_verification_service.dart';

class BusinessDetailsPage extends StatefulWidget {
  final String userId;
  final User? user;
  const BusinessDetailsPage({Key? key, required this.userId, this.user}) : super(key: key);

  @override
  _BusinessDetailsPageState createState() => _BusinessDetailsPageState();
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isEditing = false;
  late Map<String, dynamic> _data;
  late TabController _tabController;

  // State cho xác minh
  bool _verificationLoading = true;
  Map<String, dynamic> _verificationData = {};
  String _businessId = '';

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleApproval() async {
    try {
      // Gọi hàm phê duyệt
      await BusinessVerificationService.approveBusinessVerification(
        verificationId: _businessId,
      );

      // Load lại dữ liệu từ Firestore
      await _loadData();

      // Cập nhật UI
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text("approve_success".tr()),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _loadData() async {
    try {
      // Load user data
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!userSnap.exists) {
        if (mounted) setState(() => _isLoading = false);
        throw Exception('User document does not exist');
      }

      _data = userSnap.data() ?? {};

      // Load verification data
      try {
        final email = _data['email'];
        if (email != null && email.isNotEmpty) {
          final verificationSnap = await FirebaseFirestore.instance
              .collection('businessVerifications')
              .where('email', isEqualTo: email)
              .get();

          if (verificationSnap.docs.isNotEmpty) {
            _verificationData = verificationSnap.docs.first.data();
            _businessId = verificationSnap.docs.first.id;
          }
        }
      } catch (e) {
      }

      // Cập nhật controllers
      _nameCtrl.text = _data['name'] ?? '';
      _emailCtrl.text = _data['email'] ?? '';
      _roleCtrl.text = _data['role'] ?? '';
      _locationCtrl.text = _data['location'] ?? '';
      _phoneCtrl.text = _data['phone'] ?? '';

      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"error_loading_data".tr()} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRejection() async {
    if (!mounted) return;

    try {
      // Hiển thị dialog nhập lý do
      final rejectionReason = await showDialog<String>(
        context: context,
        builder: (context) {
          final _reasonCtrl = TextEditingController();
          return AlertDialog(
            title: Text("reject_reason".tr()),
            content: TextFormField(
              controller: _reasonCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "enter_reject_reason_hint".tr(),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancel".tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _reasonCtrl.text.trim()),
                child:  Text("confirm".tr()),
              ),
            ],
          );
        },
      );

      // Validate lý do
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

      if (mounted) setState(() => _isLoading = true);

      await BusinessVerificationService.rejectVerification(
        verificationId: _businessId,
        rejectionReason: rejectionReason,
      );
      await _loadData();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("reject_success".tr()),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on FirebaseException catch (e, stackTrace) {

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"db_error".tr()} ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FormatException catch (e, stackTrace) {

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"invalid_data".tr()} ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"system_error".tr()} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'role': _roleCtrl.text,
        'location': _locationCtrl.text,
        'phone': _phoneCtrl.text,
      });
      await _loadData();

      if (mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"save_error".tr()} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _showReasonDialog(BuildContext context, String title, String hint) {
    final _reasonCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Text("other_placeholder".tr()),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, null),
              child: Text("cancel".tr()),
            ),
            TextButton(
              onPressed: () {
                final reason = _reasonCtrl.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("reason_required".tr()),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                Navigator.pop(c, reason);
              },
              child: Text("ok".tr()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmAndDelete() async {
    final reason = await _showReasonDialog(
      context,
      "confirm_delete".tr(),
      "enter_delete_reason_hint".tr(),
    );
    if (reason == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();

      await FirebaseFirestore.instance
          .collection('userActions')
          .add({
        'userId': widget.userId,
        'action': 'delete',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("account_deleted".tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"error_deleting".tr()} ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleAccountStatus() async {
    final isDisabling = !(_data['isDisabled'] ?? false);
    final title = isDisabling ? "disable_account".tr() : "enable_account".tr();
    final hint = isDisabling ? "enter_reason_for_disabling".tr() : "enter_reactivation_reason".tr();

    final reason = await _showReasonDialog(context, title, hint);
    if (reason == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'isDisabled': isDisabling,
        'statusReason': reason,
      });

      await FirebaseFirestore.instance
          .collection('userActions')
          .add({
        'userId': widget.userId,
        'action': isDisabling ? 'disable' : 'enable',
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isDisabling
                ? "account_disabled".tr()
                : "account_enabled".tr()),
          ),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"update_error".tr()} ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final donatedAmount = _data['donatedAmount'] ?? 0;
    final donationCount = _data['donationCount'] ?? 0;
    final campaignCount = _data['campaignCount'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.cotton,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(size: 30.0, color: AppColors.pureWhite),
        title: Text(
          "business_details".tr(),
          style: TextStyle(
              color: AppColors.pureWhite, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 30),
              onPressed: () {
                if (mounted) {
                  setState(() => _isEditing = true);
                }
              },
            )
        ],
      ),
      body: Column(
        children: [
          HeaderBusiness(
            user: FirebaseAuth.instance.currentUser,
            userData: _data,
          ),
          PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: AppColors.pureWhite,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.sunrise,
                unselectedLabelColor: AppColors.deepOcean,
                indicatorColor: AppColors.sunrise,
                tabs: [
                  Tab(text: "basic_info".tr()),
                  Tab(text: "legal_info".tr()),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: BasicInfoSection(
                          isEditing: _isEditing,
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          roleCtrl: _roleCtrl,
                          locationCtrl: _locationCtrl,
                          phoneCtrl: _phoneCtrl,
                          data: _data,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ActivityStatsSection(
                          donatedAmount: donatedAmount,
                          donationCount: donationCount,
                          campaignCount: campaignCount,
                          isEditing: _isEditing,
                          data: _data,
                          onSave: _saveChanges,
                          onCancel: () {
                            if (mounted) {
                              setState(() => _isEditing = false);
                            }
                          },
                          onToggleStatus: _toggleAccountStatus,
                          onDelete: _confirmAndDelete,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                _verificationLoading
                    ? const Center(child: CircularProgressIndicator())
                    : LegalInfoSection(
                  data: _verificationData,
                  onApprove: _handleApproval,
                  onReject: _handleRejection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}