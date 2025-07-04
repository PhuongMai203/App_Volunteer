// File: lib/pages/create_help_request_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../components/app_colors.dart';
import '../../../user/subPages/sub_create/help_request_form.dart';
import '../widgets/nav_bar.dart';

class CreateHelpPage extends StatefulWidget {
  final String userEmail;
  final String userName;
  final OnSubmitCallback onSubmit;
  final Function onCampaignCreated;

  const CreateHelpPage({
    Key? key,
    required this.userEmail,
    required this.userName,
    required this.onSubmit,
    required this.onCampaignCreated,
  }) : super(key: key);

  @override
  _CreateHelpPageState createState() => _CreateHelpPageState();
}

class _CreateHelpPageState extends State<CreateHelpPage> {
  String _userRole = '';
  int _selectedIndex = 3;

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/partner-home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/my-campaigns');
        break;
      case 2:
        Navigator.pushNamed(context, '/completed-campaigns');
        break;
      case 3:
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.pureWhite),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/partner-home', (route) => false);
          },
        ),
        backgroundColor: AppColors.sunrise,
        title: Text("home_create_campaign".tr(),style: GoogleFonts.poppins(
          fontSize: 23,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),),
      ),
      body: HelpRequestForm(
        userEmail: widget.userEmail,
        userName: widget.userName,
        onSubmit: widget.onSubmit,
        onCampaignCreated: widget.onCampaignCreated,
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}