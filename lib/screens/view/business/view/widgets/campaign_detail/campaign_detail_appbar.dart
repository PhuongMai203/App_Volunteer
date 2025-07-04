import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../components/app_colors.dart';
import 'edit_save_button.dart';

class CampaignDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isEditing;
  final VoidCallback onEdit;
  final Future<void> Function() onSave;

  const CampaignDetailAppBar({
    super.key,
    required this.title,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.sunrise,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        EditSaveButton(
          isEditing: isEditing,
          onEdit: onEdit,
          onSave: onSave,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
