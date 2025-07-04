import 'package:activity_repository/activity_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_connect/components/app_colors.dart';

import '../../admin/sub_pages/upcoming_sub/campaign_card.dart';

class LocationCampaignWidget extends StatefulWidget {
  const LocationCampaignWidget({super.key});

  @override
  State<LocationCampaignWidget> createState() => _LocationCampaignWidgetState();
}

class _LocationCampaignWidgetState extends State<LocationCampaignWidget> {
  Position? _currentPosition;
  String? _currentAddress;
  List<Map<String, dynamic>> _campaigns = [];
  bool _isLoadingLocation = true;
  String? _locationStatusMessage;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
      _locationStatusMessage = null;
      _currentAddress = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("location_service_disabled".tr());
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage = "location_service_disabled_message".tr();
        });
      }
      _showLocationServiceDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("location_permission_denied".tr());
        if (mounted) {
          setState(() {
            _isLoadingLocation = false;
            _locationStatusMessage = "location_permission_denied_message".tr();
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint("location_permission_denied_forever".tr());
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage = "location_permission_denied_forever_message".tr();
        });
      }
      _showAppSettingsDialog();
      return;
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      debugPrint('Current position: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
          _locationStatusMessage = null;
        });
      }

      // Lấy địa chỉ từ tọa độ
      await _getAddressFromCoordinates(position);

      await _fetchCampaigns();
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _locationStatusMessage = "error_fetching_location".tr(args: [e.toString()]);
        });
      }
    }
  }

  Future<void> _getAddressFromCoordinates(Position position) async {
    String? displayAddress;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String?> addressParts = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ];

        String joinedAddress = addressParts.where((element) => element != null && element.isNotEmpty).join(', ');

        if (joinedAddress.isNotEmpty) {
          displayAddress = joinedAddress;
        } else if (place.name != null && place.name!.isNotEmpty) {
          // Fallback sang tên chung nếu không có đủ thông tin chi tiết
          displayAddress = place.name!;
        } else {
          displayAddress = "address_unknown".tr();
        }
      } else {
        displayAddress = "address_unknown".tr();
      }
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      displayAddress = "unable_to_get_address".tr(args: [e.toString()]);
    }

    if (mounted) {
      setState(() {
        _currentAddress = displayAddress;
      });
    }
  }

  Future<void> _showLocationServiceDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.yellow.shade50, // 🎨 Nền vàng nhạt
        title: Text(
          "location_service_off_title".tr(),
          style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "location_service_off_content".tr(),
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "cancel".tr(),
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, // 🎨 Màu nút chính
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
              _fetchLocation();
            },
            child: Text("open_settings".tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _showAppSettingsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("permission_denied_title".tr()),
        content: Text("permission_denied_content".tr()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("cancel".tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
              _fetchLocation();
            },
            child: Text("open_app_settings".tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCampaigns() async {
    if (_currentPosition == null) {
      debugPrint('No current position to fetch campaigns.');
      if (mounted && !_isLoadingLocation && _locationStatusMessage == null) {
        setState(() {
          _locationStatusMessage = "no_current_location_for_campaigns".tr();
        });
      }
      return;
    }

    try {
      final DateTime now = DateTime.now();
      final Timestamp currentTimestamp = Timestamp.fromDate(now);

      final snapshot = await FirebaseFirestore.instance
          .collection('featured_activities')
          .where('endDate', isGreaterThanOrEqualTo: currentTimestamp)
          .get();

      final List<Map<String, dynamic>> nearbyCampaigns = [];

      for (var doc in snapshot.docs) {
        String? address = doc['address'];
        debugPrint('Address from Firestore: $address');

        if (address == null || address.isEmpty) {
          debugPrint('Skipping campaign ${doc.id}: address is null or empty');
          continue;
        }

        try {
          List<Location> locations = await locationFromAddress(address);
          if (locations.isEmpty) {
            debugPrint('No locations found for address: $address');
            continue;
          }
          double destLat = locations.first.latitude;
          double destLng = locations.first.longitude;

          debugPrint('Geocoded location: $destLat, $destLng');

          double distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            destLat,
            destLng,
          );

          debugPrint('Distance to ${doc.id}: $distance meters');

          if (distance < 50000) { // 50km
            debugPrint('Adding campaign: ${doc.id} at distance: $distance meters');
            nearbyCampaigns.add({
              'id': doc.id,
              'data': doc.data(),
            });
          }
        } catch (e) {
          debugPrint('Error geocoding address "$address": $e');
        }
      }

      if (mounted) {
        setState(() {
          _campaigns = nearbyCampaigns;
        });
      }
    } catch (e) {
      debugPrint('Error fetching campaigns from Firestore: $e');
      if (mounted) {
        setState(() {
          _locationStatusMessage = "error_fetching_campaigns".tr(args: [e.toString()]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "nearby_campaigns_suggestion".tr(),
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 8),

          if (_isLoadingLocation)
            Container(
              width: double.infinity,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text("searching_location".tr()),
                ],
              ),
            )
          else if (_locationStatusMessage != null)
            Container(
              width: double.infinity,
              height: 100,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _locationStatusMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade800),
              ),
            )
          else if (_currentPosition != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _currentAddress ?? "determining_address".tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.deepOcean,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),

          const SizedBox(height: 16),

          _campaigns.isEmpty && !_isLoadingLocation && _locationStatusMessage == null
              ? Center(child: Text("no_campaigns_found".tr()))
              : _campaigns.isNotEmpty
              ? SizedBox(
            height: 550, // chiều cao đủ để chứa card
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                final campaignData = _campaigns[index];
                final data = campaignData['data'];
                final id = campaignData['id'];

                if (data == null || id == null) {
                  return const SizedBox.shrink();
                }

                final activity = FeaturedActivity.fromMap(
                  data as Map<String, dynamic>,
                  id as String,
                );

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 280,
                    child: CampaignCard(
                      activity: activity,
                      onDeleted: () {
                        setState(() {
                          _campaigns.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          )
              : const SizedBox.shrink(), // Ẩn hoàn toàn nếu _campaigns rỗng và đang loading hoặc có lỗi vị trí
        ],
      ),
    );
  }
}