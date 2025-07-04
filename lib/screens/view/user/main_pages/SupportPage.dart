import 'dart:async';

import 'package:activity_repository/activity_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:help_connect/components/app_colors.dart';
import '../../../../components/app_gradients.dart';
import '../campaign/upcoming_campaigns.dart';
import '../widgets/google_map.dart';
import '../widgets/landing/landing_page_widgets.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final FirebaseActivityRepo _repo = FirebaseActivityRepo();
  final PageController _pageController = PageController();
  late Future<List<FeaturedActivity>> _upcomingActivities;
  final PageController _upcomingController = PageController();
  final PageController _featuredController = PageController();

  List<FeaturedActivity> _upcomingList = [];
  Timer? _timer;

  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  geo.Position? _currentPosition;
  String _currentAddress = '';

  String _userRole = '';

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userRole = doc.data()?['role'] ?? 'user';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    geo.LocationPermission permission;

    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return;
    }

    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });

    _getAddressFromLatLng(position);
  }

  Future<void> _getAddressFromLatLng(geo.Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
      });
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _featuredController.dispose();
    _upcomingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _upcomingActivities = _repo.fetchAllUpcomingActivities();
    _loadUserRole();
    _getCurrentLocation();
  }

  void onCategorySelected(String categoryName) async {
    List<FeaturedActivity> allActivities = await _repo.fetchAllUpcomingActivities();
    List<FeaturedActivity> filteredActivities = allActivities.where((activity) {
      return activity.category == categoryName;
    }).toList();
    setState(() {
      _upcomingList = filteredActivities;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth >= 900 ? 5 : screenWidth >= 600 ? 4 : 3;
    int itemsPerPage = crossAxisCount * 2;
    int totalPages = (categories.length / itemsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sunrise,
        title: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04),
          child: Text(
            "support".tr(),
            style: GoogleFonts.agbalumo(
              fontSize: screenWidth > 600 ? 35 : 28,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
        ),
        elevation: 0, // Tùy chọn: loại bỏ bóng đổ
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.peachPinkToOrange,
        ),
        child: SafeArea(
          top: false, // Để tránh đè lên AppBar
          child: Column(
            children: [
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                        child: Text(
                          "who_to_help_today".tr(),
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 20 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      buildCategorySection(
                        crossAxisCount,
                        itemsPerPage,
                        totalPages,
                        _pageController,
                        onCategorySelected,
                      ),
                      SizedBox(height: 18),
                      Container(
                        width: screenWidth * 0.9,
                        child: LocationCampaignWidget(),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "upcoming_campaign".tr(),
                                  style: TextStyle(
                                    fontSize: screenWidth > 600 ? 22 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.deepOcean,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/newsfeed');
                                  },
                                  child: Text("see_all".tr()),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            FutureBuilder<List<FeaturedActivity>>(
                              future: _upcomingActivities,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      '${"error_loading_campaigns".tr()} ${snapshot.error}',
                                    ),
                                  );
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text("no_upcoming_campaigns".tr()),
                                  );
                                }
                                List<FeaturedActivity> sortedActivities = List.from(snapshot.data!);
                                sortedActivities.sort(
                                      (a, b) => b.startDate.compareTo(a.startDate),
                                );
                                return UpcomingCampaigns(
                                  activities: _upcomingList.isNotEmpty
                                      ? _upcomingList
                                      : (snapshot.data ?? []),
                                );
                              },
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}