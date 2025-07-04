import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../components/app_colors.dart';
import '../../../../../components/search_bar.dart';
import '../sub/campaign_list_completed.dart';
import '../widgets/nav_bar.dart';

class CompletedCampaigns extends StatefulWidget {
  const CompletedCampaigns({Key? key}) : super(key: key);

  @override
  State<CompletedCampaigns> createState() => _CompletedCampaignsState();
}

class _CompletedCampaignsState extends State<CompletedCampaigns> {
  String _selectedFilter = '';
  String _searchQuery = '';
  Set<String> _selectedCampaignIds = {};
  int _selectedIndex = 2;

  void _onNavBarTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/partner-home', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/my-campaigns');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/create-request_BN');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  Future<void> _deleteCampaign(String campaignId) async {
    try {
      await FirebaseFirestore.instance
          .collection('featured_activities')
          .doc(campaignId)
          .delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('delete_campaign_failed'.tr(namedArgs: {
              'error': e.toString()
            })),
          ),

        );
      }
    }
  }

  Future<void> _deleteSelected() async {
    for (var id in _selectedCampaignIds) {
      await _deleteCampaign(id);
    }
    setState(() {
      _selectedCampaignIds.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("campaign_deleted_successfully".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        iconTheme: const IconThemeData(color: Colors.white, size: 30.0),
        title: Text(
          "campaign_completed".tr(),
          style: GoogleFonts.poppins(
            fontSize: 23,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list_alt, color: AppColors.pureWhite, size: 28.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              _buildMenuItem('', Icons.clear_all, "filter_default".tr()),
              _buildMenuItem('A-Z', Icons.sort_by_alpha, 'A-Z'),
              _buildMenuItem('expiring', Icons.hourglass_bottom, "filter_expiring".tr()),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SearchBarWidget(
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),

              decoration: BoxDecoration(
                color: AppColors.softBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (_selectedCampaignIds.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedCampaignIds.length} ${ "selected_campaign".tr()}',
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _deleteSelected,
                          icon: const Icon(Icons.delete),
                          label: Text("delete".tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CampaignListCompleted(
                      onDelete: (String campaignId) async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.coralOrange, width: 2),
                            ),
                            title: Text(
                              "confirm".tr(),
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
                          await _deleteCampaign(campaignId);
                          setState(() {
                            _selectedCampaignIds.remove(campaignId);
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("campaign_deleted_successfully".tr())),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text) {
    final isSelected = _selectedFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.sunrise : Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.sunrise : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
