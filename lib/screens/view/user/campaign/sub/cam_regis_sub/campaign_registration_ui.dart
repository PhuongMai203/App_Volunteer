import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../components/app_colors.dart';
import '../../../../../../components/app_gradients.dart';
import '../../../../../../payments/momo/momo_payment.dart';
import '../../../../../../payments/zalo/payment_screen.dart';

class CampaignRegistrationUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FeaturedActivity activity;
  final String email;
  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController birthYearController;
  final TextEditingController phoneController;
  final TextEditingController donationCountController;
  final List<String> participationTypes;
  final bool showDonationMethods;
  final String donationCount;
  final Function(String, bool?) onParticipationChanged;
  final Function(String?) onDonationMethodChanged;
  final VoidCallback onSubmit;
  final int directVolunteerCount;
  final int maxVolunteerCount;

  const CampaignRegistrationUI({
    Key? key,
    required this.formKey,
    required this.activity,
    required this.email,
    required this.nameController,
    required this.locationController,
    required this.birthYearController,
    required this.phoneController,
    required this.donationCountController,
    required this.participationTypes,
    required this.showDonationMethods,
    required this.donationCount,
    required this.onParticipationChanged,
    required this.onDonationMethodChanged,
    required this.onSubmit,
    required this.directVolunteerCount,
    required this.maxVolunteerCount,
  }) : super(key: key);

  Future<void> _handleSubmit(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      if (participationTypes.contains("direct_volunteering".tr())) {
        // Có thể thêm logic đồng bộ calendar ở đây nếu cần
      }

      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';
      final userName = nameController.text;

      if (participationTypes.contains("donating_money".tr()) && donationCount == 'MoMo') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MomoPaymentPage(
              campaignId: activity.id,
              userId: userId,
              campaignTitle: activity.title,
              userName: userName,
            ),
          ),
        );
        return;
      } else if (participationTypes.contains("donating_money".tr()) && donationCount == 'ZaloPay') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZaloPayPaymentScreen(
              campaignId: activity.id,
              userId: userId,
              campaignTitle: activity.title,
              userName: userName,
            ),
          ),
        );
        return;
      }
      onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.peachPinkToOrange,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: false,
          backgroundColor: AppColors.cotton,
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, width),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: _buildFormContent(context, width),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, double width) {
    return AppBar(
      backgroundColor: AppColors.sunrise,
      title: Text(
        "join".tr(),
        style: TextStyle(
          color: AppColors.pureWhite,
          fontWeight: FontWeight.bold,
          fontSize: width * 0.05,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.pureWhite, size: width * 0.07),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, double width) {
    final padding = width * 0.04;
    return Card(
      color: const Color(0xFFFEFCEF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.title,
                style: TextStyle(
                  fontSize: width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepOcean,
                ),
              ),
              SizedBox(height: width * 0.05),
              _buildReadOnlyField("email".tr(), email),
              _buildEditableField("full_name".tr(), nameController, true),
              _buildEditableField("current_address".tr(), locationController, true),
              _buildEditableField("birth_year".tr(), birthYearController, true, inputType: TextInputType.number),
              _buildEditableField("phoneNumber".tr(), phoneController, true, inputType: TextInputType.phone),
              SizedBox(height: width * 0.04),
              _buildParticipationSection(context, width),
              SizedBox(height: width * 0.05),
              _buildSubmitButton(context, width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipationSection(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "join_method".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepOcean,
            fontSize: width * 0.045,
          ),
        ),
        ...["donating_money".tr(), "direct_volunteering".tr(), "donating_items".tr()]
            .map((option) => _buildParticipationOption(option, context, width))
            .toList(),
      ],
    );
  }

  Widget _buildParticipationOption(String option, BuildContext context, double width) {
    final isDisabled = option == "direct_volunteering".tr() && directVolunteerCount >= maxVolunteerCount;
    final selected = participationTypes.contains(option);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text(
            option,
            style: TextStyle(
              color: isDisabled ? Colors.grey : Colors.black,
              fontSize: width * 0.04,
            ),
          ),
          value: selected,
          onChanged: isDisabled ? null : (v) => onParticipationChanged(option, v),
          activeColor: AppColors.sunrise,
          checkColor: AppColors.pureWhite,
          contentPadding: EdgeInsets.zero,
        ),
        if (option == "donating_money".tr() && showDonationMethods)
          _buildDonationMethods(context, width),
      ],
    );
  }

  Widget _buildDonationMethods(BuildContext context, double width) {
    return Card(
      color: const Color(0xFFFFFAE0),
      margin: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.02),
      child: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: Column(
          children: ['ZaloPay', 'MoMo']
              .map((method) => RadioListTile<String>(
            title: Text(method, style: TextStyle(fontSize: width * 0.04)),
            value: method,
            groupValue: donationCount,
            onChanged: (v) => onDonationMethodChanged(v),
            activeColor: AppColors.deepOcean,
            contentPadding: EdgeInsets.zero,
          ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, double width) {
    return SizedBox(
      width: double.infinity,
      height: width * 0.12,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunrise,
          foregroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _handleSubmit(context),
        child: Text(
          "confirm_registration".tr(),
          style: TextStyle(fontSize: width * 0.045),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        decoration: _buildInputDecoration(label),
        initialValue: value,
        readOnly: true,
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isRequired, {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: _buildInputDecoration(label),
        validator: isRequired ? (value) => (value?.isEmpty ?? true) ? '${"please_enter".tr()} $label' : null : null,
        keyboardType: inputType,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.deepOcean,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.cotton,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.peach, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
