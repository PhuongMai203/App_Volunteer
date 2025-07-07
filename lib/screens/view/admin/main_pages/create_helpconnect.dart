// File: lib/pages/create_help_request_page.dart
//TẠO ĐƠN CHO ADMIN
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_colors.dart';
import '../../user/subPages/sub_create/help_request_form.dart';

class CreateHelpConnectPage extends StatefulWidget {
  final String userEmail;
  final String userName;
  final OnSubmitCallback onSubmit;
  final Function onCampaignCreated;

  const CreateHelpConnectPage({
    Key? key,
    required this.userEmail,
    required this.userName,
    required this.onSubmit,
    required this.onCampaignCreated,
  }) : super(key: key);

  @override
  _CreateHelpConnectPageState createState() => _CreateHelpConnectPageState();
}

class _CreateHelpConnectPageState extends State<CreateHelpConnectPage> {
  String _userRole = '';
  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = doc.data()?['role'] ?? 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        title: Text(
          "home_create_campaign".tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: HelpRequestForm(
        userEmail: widget.userEmail,
        userName: widget.userName,
        onSubmit: widget.onSubmit,
        onCampaignCreated: widget.onCampaignCreated,
      ),
    );
  }
}