import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:help_connect/components/app_colors.dart';

class AccountActionButtons extends StatelessWidget {
  final bool isEditing;
  final Map<String, dynamic> data;
  final VoidCallback onSave;
  final VoidCallback onCancelEdit;
  final VoidCallback onToggleAccountStatus;
  final VoidCallback onDelete;

  const AccountActionButtons({
    Key? key,
    required this.isEditing,
    required this.data,
    required this.onSave,
    required this.onCancelEdit,
    required this.onToggleAccountStatus,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: isEditing
                ? ElevatedButton(
              onPressed: onSave,
              child: const Text('Lưu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sunrise,
                minimumSize: const Size.fromHeight(48),
              ),
            )
                : ElevatedButton.icon(
              icon: Icon(
                data['isDisabled'] ?? false
                    ? Icons.check_circle
                    : Icons.block,
              ),
              label: Text(
                data['isDisabled'] ?? false
                    ? "reactivate".tr()
                    : "disable".tr(),
              ),
              style: _customButtonStyle(
                bgColor: data['isDisabled'] ?? false
                    ? Colors.green[700]!
                    : Colors.orange[800]!,
              ),
              onPressed: onToggleAccountStatus,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? OutlinedButton(
              onPressed: onCancelEdit,
              child: Text("cancel".tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepOcean,
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: AppColors.deepOcean),
              ),
            )
                : OutlinedButton.icon(
              icon: const Icon(Icons.delete, size: 24),
              label: Text(
                "delete".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(
                    const Size.fromHeight(48)),
                side: WidgetStateProperty.all(
                  BorderSide(color: AppColors.sunrise, width: 1.5),
                ),
                backgroundColor:
                WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.sunrise;
                  }
                  return Colors.white;
                }),
                foregroundColor:
                WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white;
                  }
                  return AppColors.sunrise;
                }),
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _customButtonStyle({
    Color bgColor = Colors.white,
    Color borderColor = Colors.transparent,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton.styleFrom(
      foregroundColor: textColor,
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      elevation: 3,
      shadowColor: Colors.black12,
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}
