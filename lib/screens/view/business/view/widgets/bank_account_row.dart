import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class BankAccountRow extends StatelessWidget {
  final String bankName;
  final String bankAccount;

  const BankAccountRow({
    super.key,
    required this.bankName,
    required this.bankAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance, size: 16, color: Colors.lightGreen.shade900),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${"account".tr()} $bankName - $bankAccount',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.deepOcean,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bankAccount));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "copiedBankAccount".tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
