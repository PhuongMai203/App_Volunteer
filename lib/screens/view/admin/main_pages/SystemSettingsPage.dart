// File: system_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/policy_card.dart';
import '../widgets/rank_badge.dart';
import '../widgets/section_card.dart';
import '../widgets/text_field_with_icon.dart';

class SystemSettingsScreen extends StatefulWidget {
  @override
  _SystemSettingsScreenState createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentReference _settingsRef = FirebaseFirestore.instance.collection('system_settings').doc('main');

  late TextEditingController _websiteNameController;
  late TextEditingController _sloganController;
  late TextEditingController _emailController;
  late TextEditingController _hotlineController;
  late TextEditingController _pointRuleController;
  late TextEditingController _bronzeController;
  late TextEditingController _silverController;
  late TextEditingController _goldController;
  late TextEditingController _diamondController;
  late TextEditingController _vipController;
  late TextEditingController _categoryController;
  late TextEditingController _termsController;
  late TextEditingController _privacyController;
  late TextEditingController _volunteerController;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  final List<IconData> _iconOptions = [
    Icons.star,
    Icons.favorite,
    Icons.school,
    Icons.sports_volleyball,
    Icons.accessible,
    Icons.eco,
    Icons.money_off,
    Icons.warning,
    Icons.groups,
    Icons.local_hospital,
    Icons.home,
  ];

  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSettings();
  }

  void _initializeControllers() {
    _websiteNameController = TextEditingController();
    _sloganController = TextEditingController();
    _emailController = TextEditingController();
    _hotlineController = TextEditingController();
    _pointRuleController = TextEditingController();
    _bronzeController = TextEditingController();
    _silverController = TextEditingController();
    _goldController = TextEditingController();
    _diamondController = TextEditingController();
    _vipController = TextEditingController();
    _categoryController = TextEditingController();
    _termsController = TextEditingController();
    _privacyController = TextEditingController();
    _volunteerController = TextEditingController();
  }

  Future<void> _loadSettings() async {
    try {
      DocumentSnapshot snapshot = await _settingsRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> generalInfo = data['generalInfo'] ?? {};
        _websiteNameController.text = generalInfo['websiteName'] ?? '';
        _sloganController.text = generalInfo['slogan'] ?? '';
        _emailController.text = generalInfo['email'] ?? '';
        _hotlineController.text = generalInfo['hotline'] ?? '';

        Map<String, dynamic> pointSettings = data['pointSettings'] ?? {};
        _pointRuleController.text = pointSettings['pointRule'] ?? '';
        _bronzeController.text = pointSettings['bronze']?.toString() ?? '0';
        _silverController.text = pointSettings['silver']?.toString() ?? '0';
        _goldController.text = pointSettings['gold']?.toString() ?? '0';
        _diamondController.text = pointSettings['diamond']?.toString() ?? '0';
        _vipController.text = pointSettings['vip']?.toString() ?? '0';

        List<dynamic> categoriesData = data['categories'] ?? [];
        _categories = categoriesData.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'icon': item['icon'],
          };
        }).toList();

        Map<String, dynamic> policySettings = data['policySettings'] ?? {};
        _termsController.text = policySettings['termsOfUse'] ?? '';
        _privacyController.text = policySettings['privacyPolicy'] ?? '';
        _volunteerController.text = policySettings['volunteerPolicy'] ?? '';
      }
    } catch (e) {
      print("Error loading settings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _settingsRef.set({
        'generalInfo': {
          'websiteName': _websiteNameController.text,
          'slogan': _sloganController.text,
          'email': _emailController.text,
          'hotline': _hotlineController.text,
        },
        'pointSettings': {
          'pointRule': _pointRuleController.text,
          'bronze': int.tryParse(_bronzeController.text) ?? 0,
          'silver': int.tryParse(_silverController.text) ?? 0,
          'gold': int.tryParse(_goldController.text) ?? 0,
          'diamond': int.tryParse(_diamondController.text) ?? 0,
          'vip': int.tryParse(_vipController.text) ?? 0,
        },
        'categories': _categories,
        'policySettings': {
          'termsOfUse': _termsController.text,
          'privacyPolicy': _privacyController.text,
          'volunteerPolicy': _volunteerController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cài đặt đã được lưu thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error saving settings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu cài đặt: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCategory() {
    if (_categoryController.text.isNotEmpty && _selectedIcon != null) {
      setState(() {
        _categories.add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'name': _categoryController.text,
          'icon': _selectedIcon!.codePoint,
        });
        _categoryController.clear();
        _selectedIcon = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên và chọn icon!'), backgroundColor: Colors.red),
      );
    }
  }

  void _removeCategory(int index) {
    setState(() {
      _categories.removeAt(index);
    });
  }

  @override
  void dispose() {
    _websiteNameController.dispose();
    _sloganController.dispose();
    _emailController.dispose();
    _hotlineController.dispose();
    _pointRuleController.dispose();
    _bronzeController.dispose();
    _silverController.dispose();
    _goldController.dispose();
    _diamondController.dispose();
    _vipController.dispose();
    _categoryController.dispose();
    _termsController.dispose();
    _privacyController.dispose();
    _volunteerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFF8A65)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionCard(title: 'Thông Tin Chung', icon: Icons.info_outline, children: [
              TextFieldWithIcon(label: 'Tên website', controller: _websiteNameController, icon: Icons.business),
              SizedBox(height: 12),
              TextFieldWithIcon(label: 'Slogan', controller: _sloganController, icon: Icons.tag_faces, maxLines: 2),
              SizedBox(height: 12),
              TextFieldWithIcon(label: 'Email liên hệ', controller: _emailController, icon: Icons.email),
              SizedBox(height: 12),
              TextFieldWithIcon(label: 'Hotline hỗ trợ', controller: _hotlineController, icon: Icons.phone),
            ]),

            SizedBox(height: 24),
            SectionCard(title: 'Cài Đặt Điểm & Xếp Hạng', icon: Icons.leaderboard, children: [
              TextFieldWithIcon(label: 'Quy tắc tính điểm', controller: _pointRuleController, icon: Icons.rule, maxLines: 6),
              SizedBox(height: 16),
              Text('Ngưỡng điểm:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
              SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  RankBadge(rank: 'Đồng', controller: _bronzeController, badgeColor: Colors.brown),
                  RankBadge(rank: 'Bạc', controller: _silverController, badgeColor: Colors.grey),
                  RankBadge(rank: 'Vàng', controller: _goldController, badgeColor: Colors.amber),
                  RankBadge(rank: 'Kim cương', controller: _diamondController, badgeColor: Colors.blue),
                  RankBadge(rank: 'VIP', controller: _vipController, badgeColor: Colors.purple),
                ],
              ),
            ]),

            SizedBox(height: 24),
            SectionCard(title: 'Quản Lý Danh Mục Hoạt Động', icon: Icons.category, children: [
              Row(
                children: [
                  Expanded(
                    child: TextFieldWithIcon(label: 'Tên danh mục', controller: _categoryController, icon: Icons.add_circle_outline),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<IconData>(
                    value: _selectedIcon,
                    hint: Icon(Icons.more_horiz),
                    items: _iconOptions.map((icon) {
                      return DropdownMenuItem(
                        value: icon,
                        child: Icon(icon, color: Color(0xFFE65100)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedIcon = value;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _addCategory,
                    backgroundColor: Color(0xFFFF8A65),
                    mini: true,
                    child: Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
              SizedBox(height: 16),
              Text('Danh sách danh mục hiện tại:', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic)),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final iconCode = _categories[index]['icon'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFFFCCBC),
                      child: iconCode != null
                          ? Icon(IconData(iconCode, fontFamily: 'MaterialIcons'), color: Color(0xFFE65100))
                          : Icon(Icons.category, color: Color(0xFFE65100)), // fallback icon khi bị null
                    ),
                    title: Text(_categories[index]['name']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _removeCategory(index),
                    ),
                  );
                },
              )

            ]),

            SizedBox(height: 24),
            SectionCard(title: 'Quản Lý Điều Khoản & Chính Sách', icon: Icons.policy, children: [
              PolicyCard(title: 'Điều khoản sử dụng', controller: _termsController, icon: Icons.description),
              SizedBox(height: 16),
              PolicyCard(title: 'Chính sách bảo mật', controller: _privacyController, icon: Icons.security),
              SizedBox(height: 16),
              PolicyCard(title: 'Chính sách hoạt động tình nguyện', controller: _volunteerController, icon: Icons.volunteer_activism),
            ]),

            SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text('LƯU CÀI ĐẶT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF8A65),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
