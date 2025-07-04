import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../../../components/app_colors.dart';
import '../../../../../../../components/search_bar.dart';
import '../../../../../../../service/activity_service.dart';
import '../../../sub/campaign_detail.dart';
import '../../campaign_complete/campaign_completed.dart';
import '../../campaign_complete/dismissible_campaign_item.dart';
import '../../campaign_filter_bar.dart';

class CampaignProfilePage extends StatefulWidget {
  const CampaignProfilePage({Key? key}) : super(key: key);

  @override
  State<CampaignProfilePage> createState() => _CampaignProfilePageState();
}

class _CampaignProfilePageState extends State<CampaignProfilePage> {
  late final User? currentUser;
  String _selectedFilter = '';
  String _searchQuery = '';

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
    });
  }

  void _onSearchChanged(String newSearch) {
    setState(() {
      _searchQuery = newSearch;
    });
  }
  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  int _calculateDaysLeft(Timestamp endDate) {
    final now = DateTime.now();
    final end = endDate.toDate();
    return end.difference(now).inDays;
  }

  Future<int> _calculateTotalAmount(String campaignId) async {
    final query = await FirebaseFirestore.instance
        .collection('payments')
        .where('campaignId', isEqualTo: campaignId)
        .get();

    int totalAmount = 0;
    for (var doc in query.docs) {
      final data = doc.data();
      final amount = data['amount'];
      if (amount is int) {
        totalAmount += amount;
      } else if (amount is String) {
        totalAmount += int.tryParse(amount) ?? 0;
      }
    }
    return totalAmount;
  }

  Future<int> _calculateVolunteerCount(String campaignId) async {
    try {
      final countSnap = await FirebaseFirestore.instance
          .collection('campaign_registrations')
          .where('campaignId', isEqualTo: campaignId)
          .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
          .count()
          .get();

      int count = countSnap.count ?? -1;

      if (count < 0) {
        final fallbackSnap = await FirebaseFirestore.instance
            .collection('campaign_registrations')
            .where('campaignId', isEqualTo: campaignId)
            .where('participationTypes', arrayContains: 'Tham gia tình nguyện trực tiếp')
            .get();
        count = fallbackSnap.docs.length;
      }
      return count;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _deleteCampaign(String campaignId) async {
    await FirebaseFirestore.instance
        .collection('featured_activities')
        .doc(campaignId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> _fetchCampaigns() async {
    if (currentUser == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('featured_activities')
        .where('userId', isEqualTo: currentUser!.uid)
        .get();

    final campaignDocs = snapshot.docs;

    final List<Map<String, dynamic>> campaigns = await Future.wait(
      campaignDocs.map((doc) async {
        final data = doc.data();
        final campaignId = doc.id;

        final totalAmount = await _calculateTotalAmount(campaignId);
        final maxVolunteerCount = (data['maxVolunteerCount'] is int && data['maxVolunteerCount'] > 0)
            ? data['maxVolunteerCount']
            : 1;

        final volunteerCount = await _calculateVolunteerCount(campaignId);

        final progress = volunteerCount / maxVolunteerCount;
        final currencyFormatter = NumberFormat("#,##0", "vi_VN");

        return {
          'title': data['title'] ?? "untitledCampaign".tr(),
          'daysLeft': _calculateDaysLeft(data['endDate']),
          'campaignId': campaignId,
          'progress': progress.clamp(0.0, 1.0),
          'target': '${currencyFormatter.format(totalAmount)}₫',
          'volunteerCount': volunteerCount,
          'maxVolunteerCount': maxVolunteerCount,
          'progressPercent': (progress * 100).toStringAsFixed(0),
          'rawData': data,
        };
      }),
    );

    return campaigns;
  }
  Future<List<FeaturedActivity>> getActivities() async {
    final allActivities = await ActivityService.fetchActivities(
      searchQuery: _searchQuery,
      selectedFilter: _selectedFilter,
    );
    final now = DateTime.now();

    return allActivities.where((activity) {
      return activity.endDate.isAfter(now);
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
        title: Text(
          "my_campaign".tr(),
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),
        actions: [
          CampaignFilterBar(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SearchBarWidget(
            onSearchChanged: _onSearchChanged,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchCampaigns(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      '${"no_campaigns".tr()}\nUID: ${currentUser!.uid}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final campaigns = snapshot.data!;
                return ListView.builder(
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    final data = campaign['rawData'] as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DismissibleCampaignItem(
                        key: Key(campaign['campaignId']),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.coralOrange, width: 2),
                              ),
                              title: Text(
                                "confirm_delete".tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              content: Text(
                                "delete_this_campaign".tr(),
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text(
                                    "cancel".tr(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: Text(
                                    "delete".tr(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _deleteCampaign(campaign['campaignId']);
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("campaign_deleted_successfully".tr())),
                            );

                            setState(() {}); // reload lại danh sách
                          }
                        },
                        child: CampaignCompleted(
                          campaign: campaign,
                          onTap: () {
                            final activity = FeaturedActivity.fromMap(data, campaign['campaignId']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CampaignDetailBN(activity: activity),
                              ),
                            );
                          },
                        ),
                      ),
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
