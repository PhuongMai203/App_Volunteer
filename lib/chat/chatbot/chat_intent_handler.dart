import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:string_similarity/string_similarity.dart'; // Import thư viện độ tương đồng chuỗi

class _Intent {
  final List<String> keywords;
  final Future<String> Function(String question, String userId) handler;

  _Intent(this.keywords, this.handler);
}

class ChatIntentHandler {
  static final List<_Intent> _intents = [
    _Intent(["chiến dịch", "tham gia"], (question, userId) => _getJoinedCampaigns(userId)),
    _Intent(["tôi", "đăng ký", "chiến dịch"], (question, userId) => _getJoinedCampaignCount(userId)),
    _Intent(["khi nào", "bắt đầu", "chiến dịch"], (question, userId) => _getCampaignStartTime(question)),
    _Intent(["khi nào", "kết thúc", "chiến dịch"], (question, userId) => _getCampaignEndTime(question)),
    _Intent(["tiền", "đã quyên góp"], (question, userId) => _getDonationSummary(userId)),
    _Intent(["địa chỉ", "chiến dịch"], (question, userId) => _getCampaignAddress(question)),
    _Intent(["người tạo", "chiến dịch"], (question, userId) => _getCampaignCreator(question)),
    _Intent(["tình trạng", "chiến dịch"], (question, userId) => _getCampaignStatus(question)),
    _Intent(["số lượng tối đa", "tình nguyện viên", "chiến dịch"], (question, userId) => _getMaxVolunteerCount(question)),
    _Intent(["tài khoản", "chiến dịch"], (question, userId) => _getCampaignBank(question)),
    _Intent(["bao nhiêu", "tình nguyện viên", "chiến dịch"], (question, userId) => _getParticipantCount(question)),
    _Intent(["chiến dịch", "bao nhiêu", "tiền", "quyên góp"], (question, userId) => _getCampaignDonationAmount(question)),
  ];

  // Tập hợp tất cả các từ khóa cốt lõi cần được nhận diện linh hoạt
  static final Set<String> _allCoreKeywords = {
    'chiến dịch', 'tham gia', 'tôi', 'đăng ký', 'khi nào', 'bắt đầu',
    'kết thúc', 'tiền', 'đã quyên góp', 'địa chỉ', 'người tạo',
    'tình trạng', 'số lượng tối đa', 'tình nguyện viên', 'tài khoản',
    'bao nhiêu', 'quyên góp', 'ngân hàng', 'thời gian', 'chi tiết', 'ai tạo',
    // Thêm các từ khóa khác bạn muốn xử lý lỗi chính tả tự động
  };

  static Future<String> process(String question, String userId) async {
    // 1. Chuyển về chữ thường và loại bỏ dấu
    String processedQuestion = question.toLowerCase();
    processedQuestion = removeDiacritics(processedQuestion);

    // 2. Tách câu hỏi thành các từ và sửa lỗi chính tả cho từng từ
    final words = processedQuestion.split(' ');
    final correctedWords = words.map((word) => _correctWord(word)).toList();
    processedQuestion = correctedWords.join(' '); // Ghép lại thành câu đã sửa

    // 3. Kiểm tra các ý định (intent matching)
    for (final intent in _intents) {
      if (_match(processedQuestion, intent.keywords)) {
        return await intent.handler(question, userId); // Truyền lại câu hỏi gốc (hoặc đã xử lý) tùy theo nhu cầu của hàm handler
      }
    }

    // Nếu không tìm thấy ý định nào khớp
    return "Xin lỗi, tôi không hiểu câu hỏi của bạn. Bạn có thể hỏi lại rõ ràng hơn không?";
  }

  // Hàm _match bây giờ sẽ hoạt động với câu hỏi đã được tiền xử lý và sửa lỗi
  static bool _match(String input, List<String> keywords) {
    // Chuẩn hóa các từ khóa trong intent để so sánh
    final normalizedKeywords = keywords.map((kw) => removeDiacritics(kw.toLowerCase())).toList();
    return normalizedKeywords.every((kw) => input.contains(kw));
  }

