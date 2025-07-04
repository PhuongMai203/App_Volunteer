import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_repository/user_repository.dart';
import '../../../../../../../components/app_colors.dart';
import '../../../../../../../components/app_gradients.dart';
import '../../../../../../auth/views/forgot_password_screen.dart';

class EditProfileSecurityPage extends StatelessWidget {
  final MyUser user;

  const EditProfileSecurityPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
        // Đặt màu Status Bar khớp với màu AppBar để tạo sự liền mạch
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
    ),
    child: SafeArea(
    child: Container( // <--- ĐẶT LẠI CONTAINER CHỨA GRADIENT Ở ĐÂY
    decoration: const BoxDecoration(gradient: AppGradients.peachPinkToOrange),
    child: Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        title: Text(
          "security_and_passwords".tr(),
          style: GoogleFonts.agbalumo(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 28, // hoặc lớn hơn một chút
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 0),
                blurRadius: 2,
                color: Colors.white.withOpacity(0.4),
              ),
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: Text("resetPassword".tr()),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    "deleteAccount".tr(),
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    ),
    )
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(children: children),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:Text("confirmDeleteTitle".tr(), style: TextStyle(color: AppColors.deepOcean)),
        content: Text(
            "confirmDeleteContent".tr(),
          style: TextStyle(color: AppColors.slateGrey),
        ),
        actions: [
          TextButton(
            child: Text("cancel".tr(), style: TextStyle(color: AppColors.deepOcean)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: Text("confirm".tr(), style: TextStyle(color: AppColors.pureWhite)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleteTime = DateTime.now().add(const Duration(days: 3));
      await FirebaseFirestore.instance.collection('users').doc(user.userId).update({
        'scheduledDeleteAt': deleteTime.toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("accountWillBeDeleted".tr())),
        );
      }
    }
  }

}
