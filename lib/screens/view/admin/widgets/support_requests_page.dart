import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:intl/intl.dart';

class SupportRequestsPage extends StatefulWidget {
  final String? highlightRequestId;

  const SupportRequestsPage({Key? key, this.highlightRequestId}) : super(key: key);

  @override
  State<SupportRequestsPage> createState() => _SupportRequestsPageState();
}

class _SupportRequestsPageState extends State<SupportRequestsPage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Delay để đợi ListView render xong rồi mới cuộn
    Future.delayed(const Duration(milliseconds: 500), _scrollToHighlightedItem);
  }

  void _scrollToHighlightedItem() {
    if (widget.highlightRequestId == null) return;

    final key = _itemKeys[widget.highlightRequestId];
    if (key == null) return;

    final context = key.currentContext;
    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.2, // Đưa item lên khoảng 20% màn hình
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "list_support_requests".tr(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.sunrise,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("error".tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return Center(child: Text("no_support_requests".tr()));
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final id = doc.id;
              final name = data['name'] ?? 'Không rõ';
              final phone = data['phone'] ?? '';
              final address = data['address'] ?? '';
              final description = data['description'] ?? '';
              final createdAt = (data['createdAt'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

              final isHighlighted = id == widget.highlightRequestId;

              // Tạo và lưu GlobalKey cho từng item
              final key = _itemKeys.putIfAbsent(id, () => GlobalKey());

              return Container(
                key: key,
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(seconds: 2),
                  tween: ColorTween(
                    begin: isHighlighted ? Colors.blue.shade100 : Colors.transparent,
                    end: Colors.transparent,
                  ),
                  builder: (context, color, child) {
                    return Container(
                      color: color,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'support_request_from'.tr(namedArgs: {
                                  'name': name
                                }),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),
                              Text('📍 ${'address'.tr()} $address'),
                              const SizedBox(height: 4),
                              Text('📞 ${"phoneNumber".tr()} $phone'),
                              const SizedBox(height: 4),
                              Text('📝 ${"descriptions".tr()} $description'),
                              const SizedBox(height: 4),
                              Text('⏰ ${"time".tr()} $formattedDate'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