  // Hàm mới để sửa lỗi chính tả cho từng từ dựa trên độ tương đồng
  static String _correctWord(String word) {
    if (_allCoreKeywords.contains(word)) {
      return word; // Nếu từ đã đúng, không cần sửa
    }

    String? bestMatch;
    double bestSimilarity = 0.0;
    const double minSimilarityForCorrection = 0.7; // Ngưỡng chấp nhận để sửa lỗi (điều chỉnh nếu cần)

    for (final keyword in _allCoreKeywords) {
      final similarity = word.similarityTo(keyword);

      if (similarity > bestSimilarity) {
        bestSimilarity = similarity;
        bestMatch = keyword;
      }
    }

    // Nếu tìm thấy từ khớp tốt và đạt ngưỡng, trả về từ đã sửa
    if (bestMatch != null && bestSimilarity >= minSimilarityForCorrection) {
      return bestMatch;
    }
    return word; // Trả về từ gốc nếu không tìm thấy từ nào đủ tương đồng để sửa
  }

  // --- Các hàm xử lý intent (được giữ nguyên hoặc chỉ thay đổi _findCampaignByTitle) ---

  static Future<String> _getJoinedCampaigns(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return 'Bạn chưa tham gia chiến dịch nào.';

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final title = data?['title'] ?? 'Không rõ tên chiến dịch';
      final status = data?['attendanceStatus'] ?? 'Không rõ trạng thái';
      return '- $title (Trạng thái: $status)';
    }).join('\n');
  }

  static Future<String> _getJoinedCampaignCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: userId)
        .get();

    final count = snapshot.docs.length;
    return 'Bạn đã đăng ký $count chiến dịch.';
  }

  static Future<String> _getCampaignStartTime(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'];
    final startTime = data?['startDate'];
    if (startTime is Timestamp) {
      final startDate = startTime.toDate().toLocal();
      return 'Chiến dịch "$title" bắt đầu vào ngày ${_formatDate(startDate)}.';
    }

    return 'Không có thông tin ngày bắt đầu cho chiến dịch "$title".';
  }

  static Future<String> _getCampaignAddress(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'];
    final address = data?['address'] ?? 'Không có thông tin địa chỉ.';
    return 'Địa chỉ của chiến dịch "$title" là: $address.';
  }
  static Future<String> _getParticipantCount(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;

    final title = data?['title'] ?? 'Không rõ tên chiến dịch';
    final count = data?['participantCount'];

    if (count == null) {
      return 'Chiến dịch "$title" chưa có thông tin về số lượng tình nguyện viên.';
    }

    return 'Chiến dịch "$title" đã có $count tình nguyện viên tham gia.';
  }

  static Future<String> _getCampaignCreator(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'];
    final creatorEmail = data?['creatorEmail'] ?? 'Không có thông tin người tạo.';
    return 'Người tạo chiến dịch "$title" là: $creatorEmail.';
  }

  static Future<String> _getCampaignStatus(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'];
    final status = data?['status'] ?? 'Không có thông tin tình trạng.';
    return 'Tình trạng hiện tại của chiến dịch "$title" là: $status.';
  }

  static Future<String> _getMaxVolunteerCount(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return 'Không lấy được dữ liệu chiến dịch.';

    final title = data['title'] ?? 'Không rõ tên chiến dịch';
    final maxCount = data['maxVolunteerCount'];

    if (maxCount == null) {
      return 'Chiến dịch "$title" không có thông tin về số lượng tình nguyện viên tối đa.';
    }

    return 'Chiến dịch "$title" có tối đa $maxCount tình nguyện viên.';
  }

  static Future<String> _getCampaignEndTime(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'];
    final endTime = data?['endDate'];
    if (endTime is Timestamp) {
      final endDate = endTime.toDate().toLocal();
      return 'Chiến dịch "$title" kết thúc vào ngày ${_formatDate(endDate)}.';
    }

    return 'Không có thông tin ngày kết thúc cho chiến dịch "$title".';
  }

  static Future<String> _getCampaignBank(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp';

    final data = doc.data() as Map<String, dynamic>;
    final bankName = data['bankName'];
    final bankAccount = data['bankAccount'];

    if (bankName == null || bankAccount == null) {
      return 'Chiến dịch này chưa cập nhật thông tin ngân hàng.';
    }

    return 'Thông tin tài khoản ngân hàng của chiến dịch:\n'
        '🏦 Ngân hàng: $bankName\n'
        '💳 Số tài khoản: $bankAccount';
  }
  static Future<String> _getCampaignDonationAmount(String question) async {
    final doc = await _findCampaignByTitle(question);
    if (doc == null) return 'Không tìm thấy chiến dịch phù hợp.';

    final data = doc.data() as Map<String, dynamic>?;
    final title = data?['title'] ?? 'Không rõ tên chiến dịch';
    final amount = data?['totalDonationAmount'];

    if (amount == null || amount is! num) {
      return 'Chiến dịch "$title" chưa có thông tin về số tiền quyên góp.';
    }

    return 'Chiến dịch "$title" đã nhận được ${amount.toStringAsFixed(0)} VND tiền quyên góp.';
  }

  static Future<String> _getDonationSummary(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final amount = data?['amount'];
      if (amount != null && amount is num) total += amount.toDouble();
    }

    return 'Tổng số tiền bạn đã quyên góp là: ${total.toStringAsFixed(0)} VND.';
  }

  // --- HÀM TÌM KIẾM CHIẾN DỊCH CẢI TIẾN VỚI FUZZY MATCHING ---
  static Future<DocumentSnapshot?> _findCampaignByTitle(String question) async {
    final inputTitle = _extractCampaignTitle(question);
    if (inputTitle == null || inputTitle.isEmpty) return null;

    // Chuẩn hóa inputTitle để so sánh
    final inputNormalized = removeDiacritics(inputTitle.toLowerCase());

    final snapshot = await FirebaseFirestore.instance
        .collection('featured_activities')
        .get();

    DocumentSnapshot? bestMatchDoc;
    double bestSimilarity = 0.0;
    const double similarityThreshold = 0.7; // Ngưỡng chấp nhận độ tương đồng

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>?;
      final title = data?['title']?.toString() ?? '';
      if (title.isEmpty) continue; // Bỏ qua nếu tiêu đề rỗng

      final titleNormalized = removeDiacritics(title.toLowerCase());

      // Tính toán độ tương đồng giữa input của người dùng và tiêu đề chiến dịch
      final similarity = inputNormalized.similarityTo(titleNormalized);

      // Nếu độ tương đồng cao hơn kết quả tốt nhất hiện tại và vượt ngưỡng
      if (similarity > bestSimilarity && similarity >= similarityThreshold) {
        bestSimilarity = similarity;
        bestMatchDoc = doc;
      }
    }
    return bestMatchDoc;
  }

  // TÁCH TÊN CHIẾN DỊCH RA KHỎI CÂU HỎI
  static String? _extractCampaignTitle(String question) {

    final stopKeywords = [
      'khi nào', 'ở đâu', 'địa chỉ', 'người tạo',
      'tình trạng', 'số lượng', '?', '!', 'là',
      'bao nhiêu', 'là bao nhiêu', 'có bao nhiêu', 'được bao nhiêu',
      'tham gia', 'chi tiết', 'ai tạo', 'thời gian', 'tối đa', 'tài khoản', 'ngân hàng',
      'tiền quyên góp', 'bao nhiêu tiền', 'muc tieu',
    ].map((e) => removeDiacritics(e.toLowerCase())).toList();

    final startRegex = RegExp(r"chiến dịch\s+", caseSensitive: false);
    final startMatch = startRegex.firstMatch(question);

    int startIndex = 0; // Mặc định bắt đầu từ đầu câu
    if (startMatch != null) {
      startIndex = startMatch.end;
    } else {
      String cleanedQuestion = question;
      for (final keyword in stopKeywords) {
        cleanedQuestion = cleanedQuestion.replaceAll(keyword, '');
      }
      return cleanedQuestion.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    String remaining = question.substring(startIndex);
    int? endIndex;
    for (final keyword in stopKeywords) {
      final index = remaining.indexOf(keyword);
      if (index != -1) {
        if (endIndex == null || index < endIndex) {
          endIndex = index;
        }
      }
    }

    String title;
    if (endIndex != null) {
      title = remaining.substring(0, endIndex).trim();
    } else {
      title = remaining.trim();
    }

    title = title.replaceAll(
      RegExp(r'[^\w\s]', unicode: true),
      '',
    );
    return title.trim();
  }

  static String _formatDate(DateTime date) {
    return '${_padZero(date.day)}/${_padZero(date.month)}/${date.year}';
  }

  static String _padZero(int number) {
    return number < 10 ? '0$number' : number.toString();
  }
}