import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../../../../components/app_colors.dart';
import 'campaign_detail_editable_fields.dart';
import 'campaign_detail_read_only_summary.dart';

class CampaignDetailSection extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic> data;

  final List<String> supportTypes;
  final List<String> urgencyLevels;
  final List<String> bankNames;
  final List<String> categories;

  final String? selectedSupportType;
  final String? selectedUrgency;
  final String? selectedBankName;
  final String? selectedCategory;
  final DateTime startDate;
  final DateTime endDate;
  final void Function(DateTime, DateTime)? onDateRangeChanged;

  final ValueChanged<String?>? onSupportTypeChanged;
  final ValueChanged<String?>? onUrgencyChanged;
  final ValueChanged<String?>? onBankNameChanged;
  final ValueChanged<String?>? onCategoryChanged;

  final TextEditingController titleController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController supportTypeController;
  final TextEditingController bankAccountController;
  final TextEditingController descriptionController;
  final TextEditingController maxVolunteerCountController;

  final String dateRange;

  final GlobalKey<FormState> formKey;

  final TextEditingController dateController;

  final VoidCallback? onDeleteCampaign;
  final bool isCurrentUserOwner;


  const CampaignDetailSection({
    super.key,
    required this.isEditing,
    required this.data,
    required this.supportTypes,
    required this.urgencyLevels,
    required this.bankNames,
    required this.categories,
    required this.selectedSupportType,
    required this.selectedUrgency,
    required this.selectedBankName,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    this.onDateRangeChanged,
    required this.onSupportTypeChanged,
    required this.onUrgencyChanged,
    required this.onBankNameChanged,
    required this.onCategoryChanged,
    required this.titleController,
    required this.addressController,
    required this.phoneController,
    required this.supportTypeController,
    required this.bankAccountController,
    required this.descriptionController,
    required this.maxVolunteerCountController,
    required this.dateRange,
    required this.formKey,
    required this.dateController,
    this.onDeleteCampaign,
    required this.isCurrentUserOwner,
  });

  @override
  State<CampaignDetailSection> createState() => _CampaignDetailSectionState();
}

class _CampaignDetailSectionState extends State<CampaignDetailSection> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CampaignDetailSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dateRange != oldWidget.dateRange) {
      widget.dateController.text = widget.dateRange;
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: widget.startDate, end: widget.endDate),
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
    if (picked != null && (picked.start != widget.startDate || picked.end != widget.endDate)) {
      widget.onDateRangeChanged?.call(picked.start, picked.end);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isEditing)
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: widget.formKey,
                child: CampaignDetailEditableFields(
                  key: const ValueKey('editableFields'),
                  titleController: widget.titleController,
                  addressController: widget.addressController,
                  phoneController: widget.phoneController,
                  supportTypeController: widget.supportTypeController,
                  bankAccountController: widget.bankAccountController,
                  selectedSupportType: widget.selectedSupportType,
                  selectedUrgency: widget.selectedUrgency,
                  selectedBankName: widget.selectedBankName,
                  selectedCategory: widget.selectedCategory,
                  supportTypes: widget.supportTypes,
                  urgencyLevels: widget.urgencyLevels,
                  bankNames: widget.bankNames,
                  categories: widget.categories,
                  onSupportTypeChanged: widget.onSupportTypeChanged,
                  onUrgencyChanged: widget.onUrgencyChanged,
                  onBankNameChanged: widget.onBankNameChanged,
                  onCategoryChanged: widget.onCategoryChanged,
                  dateRangeDisplay: widget.dateRange,
                  onSelectDateRange: () => _selectDateRange(context),
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                  dateController: widget.dateController,
                ),
              ),
            ),
          )
        else
          CampaignDetailReadOnlySummary(
            key: const ValueKey('readOnlySummary'),
            dateRange: widget.dateRange,
            data: widget.data,
            onDeleteCampaign: widget.onDeleteCampaign,
            isCurrentUserOwner: widget.isCurrentUserOwner, // Vẫn truyền đúng
          ),
      ],
    );
  }
}