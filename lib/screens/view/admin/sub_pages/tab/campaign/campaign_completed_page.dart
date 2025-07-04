import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../components/app_colors.dart';
import '../../../../business/view/sub/campaign_detail.dart';
import '../../../../user/campaign/campaign_detail_screen.dart';

class CampaignCompletedPage extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;

  const CampaignCompletedPage({
    Key? key,
    this.searchQuery = '',
    this.selectedFilter = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nowUtc = DateTime.now().toUtc();
    final startOfTodayUtc = DateTime(nowUtc.year, nowUtc.month, nowUtc.day);
    final startOfTodayTs = Timestamp.fromDate(startOfTodayUtc);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('featured_activities')
            .where('endDate', isLessThan: startOfTodayTs)
            .orderBy('endDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            for (final doc in snapshot.data!.docs) {
              final endDate = (doc['endDate'] as Timestamp).toDate();

            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          final filtered = _filterDocuments(docs);
          return _buildCampaignList(filtered);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.deepOrange, size: 40),
          const SizedBox(height: 16),
          Text(
            "error_loading_data".tr(),
            style: TextStyle(
              color: AppColors.deepOcean,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today,
              color: AppColors.lavender.withOpacity(0.6), size: 64),
          const SizedBox(height: 16),
          Text(
            "no_ended_campaigns".tr(),
            style: TextStyle(
              color: AppColors.deepOcean,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "ended_campaigns_title".tr(),
            style: TextStyle(
              color: AppColors.slateGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterDocuments(List<QueryDocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String? ?? '').toLowerCase();
      final description = (data['description'] as String? ?? '').toLowerCase();
      final query = searchQuery.toLowerCase().trim();

      return query.isEmpty ||
          title.contains(query) ||
          description.contains(query);
    }).toList();
  }

  Widget _buildCampaignList(List<QueryDocumentSnapshot> filtered) {
    return ListView.builder(
      itemCount: filtered.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (ctx, index) {
        final doc = filtered[index];
        final data = doc.data() as Map<String, dynamic>;
        final id = doc.id;
        final title = data['title'] as String? ?? "no_title".tr();
        final description = data['description'] as String? ?? '';
        final imageUrl = data['imageUrl'] as String? ?? '';
        final urgency = data['urgency'] as String? ?? ''; // 👈 LẤY urgency
        final activity = FeaturedActivity.fromMap(data, doc.id);

        DateTime startDate;
        final rawStart = data['startDate'];
        if (rawStart is Timestamp) {
          startDate = rawStart.toDate();
        } else if (rawStart is DateTime) {
          startDate = rawStart;
        } else {
          startDate = DateTime.now();
        }

        DateTime endDate;
        final rawEnd = data['endDate'];
        if (rawEnd is Timestamp) {
          endDate = rawEnd.toDate();
        } else if (rawEnd is DateTime) {
          endDate = rawEnd;
        } else {
          endDate = DateTime.now();
        }

        return _buildCampaignCard(
          context: ctx,
          id: id,
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate,
          imageUrl: imageUrl,
          urgency: urgency,
          activity: activity,
        );
      },
    );
  }

  Widget _buildCampaignCard({
    required BuildContext context,
    required String id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String imageUrl,
    required String urgency,
    required FeaturedActivity activity,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepOcean.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(
            context,
            activity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageUrl.isNotEmpty) _buildCampaignImage(imageUrl),
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: imageUrl.isNotEmpty
                      ? const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  )
                      : BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.slateGrey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: AppColors.mint,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDate(startDate)} - ${_formatDate(endDate)}',
                            style: TextStyle(
                              color: AppColors.slateGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 180,
            color: AppColors.cotton,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.cumulativeBytesLoaded /
                    (progress.expectedTotalBytes ?? 1),
                color: AppColors.mint,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: AppColors.cotton,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: AppColors.slateGrey, size: 40),
              const SizedBox(height: 8),
              Text(
                "unable_to_load_image".tr(),
                style: TextStyle(color: AppColors.slateGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, FeaturedActivity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CampaignDetailBN(activity: activity),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
