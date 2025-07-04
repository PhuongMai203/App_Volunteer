import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:help_connect/screens/auth/views/sign_in_screen.dart';

import '../../../../../components/app_colors.dart';

class CampaignReport {
  static void showReportDialog(BuildContext context, FeaturedActivity activity) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
      return;
    }

    String? selectedReason;
    TextEditingController otherReasonController = TextEditingController();
    final width = MediaQuery.of(context).size.width;
    final padding = width * 0.04;
    final fontSize = width * 0.04;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                dialogTheme: const DialogThemeData(
                  backgroundColor: Colors.white,
                ),
                unselectedWidgetColor: AppColors.sunrise,
              ),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.sunrise, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "report".tr(),
                      style: TextStyle(color: AppColors.deepOrange, fontSize: fontSize + 2),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: width * 0.06),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                content: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "report_description".tr(),
                          style: TextStyle(fontSize: fontSize, color: AppColors.slateGrey),
                        ),
                        SizedBox(height: padding),
                        ...[
                          {'label': "violence".tr(), 'value': "value_violence".tr()},
                          {'label': "illegal_sales".tr(), 'value': "value_illegal_sales".tr()},
                          {'label': "false_info".tr(), 'value': "value_false_info".tr()},
                          {'label': "other".tr(), 'value': "other".tr()},
                        ].map((item) => RadioListTile<String>(
                          title: Text(item['label']!, style: TextStyle(fontSize: fontSize)),
                          value: item['value']!,
                          groupValue: selectedReason,
                          activeColor: AppColors.deepOrange,
                          onChanged: (value) => setState(() => selectedReason = value),
                        )),
                        if (selectedReason == "other".tr())
                          Padding(
                            padding: EdgeInsets.only(top: padding / 2),
                            child: TextField(
                              controller: otherReasonController,
                              style: const TextStyle(color: AppColors.deepOcean),
                              decoration: InputDecoration(
                                labelText: "other_placeholder".tr(),
                                labelStyle: const TextStyle(color: AppColors.deepOcean),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.peach),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.peach, width: 2),
                                ),
                              ),
                              maxLines: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => Navigator.pop(context),
                    child: Text("cancel".tr(), style: const TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      String reason = selectedReason ?? '';
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("select_reason_warning".tr())),
                        );
                        return;
                      }
                      if (reason == "other".tr()) {
                        reason = otherReasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("empty_reason_warning".tr())),
                          );
                          return;
                        }
                      }

                      FirebaseFirestore.instance.collection('reports').add({
                        'activityId': activity.id,
                        'userId': user.uid,
                        'reason': reason,
                        'createdAt': Timestamp.now(),
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("report_success".tr())),
                      );
                    },
                    child: Text("send".tr(), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
