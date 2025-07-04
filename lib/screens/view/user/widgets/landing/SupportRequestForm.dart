import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../components/app_colors.dart';

class SupportRequestForm extends StatefulWidget {
  const SupportRequestForm({super.key});

  @override
  State<SupportRequestForm> createState() => _SupportRequestFormState();
}

class _SupportRequestFormState extends State<SupportRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('support_requests').add({
        'userId': user?.uid ?? '',
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi yêu cầu thành công!'), backgroundColor: Colors.green),
        );
        _nameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _descriptionController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi yêu cầu: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.support_agent, size: 50, color: AppColors.sunrise),
                const SizedBox(height: 12),
                const Text(
                  'Yêu cầu hỗ trợ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepOcean),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  label: 'Họ và tên',
                  icon: Icons.person,
                  validatorMsg: 'Vui lòng nhập họ tên',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  label: 'Số điện thoại',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validatorMsg: 'Vui lòng nhập số điện thoại',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  focusNode: _addressFocus,
                  label: 'Địa chỉ',
                  icon: Icons.location_on,
                  validatorMsg: 'Vui lòng nhập địa chỉ',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  focusNode: _descriptionFocus,
                  label: 'Mô tả cần giúp đỡ',
                  icon: Icons.help_outline,
                  maxLines: 4,
                  validatorMsg: 'Vui lòng nhập nội dung cần hỗ trợ',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.send, color: Colors.white),
                    label: Text(
                      _isSubmitting ? 'Đang gửi...' : 'Gửi yêu cầu',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sunrise,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Builder(
        builder: (context) {
          final isFocused = focusNode.hasFocus;
          return TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: isFocused ? const Color(0xFF4B3832) : Colors.black54),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: AppColors.sunrise),
              filled: true,
              fillColor: Colors.grey[100],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.sunrise, width: 1.5),
              ),
            ),
            validator: (value) => (value == null || value.isEmpty) ? validatorMsg : null,
          );
        },
      ),
    );
  }
}
