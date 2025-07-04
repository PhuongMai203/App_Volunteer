import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:intl/intl.dart';
import '../../user/components/custom_bottom_nav_bar.dart';
import '../../../../chat/chatweb_socker/chat_screen.dart';
import 'chatscreenBN.dart';

class ChatBn extends StatefulWidget {
  const ChatBn({super.key});

  @override
  State<ChatBn> createState() => _ChatBnState();
}

class _ChatBnState extends State<ChatBn> {
  String? userId;
  Map<String, Map<String, dynamic>> userCache = {}; // Cache thông tin user

  String getChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    if (userCache.containsKey(uid)) {
      return userCache[uid]!;
    } else {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      userCache[uid] = data;
      return data;
    }
  }

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }
  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.sunrise,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
          title: Text(
            "chat_title".tr(),
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
            ),
          ),),
        body:  Center(child: Text("chat_login_required".tr())),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26.0),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
        title: Text(
          "chat_title".tr(),
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh sách user chọn nhắn tin ngang
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("chat_select_user".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 100,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs.where((doc) => doc.id != userId).toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final data = user.data() as Map<String, dynamic>? ?? {};
                    final avatarUrl = data['avatarUrl'] as String? ?? '';
                    final name = data['name'] as String? ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatScreenBN(
                            userId: userId!,
                            receiverId: user.id,
                          ),
                        ));
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
                              radius: 30,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),

          // Danh sách cuộc trò chuyện gần đây
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("chat_recent_conversations".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Query theo chatId chứa userId
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('participants', arrayContains: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;
                Map<String, DocumentSnapshot> latestMessagesByChatId = {};

                for (var msg in messages) {
                  final data = msg.data() as Map<String, dynamic>? ?? {};

                  // Tạo chatId tạm thời từ sender và receiver (vì bạn không lưu sẵn chatId)
                  final sender = data['senderId'] as String? ?? '';
                  final receiver = data['receiverId'] as String? ?? '';
                  if (sender.isEmpty || receiver.isEmpty) continue;

                  final ids = [sender, receiver]..sort();
                  final chatId = ids.join('_');

                  final existingMsg = latestMessagesByChatId[chatId];
                  final currentTimestamp = data['timestamp'] as Timestamp?;

                  if (existingMsg == null ||
                      currentTimestamp != null &&
                          currentTimestamp.compareTo(existingMsg['timestamp']) > 0) {
                    latestMessagesByChatId[chatId] = msg;
                  }
                }

                final chatPreviews = latestMessagesByChatId.values.toList();


                if (chatPreviews.isEmpty) {
                  return Center(child: Text("chat_no_conversations".tr()));
                }

                return ListView.builder(
                  itemCount: chatPreviews.length,
                  itemBuilder: (context, index) {
                    final msg = chatPreviews[index];

                    final sender = msg['senderId'] as String;
                    final receiver = msg['receiverId'] as String;

                    final otherUserId = sender == userId ? receiver : sender;
                    final lastMessage = msg['message'] as String? ?? '';
                    final timestamp = msg['timestamp'] as Timestamp?;
                    final timeString = timestamp != null
                        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
                        : '';

                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(otherUserId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return ListTile(title: Text("chat_loading".tr()));
                        }
                        final userData = snapshot.data!;
                        final avatarUrl = userData['avatarUrl'] as String? ?? '';
                        final name = userData['name'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(lastMessage),
                            trailing: Text(
                              timeString,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  userId: userId!,
                                  receiverId: otherUserId,
                                ),
                              ));
                            },
                          ),
                        );

                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
