import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../admin/sub_pages/upcoming_sub/campaign_utils.dart';
import '../../../admin/sub_pages/upcoming_sub/widgets/volunteer_count_widget.dart';
import 'campaign_detail.dart';

class MyCampaignsBody extends StatefulWidget {
  final String searchQuery;
  final String selectedFilter;

  const MyCampaignsBody({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
  });

  @override
  State<MyCampaignsBody> createState() => _MyCampaignsBodyState();
}

class _MyCampaignsBodyState extends State<MyCampaignsBody> {
  final Map<String, TextEditingController> _volunteerControllers = {};

  @override
  void dispose() {
    for (var controller in _volunteerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getVolunteerController(String id, int count) {
    return _volunteerControllers.putIfAbsent(
        id, () => TextEditingController(text: count.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text("please_login_to_view_campaign".tr()));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
        final isAdmin = userData?['role'] == 'admin';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('featured_activities').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("notcreatedcampaigns".tr()));
            }

            var campaigns = snapshot.data!.docs;

            // Lọc chiến dịch chưa hết hạn
            campaigns = campaigns.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final endDate = data['endDate'] as Timestamp?;
              if (endDate == null) return false;
              final isFuture = endDate.toDate().isAfter(DateTime.now());
              return isAdmin ? isFuture : data['userId'] == currentUser.uid && isFuture;
            }).toList();

            // Lọc theo từ khóa
            if (widget.searchQuery.isNotEmpty) {
              campaigns = campaigns.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title']?.toString().toLowerCase() ?? '';
                return title.contains(widget.searchQuery.toLowerCase());
              }).toList();
            }

            // Sắp xếp theo filter
            if (widget.selectedFilter == 'A-Z') {
              campaigns.sort((a, b) =>
                  (a['title'] ?? '').toString().compareTo((b['title'] ?? '').toString()));
            } else if (widget.selectedFilter == 'expiring') {
              campaigns.sort((a, b) {
                final aDate = (a['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                final bDate = (b['endDate'] as Timestamp?)?.toDate() ?? DateTime.now();
                return aDate.compareTo(bDate);
              });
            }

            if (campaigns.isEmpty) {
              return Center(child: Text("no_campaigns_found".tr()));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                final doc = campaigns[index];
                final data = doc.data() as Map<String, dynamic>;
                final activity = FeaturedActivity.fromMap(data, doc.id);

                final imageUrl = data['imageUrl'] ?? '';
                final title = data['title'] ?? "untitledCampaign".tr();
                final description = data['description'] ?? '';
                final maxVolunteerCount = data['maxVolunteerCount'] ?? 0;

                final volunteerController = _getVolunteerController(doc.id, maxVolunteerCount);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampaignDetailBN(activity: activity),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.orange.shade50,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              imageUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  VolunteerCountWidget(
                                    campaignId: doc.id,
                                    isEditing: false,
                                    maxVolunteerCountController: volunteerController,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      CampaignUtils.formatDonation(activity.totalDonationAmount.toDouble() ?? 0.0),
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
