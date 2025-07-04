import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';

import 'campaign/campaign_profile.dart';

class CampaignCountCard extends StatefulWidget {
  const CampaignCountCard({super.key});

  @override
  State<CampaignCountCard> createState() => _CampaignCountCardState();
}

class _CampaignCountCardState extends State<CampaignCountCard> {
  int _campaignCount = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCampaignCount();
  }

  Future<void> _loadCampaignCount() async {
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('featured_activities')
          .where('userId', isEqualTo: user!.uid)
          .get();

      setState(() {
        _campaignCount = snapshot.docs.length;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CampaignProfilePage()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sunrise.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign, color: AppColors.sunrise, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "total_number_of_campaigns_created".tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$_campaignCount',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sunrise,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
