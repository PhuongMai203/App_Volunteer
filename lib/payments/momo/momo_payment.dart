import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_links/uni_links.dart';

class MomoPaymentPage extends StatefulWidget {
  final String campaignId;
  final String userId;
  final String userName;
  final String campaignTitle;
  const MomoPaymentPage({
    super.key,
    required this.campaignId,
    required this.userId,
    required this.userName,
    required this.campaignTitle,
  });

  @override
  State<MomoPaymentPage> createState() => _MomoPaymentPageState();
}

class _MomoPaymentPageState extends State<MomoPaymentPage> {
  bool _isLoading = false;
  String? _paymentMessage;
  final String _apiBaseUrl = 'https://9e86-2402-800-629f-adda-94e0-c62-c0e8-e11.ngrok-free.app';
  final TextEditingController _amountController = TextEditingController();

  String _status = "💳 Nhập số tiền để thanh toán Momo";
  bool _hasSavedPayment = false;
  StreamSubscription<Uri?>? _sub;
  final Set<String> _processedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _listenToDeepLink();
  }

  void _listenToDeepLink() {
    if (_sub != null) return;

    _sub = uriLinkStream.listen((Uri? uri) async {

      if (uri != null && uri.scheme == 'helpconnectmomo') {
        final orderId = uri.queryParameters['orderId'];
        if (orderId == null) return;

        if (_processedOrderIds.contains(orderId)) {
          debugPrint('OrderId $orderId đã xử lý rồi, bỏ qua.');
          return;
        }
        _processedOrderIds.add(orderId);

        await Future.delayed(const Duration(seconds: 2));
        final status = await checkOrderStatus(orderId);

        if (status != null && status['resultCode'] == 0) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('payments')
              .where('orderId', isEqualTo: orderId)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            final enteredAmount = int.tryParse(_amountController.text.trim()) ?? 0;
            debugPrint('Đang lưu dữ liệu payment lần đầu với amount = $enteredAmount');

            String? campaignCreatorId;
            String? campaignTitle;

            try {
              final doc = await FirebaseFirestore.instance
                  .collection('featured_activities')
                  .doc(widget.campaignId)
                  .get();
              if (doc.exists) {
                final data = doc.data()!;
                campaignCreatorId = data['userId'];
                campaignTitle = data['title'];
              }
            } catch (e) {
              debugPrint('❌ Lỗi lấy thông tin chiến dịch: $e');
            }

            await FirebaseFirestore.instance
                .collection('featured_activities')
                .doc(widget.campaignId)
                .update({
              'totalDonationAmount': FieldValue.increment(enteredAmount),
            });

            // await FirebaseFirestore.instance.collection('payments').add({
            //   'campaignId': widget.campaignId,
            //   'userId': widget.userId,
            //   'userName': widget.userName,
            //   'amount': enteredAmount,
            //   'paymentMethod': 'Momo',
            //   'createdAt': FieldValue.serverTimestamp(),
            //   'orderId': orderId,
            //   'campaignCreatorId': campaignCreatorId,
            //   'campaignTitle': campaignTitle,
            // });

            setState(() {
              _paymentMessage = '✅ Thanh toán thành công!';
              _isLoading = false;
            });
          } else {
            debugPrint('Đã lưu payment với orderId $orderId trước đó, không lưu lại nữa.');
            setState(() {
              _paymentMessage = '✅ Thanh toán đã được xác nhận trước đó.';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _paymentMessage = '❌ Thanh toán chưa hoàn tất';
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<String?> createMomoOrder({
    required String orderId,
    required int amount,
    required String orderInfo,
    required String campaignId,
    required String userId,
  }) async {
    final uri = Uri.parse('$_apiBaseUrl/payment');

    final body = jsonEncode({
      'orderId': orderId,
      'amount': amount.toString(),
      'orderInfo': orderInfo,
      'campaignId': campaignId,
      'userId': userId,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonRes = jsonDecode(response.body);
        return jsonRes['payUrl'];
      } else {
        debugPrint('❌ Lỗi tạo đơn hàng: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi tạo đơn hàng: $e');
      return null;
    }
  }

  Future<void> launchMomo(String payUrl) async {
    final uri = Uri.parse(payUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Không thể mở liên kết thanh toán MoMo.';
    }
  }

  Future<Map<String, dynamic>?> checkOrderStatus(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/check-status-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'orderId': orderId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? '';
        final resultCode = data['resultCode'];
        return {'resultCode': resultCode, 'message': message};
      } else {
        debugPrint('❌ Lỗi kiểm tra trạng thái đơn hàng: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Lỗi kiểm tra đơn hàng: $e');
      return null;
    }
  }

  Future<void> handlePayment() async {
    final enteredAmountText = _amountController.text.trim();
    if (enteredAmountText.isEmpty) {
      showSnackBar('Vui lòng nhập số tiền.');
      return;
    }

    final amount = int.tryParse(enteredAmountText);
    if (amount == null || amount <= 0) {
      showSnackBar('Số tiền không hợp lệ.');
      return;
    }

    setState(() {
      _isLoading = true;
      _paymentMessage = null;
    });

    String title = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('featured_activities')
          .doc(widget.campaignId)
          .get();
      if (doc.exists && doc.data()!.containsKey('title')) {
        title = doc.get('title');
      } else {
        title = 'chiến dịch';
      }
    } catch (e) {
      debugPrint('❌ Lỗi lấy campaign: $e');
      title = 'chiến dịch';
    }

    final orderId = '${widget.campaignId}_${DateTime.now().millisecondsSinceEpoch}';
    final orderInfo = 'ỦNG HỘ CHIẾN DỊCH $title';

    try {
      final payUrl = await createMomoOrder(
        orderId: orderId,
        amount: amount,
        orderInfo: orderInfo,
        campaignId: widget.campaignId,
        userId: widget.userId,
      );

      if (payUrl == null) {
        setState(() => _paymentMessage = 'Không tạo được liên kết thanh toán.');
        return;
      }

      await launchMomo(payUrl);

      setState(() {
        _paymentMessage = '🔄 Đang chờ xác nhận thanh toán từ MoMo...';
      });
    } catch (e) {
      setState(() => _paymentMessage = 'Lỗi khi xử lý thanh toán: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final momoPink = const Color(0xFFd82d8b);
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        backgroundColor: momoPink,
        title: const Text('Ủng hộ qua MoMo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Image.asset('assets/mm.png', width: 150, height: 150),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Nhập số tiền (VNĐ)',
                hintText: 'Ví dụ: 100000',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [20000, 50000, 100000, 200000].map((amount) {
                return ActionChip(
                  label: Text('$amount VNĐ'),
                  onPressed: () => setState(() {
                    _amountController.text = amount.toString();
                  }),
                  backgroundColor: Colors.pink.shade100,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Column(
              children: [
                CircularProgressIndicator(color: Color(0xFFd82d8b)),
                SizedBox(height: 16),
                Text('Đang xử lý thanh toán...', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            )
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: handlePayment,
                icon: const Icon(Icons.payment),
                label: const Text('Thanh toán với MoMo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: momoPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_paymentMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _paymentMessage!.contains('✅') ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _paymentMessage!.contains('✅') ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _paymentMessage!.contains('✅') ? Icons.check_circle : Icons.error,
                      color: _paymentMessage!.contains('✅') ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _paymentMessage!,
                        style: TextStyle(
                          color: _paymentMessage!.contains('✅') ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
