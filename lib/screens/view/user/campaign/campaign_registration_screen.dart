import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';

import '../../../../components/app_colors.dart';
import 'sub/cam_regis_sub/campaign_registration_service.dart';
import 'sub/cam_regis_sub/campaign_registration_ui.dart';

class CampaignRegistrationScreen extends StatefulWidget {
  final FeaturedActivity activity;
  final VoidCallback? onRegistered;
  const CampaignRegistrationScreen({
    super.key,
    required this.activity,
    this.onRegistered,
  });

  @override
  State<CampaignRegistrationScreen> createState() =>
      _CampaignRegistrationScreenState();
}

class _CampaignRegistrationScreenState
    extends State<CampaignRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CampaignRegistrationService();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _donationCountController = TextEditingController();

  String _email = '';
  String _donationCount = '';
  List<String> _participationTypes = [];
  bool _showDonationMethods = false;

  @override
  void initState() {
    super.initState();
    _email = _service.getCurrentUserEmail();
    _service.fetchUserInfo(
      context,
      _nameController,
      _locationController,
      _birthYearController,
      _phoneController,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _birthYearController.dispose();
    _phoneController.dispose();
    _donationCountController.dispose();
    super.dispose();
  }

  void _handleParticipationChange(String option, bool? value) {
    setState(() {
      if (value == true) {
        _participationTypes.add(option);
      } else {
        _participationTypes.remove(option);
      }
      _showDonationMethods = option == "donating_money".tr() && value == true;
    });
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_participationTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "choose_format".tr(),
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: AppColors.lightPinkRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final already = await _service.isAlreadyRegistered(
      userId: FirebaseAuth.instance.currentUser!.uid,
      campaignId: widget.activity.id,
    );
    if (already) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "already_registered".tr(),
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          backgroundColor: AppColors.lightPinkRed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Khi đăng ký xong thì thêm vào Google Calendar nếu chọn trực tiếp
    await _service.submitRegistration(
      context: context,
      activity: widget.activity,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      birthYear: _birthYearController.text.trim(),
      phone: _phoneController.text.trim(),
      participationTypes: _participationTypes,
      donationAmount: _donationCountController.text.trim(),
      onRegistered: widget.onRegistered,
    );

  }

  @override
  Widget build(BuildContext context) {
    return CampaignRegistrationUI(
      formKey: _formKey,
      activity: widget.activity,
      email: _email,
      nameController: _nameController,
      locationController: _locationController,
      birthYearController: _birthYearController,
      phoneController: _phoneController,
      donationCountController: _donationCountController,
      participationTypes: _participationTypes,
      showDonationMethods: _showDonationMethods,
      donationCount: _donationCount,
      onParticipationChanged: _handleParticipationChange,
      onDonationMethodChanged: (value) => setState(() => _donationCount = value!),
      onSubmit: _submitRegistration,
      directVolunteerCount: widget.activity.directVolunteerCount,
      maxVolunteerCount: widget.activity.maxVolunteerCount,
    );
  }
}
