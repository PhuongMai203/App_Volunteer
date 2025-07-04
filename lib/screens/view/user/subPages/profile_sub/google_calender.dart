import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../components/app_colors.dart';
import '../../../../../service/google_calendar_service.dart';

Future<void> handleCreateEventsToGoogleCalendar(
    BuildContext context,
    List<FeaturedActivity> registeredEvents,
    ) async {
  void showCustomSnackBar(
      BuildContext context,
      String message,
      Color color,
      IconData icon, {
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 4),
        String? actionLabel,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    double horizontalMargin = screenWidth >= 600 ? 40 : 20;
    double iconSize = screenWidth >= 600 ? 24 : 20;
    double textSize = screenWidth >= 600 ? 16 : 14;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.pureWhite, size: iconSize),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: textSize),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 12),
        duration: duration,
        action: (onAction != null && actionLabel != null)
            ? SnackBarAction(
          label: actionLabel,
          onPressed: onAction,
          textColor: AppColors.pureWhite,
        )
            : null,
      ),
    );
  }

  try {
    final calendarApi = await signInAndGetCalendarData();
    if (calendarApi == null) {
      showCustomSnackBar(
        context,
        "calendar_connection_error".tr(),
        AppColors.deepOrange,
        Icons.warning,
      );
      return;
    }

    for (final event in registeredEvents) {
      final calendarEvent = Event()
        ..summary = event.title
        ..description = event.description
        ..start = EventDateTime(
          dateTime: event.startDate,
          timeZone: 'Asia/Ho_Chi_Minh',
        )
        ..end = EventDateTime(
          dateTime: event.endDate,
          timeZone: 'Asia/Ho_Chi_Minh',
        )
        ..reminders = EventReminders(
          useDefault: false,
          overrides: [
            EventReminder(method: 'popup', minutes: 10),
            EventReminder(method: 'email', minutes: 30),
          ],
        );

      await calendarApi.events.insert(calendarEvent, 'primary');
    }

    showCustomSnackBar(
      context,
      "event_added_success".tr(),
      const Color(0xFF27DD33),
      Icons.check_circle,
      actionLabel: "view_calendar".tr(),
      onAction: () async {
        const calendarUrl = 'https://calendar.google.com/calendar/u/0/r';
        if (await canLaunchUrl(Uri.parse(calendarUrl))) {
          await launchUrl(Uri.parse(calendarUrl), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("cannot_open_calendar".tr())),
          );
        }
      },
      duration: const Duration(seconds: 7), // Hiển thị SnackBar lâu hơn
    );
  } catch (e) {
    debugPrint('${"event_creation_error".tr()} $e');
    showCustomSnackBar(
      context,
      '${"event_creation_error".tr()} $e',
      const Color(0xFFF62828),
      Icons.error,
      duration: const Duration(seconds: 7),
    );
  }
}