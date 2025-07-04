import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chat_intent_handler.dart';

Future<void> listModels() async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
  );
}

Future<String> sendMessageToGemini(String userMessage, String userId) async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  // 🔍 1. Xử lý câu hỏi có thể trả lời bằng dữ liệu Firestore
  final dynamicResponse = await ChatIntentHandler.process(userMessage, userId);
  if (dynamicResponse.isNotEmpty) return dynamicResponse;

  // 🧠 2. Nếu không khớp intent cụ thể, gửi về Gemini xử lý
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-002:generateContent?key=$apiKey',
  );

  final prompt = '''
Bạn là trợ lý ảo của ứng dụng Kết nối tình nguyện viên với hoạt động cộng đồng.
Trả lời ngắn gọn, dễ hiểu và thân thiện. Tránh lặp lại thông tin không cần thiết. Nếu có thể, trình bày dưới dạng danh sách các bước rõ ràng, đơn giản.
App có các chức năng chính:
- Đăng ký và đăng nhập tài khoản người dùng. 
- Tạo và tham gia các chiến dịch tình nguyện.
- Đóng góp bằng tiền, vật phẩm hoặc tham gia tình nguyện trực tiếp.
- Theo dõi hoạt động, thống kê và phản hồi.
- Lấy lại mật khẩu khi quên mật khẩu.
- Chia sẻ ứng dụng hoặc chiến dịch của ứng dụng.

Người dùng là tình nguyện viên có thể:
- Xem danh sách chiến dịch tại trang Bảng tin.
- Click "Tham gia" để chọn hình thức tham gia.
- Sử dụng ZaloPay hoặc Momo để quyên góp.
- Lưu chiến dịch quan tâm.
- Theo dõi các chiến dịch đã tham gia trong trang Tài khoản.
- Chỉnh sửa hồ sơ, xem thống kê số tiền đã quyên góp, số chiến dịch đã tham gia, số chiến dịch đã đánh giá tại trang cá nhân.
- Đánh giá chiến dịch đã tham gia.
- Báo cáo chiến dịch đáng ngờ.
- Tìm kiếm chiến dịch, lọc chiến dịch.
- Tìm kiếm chiến dịch theo vị trí.
- Đồng bộ với lịch calender để nhắc nhở chiến dịch đã đăng ký.
- Nhận thông báo khi chiến dịch sắp tới hạn diễn ra.
- Đối với người dùng đăng ký tài khoản doanh nghiệp thì sau khi thực hiện đăng ký bình thường rồi click đăng ký thì nó sẽ chuyển hướng qua trang gửi thông tin xác minh tài khoản doanh nghiệp đến admin chờ admin xét duyệt rồi mới đăng nhập đươc. Ngoài ra có thể đăng nhập bằng tài khoản google hoặc facebook

Người dùng là tổ chức có thể:
- Xem danh sách chiến dịch đã tạo.
- Tạo/sửa/xóa chiến dịch.
- Xem thông tin chi tiết chiến dịch ở trang thông tin chi tiết bao gồm: danh sách những người tham gia trực tiếp, danh sách những người đóng góp bằng tiền, xem đánh giá chiến dịch đã hoàn thành.
- Thống kê chiến dịch, thống kê hoạt động, thống kê tình nguyện viên, thống kê chất lượng.
- Nhận thông báo khi có tình nguyện viên chuyển khoản hay đánh giá.
- Xuất danh sách những người tham gia trực tiếp, danh sách những người đóng góp bằng tiền ra file excel.
Xin lỗi, tôi chưa hiểu câu hỏi của bạn. Hãy giải thích cụ thể hơn để tôi có thể giúp bạn.
Người dùng hỏi: "$userMessage"
''';

  final headers = {'Content-Type': 'application/json'};

  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt}
        ]
      }
    ]
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return reply ?? '🤖 Không có phản hồi từ Gemini.';
    } else {
      print('❌ API Error: ${response.statusCode} - ${response.body}');
      return '❌ Lỗi API: ${jsonDecode(response.body)?['error']?['message'] ?? 'Không rõ lỗi.'}';
    }
  } catch (e) {
    print("❌ Exception: $e");
    return '⚠️ Lỗi hệ thống: $e';
  }
}
