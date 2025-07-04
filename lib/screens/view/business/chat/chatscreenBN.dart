import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../chat/chatweb_socker/chat_service.dart';
import '../../../../components/app_colors.dart';

class ChatScreenBN extends StatefulWidget {
  final String userId;
  final String receiverId;

  const ChatScreenBN({required this.userId, required this.receiverId});

  @override
  _ChatScreenBNState createState() => _ChatScreenBNState();
}

class _ChatScreenBNState extends State<ChatScreenBN> {
  late ChatService chatService;
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String receiverName = "chat_loading".tr();



  @override
  void initState() {
    super.initState();
    chatService = ChatService(widget.userId);

    // Lấy tin nhắn lịch sử từ Firestore
    chatService.fetchChatHistory(widget.userId, widget.receiverId).listen((history) {
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
      _scrollToBottom();
    });

    // Nghe tin nhắn mới từ WebSocket
    chatService.getLiveMessages(widget.userId, widget.receiverId).listen((newMessage) {
      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    });

    _loadReceiverName();
  }


  Future<void> _loadReceiverName() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .get();

    if (snapshot.exists && mounted) {
      setState(() {
        receiverName = snapshot.data()?['name'] ?? 'Không rõ tên';
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      chatService.sendMessage(widget.userId, widget.receiverId, text);
      setState(() {
        _messages.add({
          'senderId': widget.userId,
          'message': text,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
      _scrollToBottom();
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
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _formatTime(msg['timestamp'] ?? ''),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                      decoration: InputDecoration(
                        hintText: "enter_message".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.coralOrange,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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
