import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../components/app_colors.dart';
import '../../user/subPages/event_tabs.dart';
import '../../user/widgets/campaign/user_event_tab_section.dart';
import '../widgets/account_action_buttons.dart';
import '../widgets/basic_info_card.dart';
import '../widgets/user_event_tab_admin.dart';
import '../widgets/user_statistics_card.dart';
import 'business/header_business.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  const UserDetailsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool _isLoading = true;
  bool _isEditing = false;
  late Map<String, dynamic> _data;
  final User? user = FirebaseAuth.instance.currentUser;
  // Controllers cho form
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _birthYearCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  num donatedAmount = 0;
  @override
  void initState() {
    super.initState();
    _loadUser();
    loadTotalDonated();
  }

  Future<void> _loadUser() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    _data = snap.data()!;
    // khởi tạo controller
    _nameCtrl.text = _data['name'] ?? '';
    _emailCtrl.text = _data['email'] ?? '';
    _roleCtrl.text = _data['role'] ?? '';
    _genderCtrl.text = _data['gender'] ?? '';
    _birthYearCtrl.text = (_data['birthYear'] ?? '').toString();
    _locationCtrl.text = _data['location'] ?? '';
    _phoneCtrl.text = _data['phone'] ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'role': _roleCtrl.text,
        'gender': _genderCtrl.text,
        'birthYear': int.tryParse(_birthYearCtrl.text),
        'location': _locationCtrl.text,
        'phone': _phoneCtrl.text,
      });
      await _loadUser();
      setState(() => _isEditing = false);

      // ✅ Hiển thị thông báo "Đã lưu thay đổi"
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "save_changes".tr(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error'.tr()} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text( "confirm_delete".tr()),
        content: Text("delete_this_account".tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("cancel".tr())),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text("delete".tr())),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("account_deleted".tr())),
        );
        Navigator.pop(context);
      }
    }
  }
  Future<num> getTotalDonatedAmount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .get();
    num total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] ?? 0);
    }

    return total;
  }


  Future<void> loadTotalDonated() async {
    donatedAmount = await getTotalDonatedAmount(widget.userId);
    setState(() {});
  }

  Future<void> _toggleAccountStatus() async {
    final newStatus = !(_data['isDisabled'] ?? false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus ? "disable_account".tr() : "enable_account".tr()),
        content: Text(newStatus
            ? "user_not_login".tr()
            : "user_able_login".tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(newStatus ? "disable".tr() : "reactivate".tr(),
                style: TextStyle(color: newStatus ? Colors.red : Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'isDisabled': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newStatus
              ? "account_disabled".tr()
              :  "account_enabled".tr())),
        );
        await _loadUser();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final campaignCount = _data['campaignCount'] ?? 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.cotton,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        centerTitle: true,
        elevation: 1,
        iconTheme: const IconThemeData(size: 30.0, color: AppColors.pureWhite),
        title: Text(
          "user_detail".tr(),
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, size: 30),
              onPressed: () => setState(() => _isEditing = true),
            )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderBusiness(
                user: FirebaseAuth.instance.currentUser,
                userData: _data,
              ),
              // THÔNG TIN CƠ BẢN
              BasicInfoCard(
                data: _data,
                isEditing: _isEditing,
                nameCtrl: _nameCtrl,
                emailCtrl: _emailCtrl,
                roleCtrl: _roleCtrl,
                genderCtrl: _genderCtrl,
                birthYearCtrl: _birthYearCtrl,
                locationCtrl: _locationCtrl,
                phoneCtrl: _phoneCtrl,
              ),
              const SizedBox(height: 16),
              // THỐNG KÊ
              UserStatisticsCard(
                donatedAmount: donatedAmount,
                campaignCount: campaignCount,
              ),
              const SizedBox(height: 16),
              UserEventTabAdmin(userId: widget.userId),
              const SizedBox(height: 24),
              // NÚT HÀNH ĐỘNG
              AccountActionButtons(
                isEditing: _isEditing,
                data: _data,
                onSave: _saveChanges,
                onCancelEdit: () => setState(() => _isEditing = false),
                onToggleAccountStatus: _toggleAccountStatus,
                onDelete: _confirmAndDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
