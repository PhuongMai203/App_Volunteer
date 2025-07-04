import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../components/app_colors.dart';

class CampaignDetailEditableFields extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController supportTypeController; // Có thể không cần nếu dùng Dropdown
  final TextEditingController bankAccountController;
  final String? selectedSupportType;
  final String? selectedUrgency;
  final String? selectedBankName;
  final String? selectedCategory;
  final List<String> supportTypes;
  final List<String> urgencyLevels;
  final List<String> bankNames;
  final List<String> categories;
  final ValueChanged<String?>? onSupportTypeChanged;
  final ValueChanged<String?>? onUrgencyChanged;
  final ValueChanged<String?>? onBankNameChanged;
  final ValueChanged<String?>? onCategoryChanged;
  final String dateRangeDisplay; // Để hiển thị ngày tháng
  final Function() onSelectDateRange; // Callback khi click vào trường ngày tháng
  final DateTime startDate; // Thêm startDate
  final DateTime endDate;   // Thêm endDate
  final TextEditingController dateController; // Thêm dateController để điều khiển trường ngày tháng

  const CampaignDetailEditableFields({
    super.key,
    required this.titleController,
    required this.addressController,
    required this.phoneController,
    required this.supportTypeController,
    required this.bankAccountController,
    required this.selectedSupportType,
    required this.selectedUrgency,
    required this.selectedBankName,
    required this.selectedCategory,
    required this.supportTypes,
    required this.urgencyLevels,
    required this.bankNames,
    required this.categories,
    required this.onSupportTypeChanged,
    required this.onUrgencyChanged,
    required this.onBankNameChanged,
    required this.onCategoryChanged,
    required this.dateRangeDisplay,
    required this.onSelectDateRange,
    required this.startDate, // Yêu cầu startDate
    required this.endDate,   // Yêu cầu endDate
    required this.dateController, // Yêu cầu dateController
  });

  @override
  State<CampaignDetailEditableFields> createState() => _CampaignDetailEditableFieldsState();
}

class _CampaignDetailEditableFieldsState extends State<CampaignDetailEditableFields> {
  // Biến cho Slider, được khởi tạo dựa trên selectedUrgency
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    // Khởi tạo _currentSliderValue dựa trên selectedUrgency ban đầu
    _currentSliderValue = widget.selectedUrgency != null
        ? widget.urgencyLevels.indexOf(widget.selectedUrgency!).toDouble()
        : 0; // Mặc định là 0 nếu không có giá trị
  }

  @override
  void didUpdateWidget(covariant CampaignDetailEditableFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật _currentSliderValue nếu selectedUrgency thay đổi từ bên ngoài
    if (widget.selectedUrgency != oldWidget.selectedUrgency && widget.selectedUrgency != null) {
      final newIndex = widget.urgencyLevels.indexOf(widget.selectedUrgency!);
      if (newIndex != -1 && newIndex != _currentSliderValue.toInt()) {
        setState(() {
          _currentSliderValue = newIndex.toDouble();
        });
      }
    }
    // Cập nhật dateController khi dateRangeDisplay thay đổi
    if (widget.dateRangeDisplay != oldWidget.dateRangeDisplay) {
      widget.dateController.text = widget.dateRangeDisplay;
    }
  }

  Widget _buildUrgencySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề cho Slider
        _buildSectionTitle(tr("urgency")),
        Slider(
          value: _currentSliderValue,
          min: 0,
          max: (widget.urgencyLevels.length - 1).toDouble(), // Đảm bảo max đúng với số lượng level
          divisions: widget.urgencyLevels.length - 1,
          label: widget.urgencyLevels[_currentSliderValue.toInt()],
          activeColor: AppColors.sunrise, // Sử dụng màu từ AppColors
          onChanged: (value) {
            setState(() {
              _currentSliderValue = value;
              if (widget.onUrgencyChanged != null) {
                widget.onUrgencyChanged!(
                    widget.urgencyLevels[value.toInt()]);
              }
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.urgencyLevels
              .map((level) => Text(level, style: const TextStyle(fontSize: 12)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0), // Thêm padding để tạo khoảng cách
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16, // Kích thước lớn hơn một chút cho tiêu đề
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary, // Màu sắc rõ ràng hơn
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon, size: 20),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        filled: true,
        fillColor: AppColors.pureWhite,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade50, width: 1.0), // Màu border tinh tế hơn
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.sunrise, width: 2), // Màu focus đẹp hơn
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (val) {
        if (!isOptional && (val == null || val.trim().isEmpty)) {
          return '${label} ${tr("cannot_be_empty")}'; // Sử dụng tr()
        }
        return null;
      },
    );
  }

  Widget _buildDropdown(String? value, List<String> items,
      ValueChanged<String?>? onChanged, String label, IconData icon, BuildContext context,
      {bool isOptional = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label, // Sử dụng labelText cho Dropdown
        prefixIcon: Icon(icon, size: 20),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        filled: true,
        fillColor: AppColors.pureWhite,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade50, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.sunrise, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: (val) {
        if (!isOptional && (val == null || val.isEmpty)) {
          return '${tr("please_select")} ${label}'; // Sử dụng tr()
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelectDateRange, // Gọi callback từ widget cha
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.dateController, // Sử dụng dateController từ widget
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today, size: 20),
            labelText: tr("time"), // Thay đổi hintText thành labelText
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            filled: true,
            fillColor: AppColors.pureWhite,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade50, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.sunrise, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          readOnly: true, // Chỉ đọc
          validator: (val) => val == null || val.isEmpty
              ? '${tr("please_select")} ${tr("time")}'
              : null,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(widget.titleController, tr("project_title"), Icons.title),
          const SizedBox(height: 16), // Khoảng cách giữa các trường

          _buildDatePickerField(context),
          const SizedBox(height: 16),

          _buildDropdown(widget.selectedCategory, widget.categories,
              widget.onCategoryChanged, tr("category"), Icons.category, context),
          const SizedBox(height: 16),

          _buildUrgencySlider(), // Sử dụng Slider
          const SizedBox(height: 16),
          _buildTextField(widget.addressController, tr("address"), Icons.location_on),
          const SizedBox(height: 16),

          _buildTextField(widget.phoneController, tr("phoneNumber"), Icons.phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildDropdown(widget.selectedSupportType, widget.supportTypes,
              widget.onSupportTypeChanged, tr("supportType"), Icons.volunteer_activism, context),
          const SizedBox(height: 16),

          _buildDropdown(widget.selectedBankName, widget.bankNames,
              widget.onBankNameChanged, tr("bank_name"), Icons.account_balance, context, isOptional: true), // Bank Name có thể tùy chọn
          const SizedBox(height: 16),

          _buildTextField(widget.bankAccountController, tr("bank_account_number"), Icons.credit_card,
              keyboardType: TextInputType.number, isOptional: true), // Bank Account có thể tùy chọn
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}