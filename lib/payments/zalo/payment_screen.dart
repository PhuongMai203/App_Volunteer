// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/app_gradients.dart';

class ZaloPayPaymentScreen extends StatefulWidget {
  final String campaignId;
  final String userId; // Người thanh toán
  final String userName;
  final String campaignTitle;

  const ZaloPayPaymentScreen({
    super.key,
    required this.campaignId,
    required this.userId,
    required this.userName,
    required this.campaignTitle,
  });

  @override
  State<ZaloPayPaymentScreen> createState() => _ZaloPayPaymentScreenState();
}

class _ZaloPayPaymentScreenState extends State<ZaloPayPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  StreamSubscription? _sub;
  String _status = "💳 Nhập số tiền để thanh toán qua ZaloPay";
  String? _paymentStatus;
  String? _transId;

  @override
  void initState() {
    super.initState();
    _restoreLastTransaction();
    _listenToDeeplink();
  }

  Future<void> _restoreLastTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    _transId = prefs.getString('last_trans_id');
  }

  void _listenToDeeplink() {
    _sub = uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == "helpconnectmomo") {
        final prefs = await SharedPreferences.getInstance();
        _transId = prefs.getString('last_trans_id');
        if (_transId != null) {
          _checkOrderStatus();
        } else {
          setState(() {
            _paymentStatus = "⚠️ Không có thông tin giao dịch để kiểm tra trạng thái.";
          });
        }
      }
    }, onError: (err) {
      print("Lỗi deeplink: $err");
    });
  }

  Future<void> resetTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_trans_id');
    await prefs.remove('last_trans_created_at');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  //  Hàm lấy campaignCreatorId từ Firestore
  Future<String?> _getCampaignCreatorId(String campaignId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('featured_activities')
          .doc(campaignId)
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['userId'] as String?;
      }
    } catch (e) {
      print('Lỗi lấy campaignCreatorId: $e');
    }
    return null;
  }

  // Lưu thông tin thanh toán lên Firestore
  Future<void> _savePaymentToFirestore({
    required int amount,
    required String appTransId,
  }) async {
    try {
      final campaignCreatorId = await _getCampaignCreatorId(widget.campaignId);
      if (campaignCreatorId == null) {
        print('Không tìm thấy campaignCreatorId');
        return;
      }

      // await FirebaseFirestore.instance.collection('payments').add({
      //   'campaignId': widget.campaignId,
      //   'campaignTitle': widget.campaignTitle,
      //   'campaignCreatorId': campaignCreatorId, // Người tạo chiến dịch
      //   'userId': widget.userId,                // Người thanh toán
      //   'userName': widget.userName,
      //   'amount': amount,
      //   'app_trans_id': appTransId,
      //   'paymentMethod': 'ZaloPay',
      //   'status': 'success',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });
    } catch (e) {
      print('Lỗi lưu dữ liệu thanh toán lên Firestore: $e');
    }
  }

  String generateAppTransId() {
    final now = DateTime.now();
    final formattedDate = '${(now.year % 100).toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final randomPart = now.millisecondsSinceEpoch % 1000000;
    return '${formattedDate}_$randomPart';
  }

  Future<void> _createOrder() async {
    final url = 'https://de2d-2402-800-629f-adda-94e0-c62-c0e8-e11.ngrok-free.app/payment';
    final appTransId = generateAppTransId();
    final amount = int.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      setState(() {
        _paymentStatus = "⚠️ Vui lòng nhập số tiền hợp lệ.";
      });
      return;
    }

    final body = {
      'app_trans_id': appTransId,
      'app_user': widget.userId,
      'amount': amount,
      'campaign_id': widget.campaignId,
      'callback_url': Uri.encodeFull('helpconnectmomo://callback?app_trans_id=$appTransId'),
      'description': 'Thanh toán đơn #$appTransId cho chiến dịch ${widget.campaignId}',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final orderUrl = json['order_url'];
        _transId = appTransId;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_trans_id', _transId!);
        await prefs.setInt('last_trans_created_at', DateTime.now().millisecondsSinceEpoch);

        if (await canLaunchUrl(Uri.parse(orderUrl))) {
          await launchUrl(Uri.parse(orderUrl), mode: LaunchMode.externalApplication);
        } else {
          throw 'Không thể mở liên kết $orderUrl';
        }
      } else {
        throw 'Máy chủ trả về lỗi ${response.statusCode}';
      }
    } catch (e) {
      print("Lỗi tạo đơn hàng: $e");
      setState(() {
        _paymentStatus = "⚠️ Tạo đơn hàng thất bại.";
      });
    }
  }

  Future<void> _checkOrderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final createdAtMillis = prefs.getInt('last_trans_created_at') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final twoMonthsMillis = 60 * 24 * 60 * 60 * 1000;

    if (_transId == null || createdAtMillis == 0) {
      setState(() {
        _paymentStatus = "⚠️ Không có mã giao dịch để kiểm tra.";
      });
      return;
    }

    if (now - createdAtMillis > twoMonthsMillis) {
      setState(() {
        _paymentStatus = "⚠️ Đơn hàng đã quá 2 tháng, không thể kiểm tra trạng thái.";
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://4638-171-234-11-139.ngrok-free.app/check-status-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'app_trans_id': _transId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final code = data['return_code'];
        String msg;

        if (code == 1) {
          msg = "✅ Thanh toán thành công!";
          await _savePaymentToFirestore(
            amount: int.parse(_amountController.text),
            appTransId: _transId!,
          );
        } else if (code == 2) {
          msg = "❌ Thanh toán thất bại.";
        } else {
          msg = "⌛ Giao dịch đang xử lý hoặc chưa thực hiện.";
        }

        setState(() {
          _paymentStatus = msg;
        });
      } else {
        throw 'Mã lỗi HTTP: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _paymentStatus = "❌ Lỗi kiểm tra trạng thái: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
      decoration: const BoxDecoration(
      gradient: AppGradients.peachPinkToOrange,
    ),
    child: Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Ủng hộ qua ZaloPay', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Image.asset('assets/zlp.png', width: 100, height: 100),
                    const SizedBox(height: 20),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nhập số tiền (VNĐ)',
                      border: OutlineInputBorder(borderRadius: borderRadius),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [20000, 50000, 100000, 200000].map((amt) {
                      return ActionChip(
                        label: Text('$amt VNĐ'),
                        onPressed: () => setState(() {
                          _amountController.text = amt.toString();
                        }),
                        backgroundColor: Colors.pink.shade50,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _createOrder,
                    icon: const Icon(Icons.payment, color: Colors.white),
                    label: const Text('Thanh toán ZaloPay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _checkOrderStatus,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Kiểm tra trạng thái đơn hàng'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    ),
                  ),
                  if (_paymentStatus != null) ...[
                    const SizedBox(height: 24),
                    Text(_paymentStatus!, style: const TextStyle(fontSize: 16)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      ),
    );
  }
}
