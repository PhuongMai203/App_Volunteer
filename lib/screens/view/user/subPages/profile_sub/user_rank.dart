import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../../components/app_colors.dart';
import '../../../../../components/app_gradients.dart';
import '../../../../../service/rank_service.dart';
import '../../widgets/certificate_widget.dart';

class BeautifulRankPage extends StatefulWidget {
  const BeautifulRankPage({super.key});

  @override
  State<BeautifulRankPage> createState() => _BeautifulRankPageState();
}

class _BeautifulRankPageState extends State<BeautifulRankPage> {
  int userScore = 0;
  String userRank = '';
  double progressToNext = 0.0;
  int nextRankScore = 0;
  Map<String, dynamic>? userData;
  final GlobalKey _certificateKey = GlobalKey();

  final List<Map<String, dynamic>> ranks = [
    {'label': 'Đồng', 'emoji': '🥉', 'minScore': 0, 'maxScore': 20, 'color': Colors.brown},
    {'label': 'Bạc', 'emoji': '🥈', 'minScore': 21, 'maxScore': 25, 'color': Colors.grey},
    {'label': 'Vàng', 'emoji': '🥇', 'minScore': 26, 'maxScore': 100, 'color': Colors.amber},
    {'label': 'Kim cương', 'emoji': '💎', 'minScore': 101, 'maxScore': 250, 'color': Color(0xFF7388C1)},
    {'label': 'VIP', 'emoji': '👑', 'minScore': 251, 'maxScore': 999999, 'color': Color(0xFFE33539)},
  ];

  Future<void>? _loadingUserRankFuture;

  @override
  void initState() {
    super.initState();
    userRank = ranks.first['label'];
    _loadingUserRankFuture = _loadUserRank();
  }
  Future<void> _loadUserRank() async {
    try {
      final result = await RankService.calculateAndUpdateRank();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        setState(() {
          userData = userSnapshot.data();
        });
      }

      setState(() {
        userScore = result['score'];
        userRank = result['rank'];
      });
    } catch (e) {
      debugPrint('Lỗi tính rank: $e');
    }
  }

  Future<void> _exportCertificateAsPDF() async {
    try {
      RenderRepaintBoundary boundary =
      _certificateKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(pngBytes)),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("certificate_failure".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.grey, statusBarIconBrightness: Brightness.dark),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.peachPinkToOrange),
          child: Scaffold(
            backgroundColor: AppColors.pureWhite,
            appBar: AppBar(
              backgroundColor: AppColors.sunrise,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                "your_rank_title".tr(),
                style: GoogleFonts.agbalumo(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
            body: FutureBuilder<void>(
              future: _loadingUserRankFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final currentRankData = ranks.firstWhere(
                      (r) => r['label'] == userRank,
                  orElse: () => ranks.first,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [currentRankData['color'].withOpacity(0.6), currentRankData['color']]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currentRankData['emoji'], style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentRankData['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('$userScore ${"points".tr()}', style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressIndicator(),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: ranks.map((rank) {
                          final isActive = rank['label'] == userRank;
                          return CircleAvatar(
                            radius: 32,
                            backgroundColor: isActive ? rank['color'] : Colors.grey[300],
                            child: Text(rank['emoji'], style: const TextStyle(fontSize: 30)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ranks.map((rank) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: '${rank['emoji']} ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  TextSpan(
                                    text: '${rank['label']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: rank['color'],
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' — ${rank['minScore']} đến ${rank['maxScore']} điểm',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      InteractiveViewer(
                        boundaryMargin: const EdgeInsets.all(20.0),
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: RepaintBoundary(
                          key: _certificateKey,
                          child: CertificateWidget(
                            rankData: currentRankData,
                            userScore: userScore,
                            userName: userData?['name'] ?? "Tình nguyện viên",
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _exportCertificateAsPDF,
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18,),
                        label: Text("issue_certificate".tr(), style: TextStyle(
                          color: Colors.white,
                          fontSize: 20
                        ),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final currentRankData = ranks.firstWhere((r) => r['label'] == userRank, orElse: () => ranks.first);
    final nextRankIndex = ranks.indexOf(currentRankData) + 1;

    if (nextRankIndex >= ranks.length) {
      return Text("max_rank_message".tr(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    }

    final nextRankData = ranks[nextRankIndex];
    final progressColor = Color.lerp(Colors.blue.shade100, nextRankData['color'], progressToNext);

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: currentRankData['color'], width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progressToNext,
              minHeight: 6,
              valueColor: AlwaysStoppedAnimation(progressColor!),
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('${(progressToNext * 100).toInt()}% ${"arrive".tr()} ${nextRankData['label']}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
