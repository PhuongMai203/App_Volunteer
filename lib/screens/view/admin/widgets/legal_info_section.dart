import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../components/app_colors.dart';
class LegalInfoSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const LegalInfoSection({
    Key? key,
    required this.data,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

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
                bottom: BorderSide(
                    color: AppColors.lavender.withOpacity(0.5),
                    width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.deepOcean,
                    size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepOcean,
                      letterSpacing: 0.5),
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
          bottom: BorderSide(
              color: AppColors.lavender.withOpacity(0.3),
              width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                  color: AppColors.deepOcean.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '---',
              style: TextStyle(
                  color: AppColors.slateGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
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
              SvgPicture.asset('assets/icons/camera.svg',
                  width: 18,
                  color: AppColors.deepOcean),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepOcean),
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
                  offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: url != null && url.isNotEmpty
                ? Stack(
              children: [
                Image.network(url,
                    fit: BoxFit.cover,
                    width: double.infinity),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.zoom_out_map,
                        color: Colors.white,
                        size: 18),
                  ),
                ),
              ],
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_camera_back_rounded,
                      color: AppColors.slateGrey, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    "no_images".tr(),
                    style: TextStyle(
                        color: AppColors.slateGrey,
                        fontSize: 12),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.mint,
              child: InkWell(
                onTap: onApprove,
                borderRadius: BorderRadius.circular(10),
                hoverColor: AppColors.mint.withOpacity(0.8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "approve".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Material(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.deepOrange,
              child: InkWell(
                onTap: onReject,
                borderRadius: BorderRadius.circular(10),
                hoverColor: AppColors.deepOrange.withOpacity(0.8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "reject".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.pureWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text("no_legal_info".tr(),
            style: TextStyle(
                color: AppColors.slateGrey,
                fontSize: 16)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSection(
            title: "title".tr(),
            children: [
              _buildInfoRow("full_company_name".tr(), data['companyName']),
              _buildInfoRow( "tax_id".tr(), data['taxCode']),
              _buildInfoRow("license".tr(), data['license']),
              _buildInfoRow("head_office_address".tr(), data['address']),
            ],
          ),

          _buildSection(
            title: "legalRepresentative".tr(),
            children: [
              _buildInfoRow("full_name".tr(), data['representativeName']),
              _buildInfoRow("position".tr(), data['position']),
              _buildInfoRow("id_number".tr(), data['idNumber']),
            ],
          ),

          _buildSection(
            title: "bankInfo".tr(),
            children: [
              _buildInfoRow("bank_name".tr(), data['bankName']),
              _buildInfoRow("bank_branch".tr(), data['branch']),
              _buildInfoRow("account_number".tr(), data['accountNumber']),
              _buildInfoRow("account_holder".tr(), data['accountHolder']),
            ],
          ),

          _buildSection(
            title: "attached_documents".tr(),
            children: [
              _buildImageItem(data['logoUrl'], "businessLogo".tr()),
              _buildImageItem(data['stampUrl'],"companyStamp".tr()),
              _buildImageItem(data['idCardFrontUrl'], "idCardFront".tr()),
              _buildImageItem(data['idCardBackUrl'], "idCardBack".tr()),
            ],
          ),

          if (data['status'] == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: _buildActionButtons(),
            ),
        ],
      ),
    );
  }
}