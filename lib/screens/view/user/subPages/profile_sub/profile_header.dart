import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatefulWidget {
  final User? user;
  final Map<String, dynamic>? userData;

  const ProfileHeader({
    Key? key,
    required this.user,
    this.userData,
  }) : super(key: key);

  @override
  _ProfileHeaderState createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;
  bool _isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      userData = widget.userData;
      _isLoading = false;
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user?.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _uploadAndUpdateImage(imageFile);
      }
    } catch (e) {
      _showErrorSnack("${"select_image".tr()} $e");
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
      _showErrorSnack("${"capture_image".tr()} $e");
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
      ),
    );
  }

  Future<void> _uploadAndUpdateImage(File image) async {
    try {
      setState(() => _isLoading = true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images/${widget.user!.uid}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .update({'avatarUrl': downloadUrl});

      setState(() {
        _avatarImage = image;
        userData?['avatarUrl'] = downloadUrl;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnack("${"upload_image".tr()} ${e.toString()}");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final screenWidth = MediaQuery.of(context).size.width;

    double avatarSize;
    double nameFontSize;
    double emailFontSize;
    double rankFontSize;
    double editIconSize;
    double spacing;

    if (screenWidth >= 800) {
      avatarSize = 130;
      nameFontSize = 28;
      emailFontSize = 18;
      rankFontSize = 18;
      editIconSize = 28;
      spacing = 20;
    } else if (screenWidth >= 600) {
      avatarSize = 110;
      nameFontSize = 26;
      emailFontSize = 17;
      rankFontSize = 17;
      editIconSize = 26;
      spacing = 18;
    } else {
      avatarSize = 90;
      nameFontSize = 22;
      emailFontSize = 15;
      rankFontSize = 15;
      editIconSize = 24;
      spacing = 16;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
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
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      userData?['avatarUrl'] ?? 'assets/default_avatar.png',
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: avatarSize,
                          height: avatarSize,
                          color: Colors.grey,
                          child: const Icon(Icons.person, size: 40, color: Colors.white),
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.edit, size: editIconSize, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData?['name'] ?? "name_not_updated".tr(),
                  style: TextStyle(fontSize: nameFontSize, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.user?.email ?? '',
                  style: TextStyle(fontSize: emailFontSize, color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  '${"rank".tr()} ${userData?['rank'] ?? "no_rank".tr()}',
                  style: TextStyle(
                    fontSize: rankFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}