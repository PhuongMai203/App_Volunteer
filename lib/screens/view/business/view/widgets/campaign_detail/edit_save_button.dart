import 'package:flutter/material.dart';

class EditSaveButton extends StatelessWidget {
  final bool isEditing;
  final Future<void> Function()? onSave;
  final VoidCallback? onEdit;

  const EditSaveButton({
    super.key,
    required this.isEditing,
    this.onSave,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isEditing ? Icons.save : Icons.edit),
      onPressed: () async {
        if (isEditing) {
          if (onSave != null) {
            await onSave!();
          }
        } else {
          if (onEdit != null) {
            onEdit!();
          }
        }
      },
    );
  }
}
