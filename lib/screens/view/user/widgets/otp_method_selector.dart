import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OTPMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String?> onChanged;

  const OTPMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "otp_method_selector.title".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: Text("otp_method_selector.sms".tr()),
          value: 'SMS',
          groupValue: selectedMethod,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: Text("otp_method_selector.email".tr()),
          value: "email".tr(),
          groupValue: selectedMethod,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
