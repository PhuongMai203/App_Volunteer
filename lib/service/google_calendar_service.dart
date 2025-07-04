import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;

/// Khởi tạo GoogleSignIn với các quyền cần thiết
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    calendar.CalendarApi.calendarScope,
  ],
);

/// Đăng nhập và lấy dữ liệu từ Google Calendar
Future<calendar.CalendarApi?> signInAndGetCalendarData() async {
  try {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      print("cancelled_login".tr());
      return null;
    }

    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      print("accessToken".tr());
      return null;
    }

    final client = GoogleHttpClient(accessToken);
    final calendarApi = calendar.CalendarApi(client);

    return calendarApi; // ✅ TRẢ VỀ calendarApi để bên ngoài dùng tiếp
  } catch (e) {
    print("${"error_logging".tr()} $e");
    return null;
  }
}
/// Custom HTTP client để đính kèm access token
class GoogleHttpClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    request.headers['Content-Type'] = 'application/json';
    return _client.send(request);
  }
}
