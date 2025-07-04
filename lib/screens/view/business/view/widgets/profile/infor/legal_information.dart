import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../components/app_colors.dart';

class LegalInformationTile extends StatefulWidget {
  const LegalInformationTile({super.key});

  @override
  State<LegalInformationTile> createState() => _LegalInformationTileState();
}

class _LegalInformationTileState extends State<LegalInformationTile> {
  Map<String, dynamic>? _legalInfo;
  bool _isLoading = false;

  Future<void> _fetchLegalInfo() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('businessVerifications')
          .where('userId', isEqualTo: uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _legalInfo = snapshot.docs.first.data();
      } else {
        _legalInfo = null;
      }
    } catch (e) {
      _legalInfo = null;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        "legal_info".tr(),
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onExpansionChanged: (expanded) {
        if (expanded && _legalInfo == null && !_isLoading) {
          _fetchLegalInfo();
        }
      },
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_legalInfo != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: "title".tr(),
                  children: [
                    _buildInfoRow("full_company_name".tr(), _legalInfo!['companyName']),
                    _buildInfoRow("tax_id".tr(), _legalInfo!['taxCode']),
                    _buildInfoRow("license".tr(), _legalInfo!['license']),
                    _buildInfoRow("head_office_address".tr(), _legalInfo!['address']),
                  ],
                ),
                _buildSection(
                  title: "legalRepresentative".tr(),
                  children: [
                    _buildInfoRow( "full_name".tr(), _legalInfo!['representativeName']),
                    _buildInfoRow("position".tr(), _legalInfo!['position']),
                    _buildInfoRow( "id_number".tr(), _legalInfo!['idNumber']),
                  ],
                ),
                _buildSection(
                  title: "bankInfo".tr(),
                  children: [
                    _buildInfoRow("bank_name".tr(), _legalInfo!['bankName']),
                    _buildInfoRow("bank_branch".tr(), _legalInfo!['branch']),
                    _buildInfoRow("account_number".tr(), _legalInfo!['accountNumber']),
                    _buildInfoRow("account_holder".tr(), _legalInfo!['accountHolder']),
                  ],
                ),
                _buildSection(
                  title: "attached_documents".tr(),
                  children: [
                    _buildImageItem(_legalInfo!['logoUrl'], "businessLogo".tr()),
                    _buildImageItem(_legalInfo!['stampUrl'], "companyStamp".tr()),
                    _buildImageItem(_legalInfo!['idCardFrontUrl'], "idCardFront".tr()),
                    _buildImageItem(_legalInfo!['idCardBackUrl'], "idCardBack".tr()),
                  ],
                ),
              ],
            ),
          )
        else
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("no_legal_info".tr()),
          ),
      ],
    );
  }

  Widget _buildImageItem(String? url, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/camera.svg', width: 18, color: AppColors.deepOcean),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepOcean,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.cotton,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.slateGrey.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url != null && url.isNotEmpty
                ? Stack(
              children: [
                Image.network(url, fit: BoxFit.cover, width: double.infinity),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.zoom_out_map, color: Colors.white, size: 18),
                  ),
                ),
              ],
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_back_rounded, color: AppColors.slateGrey, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    "no_images".tr(),
                    style: TextStyle(color: AppColors.slateGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slateGrey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              border: Border(
                bottom: BorderSide(color: AppColors.lavender.withOpacity(0.5), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.deepOcean, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepOcean,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.lavender.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: AppColors.deepOcean.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '---',
              style: TextStyle(color: AppColors.slateGrey, fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
