import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String? userId;
  Map<String, Map<String, dynamic>> userCache = {};

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

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

  Future<List<Map<String, dynamic>>> fetchUsersWithCommonCampaigns(String currentUserId) async {
    final registrations = await FirebaseFirestore.instance
        .collection('campaign_registrations')
        .where('userId', isEqualTo: currentUserId)
        .get();

    final campaignIds = registrations.docs
        .map((doc) => doc['campaignId'] as String?)
        .whereType<String>()
        .toSet();

    if (campaignIds.isEmpty) return [];

    final usersSet = <String>{};
    for (String campaignId in campaignIds) {
      final others = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      for (var doc in others.docs) {
        final uid = doc['userId'] as String?;
        if (uid != null && uid != currentUserId) {
          usersSet.add(uid);
        }
      }
    }

    final result = <Map<String, dynamic>>[];
    for (String uid in usersSet) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        result.add({'uid': uid, ...userDoc.data()!});
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchRecentChats(String currentUserId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .get();

    final seenChatIds = <String>{};
    final recentChats = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final participants = data['participants'] as List<dynamic>;
      if (participants.length != 2) continue;

      final otherUserId = participants.firstWhere((id) => id != currentUserId);
      final chatId = [currentUserId, otherUserId]..sort();
      final chatKey = chatId.join('_');

      if (seenChatIds.contains(chatKey)) continue;

      final userData = await getUserData(otherUserId);

      final List<dynamic> readBy = data['readBy'] ?? [];
      final bool isRead = readBy.contains(currentUserId);

      recentChats.add({
        'uid': otherUserId,
        'lastMessage': data['message'] ?? "no_content".tr(),
        'timestamp': data['timestamp'],
        'isRead': isRead,
        ...userData,
      });

      seenChatIds.add(chatKey);
    }

    return recentChats;
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        backgroundColor: AppColors.softBackground,
        appBar: AppBar(
          backgroundColor: AppColors.sunrise,
          automaticallyImplyLeading: false,
          title: Text(
            "chat_title".tr(),
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "chat_login_required".tr(),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sunrise,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text( "sign_in".tr(), style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppColors.sunrise),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("sign_up".tr(), style: TextStyle(color: AppColors.sunrise, fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      );

    }

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.sunrise,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text("chat_title".tr(),
            style: GoogleFonts.agbalumo(
              fontSize: 35,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("chat_select_user".tr(), style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 100,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchUsersWithCommonCampaigns(userId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final users = snapshot.data!;
                if (users.isEmpty) return Center(child: Text("there_no_users_campaign".tr()));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final data = users[index];
                    final uid = data['uid'];
                    final avatarUrl = data['avatarUrl'] ?? '';
                    final name = data['name'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ChatScreen(userId: userId!, receiverId: uid),
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
                            Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("chat_recent_conversations".tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchRecentChats(userId!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final chats = snapshot.data!;
                if (chats.isEmpty) return Center(child: Text("chat_no_conversations".tr()));

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final name = chat['name'] ?? "user".tr();
                    final avatarUrl = chat['avatarUrl'] ?? '';
                    final message = (chat['lastMessage'] as String?)?.trim();
                    final displayMessage = message != null && message.isNotEmpty ? message : "(Không có tin nhắn)";
                    final timestamp = chat['timestamp'] as Timestamp?;

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
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
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            subtitle: Text(
                              displayMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: chat['isRead'] == true ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),

                            trailing: timestamp != null
                                ? Text(
                              DateFormat('HH:mm dd/MM').format(timestamp.toDate()),
                              style: const TextStyle(fontSize: 12),
                            )
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(userId: userId!, receiverId: chat['uid']),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
