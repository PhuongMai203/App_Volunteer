import 'package:intl/intl.dart';

class CampaignUtils {
  static String formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDonation(double amount) {
    final formatter = NumberFormat.currency(
      symbol: 'VNĐ',
      decimalDigits: 0,
      customPattern: '#,##0 ¤',
    );
    return formatter.format(amount);
  }
}
