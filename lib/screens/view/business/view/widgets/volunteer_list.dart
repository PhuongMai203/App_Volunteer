import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../chat/chatweb_socker/chat_screen.dart';
import '../../../user/widgets/avatar.dart';
import '../../utli/export_util.dart';

class VolunteerParticipantsList extends StatefulWidget {
  final String campaignId;
  final String currentUserId;
  const VolunteerParticipantsList({super.key, required this.campaignId, required this.currentUserId});

  @override
  State<VolunteerParticipantsList> createState() => _VolunteerParticipantsListState();
}

class _VolunteerParticipantsListState extends State<VolunteerParticipantsList> {
  final Set<String> _markedAttendanceIds = {};

  @override
  Widget build(BuildContext context) {
    final registrationsRef = FirebaseFirestore.instance.collection('campaign_registrations');

    return StreamBuilder<QuerySnapshot>(
      stream: registrationsRef
          .where('campaignId', isEqualTo: widget.campaignId)
          .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("loadParticipantsError".tr());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text("noParticipants".tr());
        }

        final totalParticipants = docs.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${"participants".tr()} ($totalParticipants)',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                ElevatedButton.icon(
                  onPressed: () => ExportUtil.exportVolunteerListToExcel(context, widget.campaignId),
                  icon: const Icon(Icons.download),
                  label: Text("exportExcel".tr()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final data = docs[index].data()! as Map<String, dynamic>;
                final name = data['name'] as String? ?? "noName".tr();
                final phone = data['phone'] as String? ?? "noPhone".tr();
                final userId = data['userId'] as String?;
                final registrationId = docs[index].id;
                final checkedStatus = data['attendanceStatus'] as String?;

                return FutureBuilder<DocumentSnapshot>(
                  future: userId != null
                      ? FirebaseFirestore.instance.collection('users').doc(userId).get()
                      : Future.value(null),
                  builder: (context, userSnapshot) {
                    String? avatarUrl;
                    if (userSnapshot.hasData && userSnapshot.data?.exists == true) {
                      // Lấy toàn bộ dữ liệu tài liệu người dùng
                      final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                      // Kiểm tra xem userData có null không và có chứa trường 'avatarUrl' không
                      if (userData != null && userData.containsKey('avatarUrl')) {
                        avatarUrl = userData['avatarUrl'] as String?;
                        // Nếu avatarUrl là null hoặc rỗng, đặt lại thành null để hiển thị placeholder
                        if (avatarUrl != null && avatarUrl.isEmpty) {
                          avatarUrl = null;
                        }
                      }
                    }

                    final showStatus = _markedAttendanceIds.contains(registrationId) || checkedStatus != null;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildPresentRadio(context, registrationId, checkedStatus),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                width: 52,
                                height: 52,
                                child: AvatarWithCrown(avatarUrl: avatarUrl),
                              ),
                              title: Text(name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(phone),
                                  if (showStatus)
                                    Text(
                                      checkedStatus == "present".tr()
                                          ? '${"attendance".tr()} ${"present".tr()}'
                                          : '${"attendance".tr()} ${"absent".tr()}',
                                      style: TextStyle(
                                        color: checkedStatus == "present".tr() ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.chat_bubble_outline),
                                tooltip: "chat".tr(),
                                onPressed: userId == null
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        userId: userId,
                                        receiverId: widget.currentUserId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPresentRadio(BuildContext context, String registrationId, String? currentStatus) {
    final isPresent = currentStatus == "present".tr();
    final isAbsent = currentStatus == "absent".tr();

    return GestureDetector(
      onTap: () {
        final newStatus = isPresent ? "absent".tr() : "present".tr();
        _markAttendance(context, registrationId, newStatus);
      },
      child: Icon(
        isPresent
            ? Icons.check_circle
            : isAbsent
            ? Icons.cancel
            : Icons.radio_button_unchecked,
        color: isPresent
            ? Colors.green
            : isAbsent
            ? Colors.red
            : Colors.grey,
        size: 30,
      ),
    );
  }

  void _markAttendance(BuildContext context, String registrationId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .doc(registrationId)
          .update({
        'attendanceStatus': status,
        'attendanceUpdatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _markedAttendanceIds.add(registrationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${"updateStatus".tr()} $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${"updateError".tr()} $e')),
      );
    }
  }
}