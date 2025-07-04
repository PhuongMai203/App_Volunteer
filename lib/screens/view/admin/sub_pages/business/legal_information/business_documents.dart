import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BusinessDocumentsSection extends StatelessWidget {
  final File? cccdFrontImage;
  final File? cccdBackImage;
  final File? portraitImage;
  final File? logoImage;
  final File? stampImage;
  final Function(File) onCccdFrontPicked;
  final Function(File) onCccdBackPicked;
  final Function(File) onPortraitPicked;
  final Function(File) onLogoPicked;
  final Function(File) onStampPicked;

  const BusinessDocumentsSection({
    Key? key,
    required this.cccdFrontImage,
    required this.cccdBackImage,
    required this.portraitImage,
    required this.logoImage,
    required this.stampImage,
    required this.onCccdFrontPicked,
    required this.onCccdBackPicked,
    required this.onPortraitPicked,
    required this.onLogoPicked,
    required this.onStampPicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDocumentSection(
          title: "cccd_title".tr(),
          children: [
            Row(
              children: [
                Expanded(child: _buildImageInput(
                    "front_side".tr(),
                    cccdFrontImage,
                        () => _pickImage(context, onCccdFrontPicked)
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildImageInput(
                    "back_side".tr(),
                    cccdBackImage,
                        () => _pickImage(context, onCccdBackPicked)
                )),
              ],
            ),
            _buildImageInput(
                "portrait".tr(),
                portraitImage,
                    () => _pickImage(context, onPortraitPicked)
            ),
          ],
        ),
        // Sửa đổi phần này để đưa logo và con dấu vào một hàng ngang
        _buildDocumentSection(
          title:  "logo_and_stamp".tr(),
          children: [
            Row( // Bọc hai _buildImageInput vào một Row
              children: [
                Expanded( // Dùng Expanded để chúng chia đều không gian
                  child: _buildImageInput(
                      "select_logo".tr(),
                      logoImage,
                          () => _pickImage(context, onLogoPicked)
                  ),
                ),
                const SizedBox(width: 12), // Thêm khoảng cách giữa hai hình
                Expanded( // Dùng Expanded cho hình con dấu
                  child: _buildImageInput(
                      "select_stamp".tr(),
                      stampImage,
                          () => _pickImage(context, onStampPicked)
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentSection({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.yellow.shade50,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildImageInput(String title, File? image, VoidCallback onPick) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 18), // Giữ margin bottom cho từng input
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: image != null
            ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(image, fit: BoxFit.cover))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, Function(File) onImagePicked) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onImagePicked(File(picked.path));
    }
  }
}