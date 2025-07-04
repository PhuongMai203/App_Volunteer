import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';

import '../../../view/admin/adminDashboardPage.dart';
import '../../../view/business/view/main_pages/home_business.dart';
import '../../../view/user/main_pages/landing_page.dart';

import '../../blocs/sign_in_bloc/sign_in_bloc.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> handleAuthState({
    required BuildContext context,
    required dynamic state,
    required String? userType,
  }) async {
    if (state is SignInSuccess) {
      await handleSignInSuccessAndNavigate(context, userType);
    } else if (state is SignInFailure) {
      _showErrorDialog(context, state.errorMessage);
    }
  }

  static Future<void> handleSignInSuccessAndNavigate(BuildContext context, String? userType) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await checkAndCancelAccountDeletion(user.uid);

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData == null) {
      _showErrorDialog(context, 'user_data_not_found'.tr());
      await _auth.signOut();
      return;
    }

    if (userData['isDisabled'] == true) {
      await showAccountDisabledDialog(context);
      await _auth.signOut();
      return;
    }

    final actualRole = userData['role'] ?? 'user';

    if (actualRole != 'admin' && userType != null && actualRole != userType) {
      await _showRoleMismatchDialog(context, actualRole, userType);
      await _auth.signOut();
      return;
    }
    navigateByRole(context, actualRole);
  }

  static void navigateByRole(BuildContext context, String actualRole) {
    Widget targetPage;

    switch (actualRole) {
      case 'admin':
        targetPage = const AdminDashboardPage();
        break;
      case 'organization':
        targetPage = PartnerHomePage();
        break;
      case 'user':
      default:
        targetPage = const LandingPage();
        break;
    }

    // Kiểm tra ràng buộc truy cập
    final invalidAccess =
    // Admin/Org không được vào LandingPage
    (['admin', 'organization'].contains(actualRole) &&
        targetPage is LandingPage) ||

        // User/Org không được vào AdminDashboard
        (['user', 'organization'].contains(actualRole) &&
            targetPage is AdminDashboardPage) ||

        // Admin/User không được vào PartnerHomePage
        (['admin', 'user'].contains(actualRole) &&
            targetPage is PartnerHomePage);

    if (invalidAccess) {
      // Xử lý truy cập không hợp lệ bằng cách chuyển hướng đến trang mặc định
      Widget fallbackPage = const LandingPage();

      if (['admin'].contains(actualRole)) {
        fallbackPage = const AdminDashboardPage();
      } else if (['organization'].contains(actualRole)) {
        fallbackPage = PartnerHomePage();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => fallbackPage),
            (route) => false,
      );
      return;
    }

    // Điều hướng bình thường
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
          (route) => false,
    );
  }

  static Future<void> showAccountDisabledDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('account_disabled'.tr()),
        content: Text('contact_admin'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  static Future<void> checkAndCancelAccountDeletion(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final doc = await docRef.get();

    if (doc.exists && doc.data()?['scheduledDeleteAt'] != null) {
      final deleteAt = DateTime.parse(doc.data()!['scheduledDeleteAt']);
      final now = DateTime.now();

      if (now.isBefore(deleteAt)) {
        await docRef.update({
          'scheduledDeleteAt': FieldValue.delete(),
        });
      }
    }
  }

  static void _showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.yellow.shade50,
        title: Text(
          'sign_in_error'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message ?? 'unknown_error'.tr(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'close'.tr(),
              style: GoogleFonts.poppins(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _showRoleMismatchDialog(BuildContext context, String actualRole, String selectedRole) async {
    final roleName = {
      'admin': 'Quản trị viên',
      'organization': 'Doanh nghiệp',
      'user': 'Người cần giúp đỡ',
    };

    final actualRoleName = roleName[actualRole] ?? actualRole;
    final selectedRoleName = roleName[selectedRole] ?? selectedRole;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sai vai trò'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn đang cố đăng nhập với vai trò "$selectedRoleName", nhưng tài khoản của bạn là "$actualRoleName".\nVui lòng chọn đúng vai trò.',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD8CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Đóng'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
