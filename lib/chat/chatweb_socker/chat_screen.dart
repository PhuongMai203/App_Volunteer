import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../components/app_colors.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;

  const ChatScreen({required this.userId, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String receiverName = 'Đang tải...';
  bool hasConnection = true;
  bool receiverExists = true;
  bool isSendingFailed = false;

  late StreamSubscription connectivitySub;
  late StreamSubscription authSub;

  @override
  void initState() {
    super.initState();
    chatService = ChatService(widget.userId);

    // Lấy lịch sử tin nhắn
    chatService.fetchChatHistory(widget.userId, widget.receiverId).listen((history) {
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
      _scrollToBottom();
    });

    // Nhận tin nhắn mới
    chatService.getLiveMessages(widget.userId, widget.receiverId).listen((newMessage) {
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    });

    // Theo dõi Internet
    connectivitySub = Connectivity().onConnectivityChanged.listen((status) {
      final connected = status != ConnectivityResult.none;
      if (!connected && hasConnection != false) {
        setState(() {
          hasConnection = false;
        });
        _showSnackbar("Không có kết nối Internet. Vui lòng kiểm tra và thử lại.");
      } else if (connected && hasConnection != true) {
        setState(() {
          hasConnection = true;
          isSendingFailed = false;
        });
      }
    });

    // Theo dõi đăng xuất
    authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        chatService.dispose();
        Navigator.of(context).popUntil((route) => route.isFirst);
        _showSnackbar("Bạn đã đăng xuất. Vui lòng đăng nhập lại.");
      }
    });

    _loadReceiverName();
  }

  Future<void> _loadReceiverName() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .get();

    if (!snapshot.exists && mounted) {
      setState(() {
        receiverExists = false;
        receiverName = "Người nhận không còn hoạt động";
      });
      _showSnackbar("Người nhận không còn hoạt động trên hệ thống.");
    } else if (mounted) {
      setState(() {
        receiverExists = true;
        receiverName = snapshot.data()?['name'] ?? 'Không rõ tên';
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || !hasConnection || !receiverExists) return;

    final message = {
      'senderId': widget.userId,
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'sending',
    };

    setState(() {
      _messages.add(message);
      _controller.clear();
    });

    _scrollToBottom();

    try {
      await chatService.sendMessage(widget.userId, widget.receiverId, text);
      setState(() {
        message['status'] = 'sent';
      });
    } catch (e) {
      setState(() {
        message['status'] = 'failed';
        isSendingFailed = true;
      });
      _showSnackbar("Gửi tin nhắn thất bại. Vui lòng thử lại.");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(dynamic timestamp) {
    DateTime? dt;

    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is String) {
      dt = DateTime.tryParse(timestamp);
    }

    if (dt == null) return "";
    final time = TimeOfDay.fromDateTime(dt);
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    connectivitySub.cancel();
    authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        title: Text(receiverName, style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.coralOrange,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[_messages.length - index - 1];
                bool isMe = msg['senderId'] == widget.userId;
                bool isFailed = msg['status'] == 'failed';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.pastelOrange : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['message'],
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontStyle: isFailed ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(msg['timestamp'] ?? ''),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            if (isFailed) ...[
                              SizedBox(width: 6),
                              Icon(Icons.error_outline, color: Colors.red, size: 16),
                            ]
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.softBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.coralOrange.withOpacity(0.4)),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: hasConnection && receiverExists,
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: (hasConnection && receiverExists)
                      ? AppColors.coralOrange
                      : Colors.grey,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed:
                    (!hasConnection || !receiverExists) ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
