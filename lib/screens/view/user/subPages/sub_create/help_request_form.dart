// File: lib/pages/help_request_form.dart
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../components/app_colors.dart';
import '../../widgets/landing/landing_page_widgets.dart';

typedef OnSubmitCallback = void Function(Map<String, dynamic> requestData);

class HelpRequestForm extends StatefulWidget {
  final String userEmail;
  final String userName;
  final OnSubmitCallback onSubmit;
  final Function onCampaignCreated;

  const HelpRequestForm({
    Key? key,
    required this.userEmail,
    required this.userName,
    required this.onSubmit,
    required this.onCampaignCreated,
  }) : super(key: key);

  @override
  _HelpRequestFormState createState() => _HelpRequestFormState();
}

class _HelpRequestFormState extends State<HelpRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '84');

  String? title, description, address, supportType, urgency, receivingMethod, bankAccount, bankName, selectedCategory;
  XFile? mainImage;
  DateTime? startDate;
  DateTime? endDate;
  bool agreement = false;
  bool _isSubmitting = false;
  double _currentSliderValue = 1;
  int maxVolunteerCount = 0;
// controller cho ô nhập tay
  late TextEditingController _maxVolController;
  final List<String> supportTypes = ["food".tr(), "cash".tr(), "medical".tr(), "education".tr(), "supplies".tr(),  "shelter".tr(), "clothing".tr(), "other".tr()];
  final List<String> urgencyLevels = ["urgencyLow".tr(), "urgencyMedium".tr(), "urgencyHigh".tr()];
  final List<String> receivingMethods = ["onsite".tr(),  "bank_transfer".tr(), "relief_center".tr()];
  final List<String> bankNames = [
    'Vietcombank', 'Techcombank', 'BIDV', 'VietinBank', 'Agribank', 'MB Bank', 'Sacombank',
    'ACB', 'VPBank', 'HDBank', 'SHB', 'TPBank', 'Eximbank', 'LienVietPostBank', 'OCB', 'SCB',
    'SeABank', 'Bac A Bank', 'DongA Bank', 'Nam A Bank', 'ABBANK', 'PVcomBank', 'VIB', 'Viet Capital Bank',
    'SaigonBank', 'CBBank', 'GPBank', 'VietBank', 'OceanBank', 'BaoViet Bank', 'KienlongBank', 'NCB',
    'PG Bank', 'VRB', 'HSBC', 'Standard Chartered', 'Shinhan Bank', 'CitiBank', 'ANZ', 'UOB', 'Woori Bank',
    'Public Bank', 'Hong Leong Bank', 'DBS Bank', 'BNP Paribas', 'Deutsche Bank', 'Bank of China'
  ];
  final userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  void dispose() {
    _phoneController.dispose();
    _maxVolController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _maxVolController = TextEditingController(text: '$maxVolunteerCount');
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (pickedImage != null) setState(() => mainImage = pickedImage);
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? now
          : (startDate ?? now),
      firstDate: isStartDate
          ? DateTime(now.year, now.month, now.day)
          : (startDate ?? DateTime(now.year, now.month, now.day)),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = pickedDate;
        }
      });
    }
  }


  Future<void> _submitForm() async {
    // 1. Kiểm tra form cơ bản và chọn danh mục
    if (!_formKey.currentState!.validate() || !agreement || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("please_fill_all_info_and_category".tr()))
      );
      return;
    }

    // 2. Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.sunrise.withOpacity(0.5), width: 2),
        ),
        backgroundColor: Color(0xFFFFF8E1),
        title: Text(
          "confirm".tr(),
          style: TextStyle(
            color: AppColors.deepOcean,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "confirm_send_request".tr(),
          style: TextStyle(
            color: AppColors.deepOcean,
            fontSize: 16,
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: Text("cancel".tr(), style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text("send".tr(), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
    if (!confirmed) return;

    // 3. Kiểm tra maxVolunteerCount
    if (maxVolunteerCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("volunteer_max_required".tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 4. Chuẩn bị gửi
    setState(() => _isSubmitting = true);
    _formKey.currentState!.save();

    // 5. Upload ảnh nếu có
    String? imageUrl;
    if (mainImage != null) {
      final fileName =
          'featured_activities/${DateTime.now().millisecondsSinceEpoch}_${mainImage!.name}';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final snapshot = await ref.putFile(File(mainImage!.path));
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    // 6. Tạo dữ liệu và gửi lên Firestore
    final requestData = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': selectedCategory,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'totalDonationAmount': 0.0,
      'participantCount': 0,
      'maxVolunteerCount': maxVolunteerCount,
      'fullName': widget.userName,
      'phoneNumber': _phoneController.text,
      'email': widget.userEmail,
      'address': address,
      'supportType': supportType,
      'urgency': urgencyLevels[_currentSliderValue.toInt()],
      'receivingMethod': receivingMethod,
      'bankAccount': receivingMethod == 'Chuyển khoản ngân hàng' ? bankAccount : null,
      'bankName': receivingMethod == 'Chuyển khoản ngân hàng' ? bankName : null,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'creatorEmail': widget.userEmail,
      'userId': userId,
    };

    await FirebaseFirestore.instance
        .collection('featured_activities')
        .add(requestData);

    // 7. Cập nhật campaignCount cho user
    try {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(widget.userEmail);
      await userRef.update({'campaignCount': FieldValue.increment(1)});
    } catch (_) {
      final userRef =
      FirebaseFirestore.instance.collection('users').doc(widget.userEmail);
      await userRef.set({
        'campaignCount': 1,
        'email': widget.userEmail,
        'name': widget.userName,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // 8. Thông báo thành công và reset form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "support_request_created".tr(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
      ),
    );

    _formKey.currentState!.reset();
    _phoneController.clear();
    setState(() {
      mainImage = null;
      selectedCategory = null;
      startDate = null;
      endDate = null;
      address = '';
      supportType = '';
      receivingMethod = '';
      bankAccount = '';
      bankName = '';
      agreement = false;
      _currentSliderValue = 0;
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        color: Colors.orange[50],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("section_1".tr()),
                  _buildDisabledTextField("email".tr(), widget.userEmail),

                  _buildSectionTitle("section_2".tr()),
                  _buildPhoneNumberField(),
                  Text(
                    "address_hint".tr(),
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  _buildTextField(
                    "contact_address".tr(),
                        (value) => address = value,
                    icon: Icons.location_on,
                  ),
                  _buildCategoryGrid(),
                  _buildTextField("project_title".tr(), (value) => title = value),
                  _buildTextField("descriptions".tr(), (value) => description = value, maxLines: 3),

                  _buildSectionTitle("volunteer_max".tr()),
                  SizedBox(height: 8),

                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.peach, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Nút giảm
                        Ink(
                          decoration: ShapeDecoration(
                            color: AppColors.peach.withOpacity(0.2),
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.remove, color: AppColors.deepOcean),
                            splashRadius: 20,
                            onPressed: () {
                              if (maxVolunteerCount > 0) {
                                setState(() {
                                  maxVolunteerCount--;
                                  _maxVolController.text = '$maxVolunteerCount';
                                });
                              }
                            },
                          ),
                        ),

                        // Khoảng cách
                        SizedBox(width: 8),

                        // Ô nhập tay
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            controller: _maxVolController,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: AppColors.deepOcean),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              final v = int.tryParse(value) ?? 0;
                              setState(() => maxVolunteerCount = v);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty || int.tryParse(value) == null) {
                                return 'Nhập số';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Khoảng cách
                        SizedBox(width: 8),

                        // Nút tăng
                        Ink(
                          decoration: ShapeDecoration(
                            color: AppColors.peach.withOpacity(0.2),
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.add, color: AppColors.deepOcean),
                            splashRadius: 20,
                            onPressed: () {
                              setState(() {
                                maxVolunteerCount++;
                                _maxVolController.text = '$maxVolunteerCount';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildSectionTitle("section_3".tr()),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text("upload_avatar".tr(), style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sunrise,
                    ),
                  ),

                  if (mainImage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Image.file(
                        File(mainImage!.path),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),

                  _buildSectionTitle("section_4".tr()),
                  _buildDatePickerField("start_date".tr(),startDate, () => _pickDate(context, true)),
                  _buildDatePickerField("end_date".tr(), endDate, () => _pickDate(context, false)),

                  _buildSectionTitle("section_5".tr()),
                  _buildDropdownField("support_type_needed".tr(), supportTypes, (value) => supportType = value),
                  Text(
                    '${ "urgency".tr()} ${urgencyLevels[_currentSliderValue.toInt()]}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: urgencyLevels[_currentSliderValue.toInt()],
                    activeColor:AppColors.skyMist,
                    onChanged: (value) {
                      setState(() {
                        _currentSliderValue = value;
                        urgency = urgencyLevels[value.toInt()];
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: urgencyLevels
                        .map((level) => Text(level, style: TextStyle(fontSize: 12)))
                        .toList(),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("section_6".tr()),
                      ...receivingMethods.map((method) => RadioListTile<String>(
                        title: Text(method),
                        value: method,
                        groupValue: receivingMethod,
                        activeColor: Colors.orange[400],
                        onChanged: (value) {
                          setState(() => receivingMethod = value!);
                        },
                      )),
                    ],
                  ),

                  if (receivingMethod == 'Chuyển khoản ngân hàng') ...[
                    _buildTextField("bank_account_number".tr(), (value) => bankAccount = value,
                        keyboardType: TextInputType.number),
                    _buildDropdownField("bank_name".tr(), bankNames, (value) => bankName = value),
                  ],
                  _buildSectionTitle("section_7".tr()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: agreement,
                            onChanged: (bool? value) => setState(() => agreement = value ?? false),
                            activeColor: Colors.orange[400],
                          ),
                          Expanded(
                            child: Text("confirmation_checkbox".tr()),
                          ),
                        ],
                      ),
                      if (selectedCategory == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0), // Căn lề để thẳng hàng với checkbox
                          child: Text(
                            "confirm_submission".tr(),
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sunrise,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                          : Text("create_support_campaign".tr(),
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            "categorys".tr(),
            style: TextStyle(
              fontSize: 16, // Giảm font tiêu đề
              color: AppColors.deepOcean,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Tăng số cột để ô nhỏ hơn
            childAspectRatio: 1.4, // Điều chỉnh tỷ lệ khung
            crossAxisSpacing: 6, // Giảm khoảng cách ngang
            mainAxisSpacing: 6, // Giảm khoảng cách dọc
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['title'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category['title'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.peach : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? AppColors.sunrise : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'],
                        size: 18,
                        color: isSelected ? Colors.orange : Colors.grey[700]),
                    SizedBox(height: 2),
                    Text(
                      category['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13, // Giảm font chữ
                        color: isSelected ? Colors.orange : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "please_complete_all_info".tr(),
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
  Widget _buildDatePickerField(String label, DateTime? selectedDate, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.deepOcean),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
          ),
        ),
        controller: TextEditingController(
          text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate) : "",
        ),
        onTap: onTap,
        validator: (value) => value!.isEmpty ? '${"please_select_field".tr()} $label' : null,
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.deepOcean,
        ),
      ),
    );
  }
  Widget _buildDropdownField(String label, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.deepOcean),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
          ),
        ),
        items: options.map((option) => DropdownMenuItem(
          value: option,
          child: Text(option),
        )).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? '${"please_select_field".tr()} $label' : null,
      ),
    );
  }
  Widget _buildTextField(String label, Function(String?) onSave,
      {TextInputType? keyboardType, int maxLines = 1,IconData? icon,}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.deepOcean),

          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? '${"please_enter_field".tr()} $label' : null,
        onSaved: onSave,
      ),
    );
  }
  Widget _buildDisabledTextField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        enabled: false,
      ),
    );
  }
  Widget _buildPhoneNumberField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: "phoneNumber".tr(),
          labelStyle: TextStyle(color: AppColors.deepOcean),

          prefixText: '+',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.peach, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.sunrise, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
          ),
        ),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "please_enter_phone".tr();
          }
          if (!RegExp(r'^84\d{9}$').hasMatch(value)) {
            return "invalid_phone_format".tr();
          }
          return null;
        },
      ),
    );
  }
}
