import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatService {
  final WebSocketChannel channel;
  final String userId;

  ChatService(this.userId)
      : channel = IOWebSocketChannel.connect('ws://localhost:3000') {
    // Tham gia room riêng theo userId
    channel.sink.add(jsonEncode({'event': 'join', 'data': userId}));
  }

  /// Gửi tin nhắn đến một người dùng
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    final timestamp = DateTime.now();

    // Gửi qua WebSocket
    final msg = {
      'event': 'send_message',
      'data': {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      }
    };
    channel.sink.add(jsonEncode(msg));

    // Lưu vào Firestore
    FirebaseFirestore.instance.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'participants': [senderId, receiverId],
    });
  }

  /// Lấy lịch sử tin nhắn giữa hai người từ Firestore
  Stream<List<Map<String, dynamic>>> fetchChatHistory(String userA, String userB) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: userA)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .where((data) =>
      data['participants'].contains(userA) &&
          data['participants'].contains(userB))
          .cast<Map<String, dynamic>>()
          .toList();
    });
  }

  /// Lắng nghe tin nhắn mới qua WebSocket giữa 2 người
  Stream<Map<String, dynamic>> getLiveMessages(String userA, String userB) {
    return channel.stream
        .map((event) {
      final data = jsonDecode(event);
      if (data is Map<String, dynamic>) {
        final msg = data['data'];
        if (msg != null &&
            ((msg['senderId'] == userA && msg['receiverId'] == userB) ||
                (msg['senderId'] == userB && msg['receiverId'] == userA))) {
          return msg;
        }
      }
      return <String, dynamic>{};
    })
        .where((msg) => msg.isNotEmpty)
        .cast<Map<String, dynamic>>();
  }

  /// Đóng kết nối WebSocket
  void dispose() {
    channel.sink.close();
  }
}
