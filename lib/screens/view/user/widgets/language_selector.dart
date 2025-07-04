import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double iconSize = 22;
    double fontSize = 14;
    double paddingV = 8;
    double paddingH = 12;

    if (screenWidth > 400) {
      iconSize = 26;
      fontSize = 16;
      paddingV = 10;
      paddingH = 16;
    }
    if (screenWidth > 600) {
      iconSize = 28;
      fontSize = 18;
      paddingV = 12;
      paddingH = 20;
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          backgroundColor: Colors.white,
          builder: (context) => _buildLanguageSheet(context),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: Colors.deepOrange, size: iconSize),
            const SizedBox(width: 8),
            Text(
              "language".tr(),
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.deepOrange, size: iconSize + 4),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final flagSize = screenWidth < 400 ? 28.0 : 32.0;
    final textSize = screenWidth < 400 ? 16.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageTile(context, '🇻🇳', 'Tiếng Việt', const Locale('vi'), flagSize, textSize),
          const Divider(height: 1),
          _buildLanguageTile(context, '🇬🇧', 'English', const Locale('en'), flagSize, textSize),
          const Divider(height: 1),
          _buildLanguageTile(context, '🇯🇵', '日本語', const Locale('ja'), flagSize, textSize),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String flag, String language, Locale locale, double flagSize, double textSize) {
    return ListTile(
      leading: Text(flag, style: TextStyle(fontSize: flagSize)),
      title: Text(
        language,
        style: TextStyle(fontSize: textSize, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: context.locale == locale ? Colors.orange.shade50 : null,
      onTap: () {
        context.setLocale(locale);
        Navigator.pop(context);
      },
      splashColor: Colors.orange.shade100,
    );
  }
}
