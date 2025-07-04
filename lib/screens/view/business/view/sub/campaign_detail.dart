import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:activity_repository/activity_repository.dart'; // Đảm bảo import này đúng

import '../../controllers/campaign_edit_controller.dart';
import '../widgets/campaign_detail/activity_image.dart';
import '../widgets/campaign_detail/activity_info.dart';
import '../widgets/campaign_detail/campaign_detail_appbar.dart';
import '../widgets/campaign_detail/campaign_detail_section.dart';

class CampaignDetailBN extends StatefulWidget {
  final FeaturedActivity activity;

  const CampaignDetailBN({super.key, required this.activity});

  @override
  State<CampaignDetailBN> createState() => _CampaignDetailBNState();
}

class _CampaignDetailBNState extends State<CampaignDetailBN> {
  bool showDetails = false;
  bool isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final List<String> supportTypes = [
    "food".tr(), "cash".tr(), "medical".tr(), "education".tr(),
    "supplies".tr(), "shelter".tr(), "clothing".tr(), "other".tr()
  ];

  final List<String> urgencyLevels = [
    "urgencyLow".tr(), "urgencyMedium".tr(), "urgencyHigh".tr()
  ];

  final List<String> bankNames = [
    'Vietcombank', 'Techcombank', 'BIDV', 'VietinBank', 'Agribank', 'MB Bank',
    'Sacombank', 'ACB', 'VPBank', 'HDBank', 'SHB', 'TPBank', 'Eximbank',
    'LienVietPostBank', 'OCB', 'SCB', 'SeABank', 'Bac A Bank', 'DongA Bank',
    'Nam A Bank', 'ABBANK', 'PVcomBank', 'VIB', 'Viet Capital Bank',
    'SaigonBank', 'CBBank', 'GPBank', 'VietBank', 'OceanBank', 'BaoViet Bank',
    'KienlongBank', 'NCB', 'PG Bank', 'VRB', 'HSBC', 'Standard Chartered',
    'Shinhan Bank', 'CitiBank', 'ANZ', 'UOB', 'Woori Bank', 'Public Bank',
    'Hong Leong Bank', 'DBS Bank', 'BNP Paribas', 'Deutsche Bank', 'Bank of China'
  ];

  List<Map<String, dynamic>> categories = [
    {'icon': Icons.fastfood, 'title': 'hunger'.tr()},
    {'icon': Icons.child_friendly, 'title': 'children'.tr()},
    {'icon': Icons.elderly, 'title': 'elderly'.tr()},
    {'icon': Icons.money_off, 'title': 'poor'.tr()},
    {'icon': Icons.accessible, 'title': 'disabled'.tr()},
    {'icon': Icons.local_hospital, 'title': 'serious_illness'.tr()},
    {'icon': Icons.groups, 'title': 'ethnic_minority'.tr()},
    {'icon': Icons.business, 'title': 'migrant_workers'.tr()},
    {'icon': Icons.home, 'title': 'homeless'.tr()},
    {'icon': Icons.eco, 'title': 'environment'.tr()},
    {'icon': Icons.bar_chart, 'title': 'poverty_alleviation'.tr()},
    {'icon': Icons.warning, 'title': 'natural_disaster'.tr()},
    {'icon': Icons.school, 'title': 'education'.tr()},
  ];

  late TextEditingController _titleController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _supportTypeController;
  late TextEditingController _bankAccountController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxVolunteerCountController;
  late TextEditingController _dateControllerForEditableFields;

  String? selectedSupportType;
  String? selectedUrgency;
  String? selectedBankName;
  String? selectedCategory;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String currentUserId = '';
  late bool _isCurrentUserOwner;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;

    _titleController = TextEditingController(text: activity.title);
    _addressController = TextEditingController(text: activity.address);
    _phoneController = TextEditingController(text: activity.phoneNumber);
    _supportTypeController = TextEditingController(text: activity.supportType);
    _bankAccountController = TextEditingController(text: activity.bankAccount ?? '');
    _descriptionController = TextEditingController(text: activity.description);
    _maxVolunteerCountController = TextEditingController(text: activity.maxVolunteerCount.toString());

    selectedSupportType = activity.supportType.isNotEmpty ? activity.supportType : null;
    selectedUrgency = activity.urgency.isNotEmpty ? activity.urgency : null;
    selectedBankName = activity.bankName;
    selectedCategory = activity.category;
    selectedStartDate = activity.startDate;
    selectedEndDate = activity.endDate;

    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Sửa lỗi: So sánh với activity.userId thay vì activity.ownerId
    _isCurrentUserOwner = currentUserId == activity.userId; // <--- SỬA ĐỔI TẠI ĐÂY

