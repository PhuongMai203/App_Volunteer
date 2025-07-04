import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_connect/components/app_colors.dart';
import '../../components/app_gradients.dart';
import 'gemini_api.dart';

class ChatBotPage extends StatefulWidget {
  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      _sessionId = _user!.uid;
    } else {
      _sessionId = 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
    }

    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final querySnapshot = await _firestore
        .collection('chat_sessions')
        .doc(_sessionId)
        .collection('messages')
        .orderBy('time', descending: false)
        .get();

    final loadedMessages = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'role': data['role'] as String,
        'text': data['text'] as String,
        'time': (data['time'] as Timestamp).toDate(),
      };
    }).toList();

    setState(() {
      _messages.clear();
      _messages.addAll(loadedMessages);
    });
  }

  Future<void> _saveMessageToFirestore(
      String role, String text, DateTime time) async {
    if (_sessionId == null) return;
    await _firestore
        .collection('chat_sessions')
        .doc(_sessionId)
        .collection('messages')
        .add({
      'role': role,
      'text': text,
      'time': Timestamp.fromDate(time),
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();

    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': now});
      _controller.clear();
    });

    await _saveMessageToFirestore('user', text, now);

    final reply = await sendMessageToGemini(text, _sessionId!);

    final replyTime = DateTime.now();

    setState(() {
      _messages.add({'role': 'bot', 'text': reply, 'time': replyTime});
    });

    await _saveMessageToFirestore('bot', reply, replyTime);
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
        statusBarColor: Colors.grey,
        statusBarIconBrightness: Brightness.dark,
    ),
    child: SafeArea(
    child: Container(
    decoration: const BoxDecoration(
    gradient: AppGradients.peachPinkToOrange,
    ),
    child: Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.coralOrange,
        title: Text(
          "🤖 Trợ lý ảo",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white, size: 26.0),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final time = msg['time'] as DateTime;
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color:
                      isUser ? AppColors.pastelOrange : AppColors.notifi,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                              fontSize: 15, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatDateTime(time),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung...',
                      filled: true,
                      fillColor: AppColors.softBackground,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
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
      ),
      ),
      ),
    );
  }
}
