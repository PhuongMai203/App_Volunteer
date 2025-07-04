import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:help_connect/components/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class HeaderBusiness extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userData;

  const HeaderBusiness({
    Key? key,
    required this.user,
    required this.userData,
  }) : super(key: key);

  @override
  _HeaderBusinessState createState() => _HeaderBusinessState();
}

class _HeaderBusinessState extends State<HeaderBusiness> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  File? _avatarImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _uploadAndUpdateImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${"select_image".tr()} $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _uploadAndUpdateImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${"capture_image".tr()} $e')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text("pick_from_gallery".tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: Text("take_photo".tr()),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text("cancel".tr()),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadAndUpdateImage(File image) async {
    try {
      setState(() => _isLoading = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/${user!.uid}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Cập nhật URL ảnh avatar vào Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'avatarUrl': downloadUrl,
      });

      // Cập nhật UI
      setState(() {
        _avatarImage = image;
        userData?['avatarUrl'] = downloadUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${"upload_image".tr()} ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        // Avatar, name & email
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 30),  // Giảm khoảng cách trên
              child: Row(
                children: [
                  // Bên trái: Avatar + Nút chỉnh sửa
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _avatarImage != null
                                ? Image.file(
                              _avatarImage!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              widget.userData?['avatarUrl'] ??
                                  'https://via.placeholder.com/100?text=Ảnh+đại+diện',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bên phải: Tên, Email và Rank
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),  // Tăng khoảng cách bên trái
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userData?['name'] ?? "name_not_updated".tr(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.userData?['email'] ?? "email_invalid_format".tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ],
    );
  }
}