    _dateControllerForEditableFields = TextEditingController(
      text: _formatDateRange(selectedStartDate, selectedEndDate),
    );
}

  @override
  void didUpdateWidget(covariant CampaignDetailBN oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newDateRange = _formatDateRange(selectedStartDate, selectedEndDate);
    if (_dateControllerForEditableFields.text != newDateRange) {
      _dateControllerForEditableFields.text = newDateRange;
    }
    // Sửa lỗi: Cập nhật quyền sở hữu nếu userId của activity thay đổi
    if (widget.activity.userId != oldWidget.activity.userId) { // <--- SỬA ĐỔI TẠI ĐÂY
      _isCurrentUserOwner = currentUserId == widget.activity.userId; // <--- SỬA ĐỔI TẠI ĐÂY

    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _supportTypeController.dispose();
    _bankAccountController.dispose();
    _descriptionController.dispose();
    _maxVolunteerCountController.dispose();
    _dateControllerForEditableFields.dispose();
    super.dispose();
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final DateTime endDate = end ?? start;
    final String startStr = DateFormat('dd/MM/yyyy').format(start);
    final String endStr = DateFormat('dd/MM/yyyy').format(endDate);
    return startStr == endStr ? startStr : '$startStr - $endStr';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: selectedStartDate ?? DateTime.now(),
        end: selectedEndDate ?? DateTime.now().add(const Duration(days: 7)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepOrange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepOrange),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = picked.start;
        selectedEndDate = picked.end;
      });
    }
  }

  Future<void> _deleteCampaign() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow.shade50,
          title: Text(tr("confirm_delete", ),
          style: TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500
          ),),
          content: Text(tr("delete_the_campaign")),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr("cancel"), style: TextStyle(
                color:Colors.green, fontSize: 16, fontWeight: FontWeight.w700
              ),),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Nền đỏ
                foregroundColor: Colors.white, // Màu chữ trắng
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr("delete")),
            ),

          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await CampaignEditController.deleteCampaign(docId: widget.activity.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr("delete_successful",), style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr("delete_failed")}: $e', style: TextStyle(
              color: Colors.white
            ),),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: CampaignDetailAppBar(
        title: activity.title,
        isEditing: isEditing,
        onEdit: () => setState(() => isEditing = true),
        onSave: () async {
          if (_formKey.currentState!.validate()) {
            final int updatedMaxCount = int.tryParse(_maxVolunteerCountController.text.trim()) ?? 0;
            final String updatedDescription = _descriptionController.text.trim();
            try {
              await CampaignEditController.updateCampaignInfo(
                docId: activity.id,
                title: _titleController.text.trim(),
                address: _addressController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
                supportType: selectedSupportType ?? '',
                urgency: selectedUrgency ?? '',
                bankName: selectedBankName ?? '',
                bankAccount: _bankAccountController.text.trim(),
                category: selectedCategory ?? '',
                startDate: selectedStartDate!,
                endDate: selectedEndDate!,
                maxVolunteerCount: updatedMaxCount,
                description: updatedDescription,
              );
              setState(() => isEditing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "update_successful".tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${"update_failed".tr()}$e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ActivityImage(imageUrl: activity.imageUrl),
            const SizedBox(height: 20),

            ActivityInfo(
              activity: activity,
              currentUserId: currentUserId,
              isEditing: isEditing,
              descriptionController: _descriptionController,
              maxVolunteerCountController: _maxVolunteerCountController,
              detailBuilder: () => _buildDetailSection(),
              endDate: selectedEndDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection() {
    return CampaignDetailSection(
      isEditing: isEditing,
      data: {
        'category': selectedCategory ?? widget.activity.category,
        'urgency': selectedUrgency ?? widget.activity.urgency,
        'address': _addressController.text,
        'phoneNumber': _phoneController.text,
        'supportType': selectedSupportType ?? widget.activity.supportType,
        'bankName': selectedBankName ?? widget.activity.bankName,
        'bankAccount': _bankAccountController.text,
      },
      supportTypes: supportTypes,
      urgencyLevels: urgencyLevels,
      bankNames: bankNames,
      categories: categories.map((e) => e['title'].toString()).toList(),
      selectedSupportType: selectedSupportType,
      selectedUrgency: selectedUrgency,
      selectedBankName: selectedBankName,
      selectedCategory: selectedCategory,
      onSupportTypeChanged: (val) => setState(() => selectedSupportType = val),
      onUrgencyChanged: (val) => setState(() => selectedUrgency = val),
      onBankNameChanged: (val) => setState(() => selectedBankName = val),
      onCategoryChanged: (val) => setState(() => selectedCategory = val),
      titleController: _titleController,
      addressController: _addressController,
      phoneController: _phoneController,
      supportTypeController: _supportTypeController,
      bankAccountController: _bankAccountController,
      descriptionController: _descriptionController,
      maxVolunteerCountController: _maxVolunteerCountController,
      dateRange: _formatDateRange(selectedStartDate, selectedEndDate),
      formKey: _formKey,
      startDate: selectedStartDate!,
      endDate: selectedEndDate!,
      onDateRangeChanged: (newStart, newEnd) {
        setState(() {
          selectedStartDate = newStart;
          selectedEndDate = newEnd;
        });
      },
      dateController: _dateControllerForEditableFields,
      onDeleteCampaign: _isCurrentUserOwner ? _deleteCampaign : null,
      isCurrentUserOwner: _isCurrentUserOwner,
    );
  }
}