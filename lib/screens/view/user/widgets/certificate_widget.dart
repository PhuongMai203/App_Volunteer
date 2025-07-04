import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CertificateWidget extends StatelessWidget {
  final Map<String, dynamic> rankData;
  final int userScore;
  final String userName;

  const CertificateWidget({
    Key? key,
    required this.rankData,
    required this.userScore,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Container(
      width: 800,
      height: 560,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border.all(color: Color(0xFFE65100), width: 3),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark nghiêng
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.4, // Góc nghiêng ~ -23 độ
              child: Center(
                child: Text(
                  "certificate_watermark".tr(),
                  style: TextStyle(
                    fontSize: 110,
                    color: Color(0xFFFFD54F).withOpacity(0.08),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Nội dung chính
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "certificate_country".tr(),
                style: GoogleFonts.merriweather(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              Text(
                "certificate_slogan".tr(),
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 2,
                width: 200,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFE65100),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "certificate_organization".tr(),
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "certificate_award".tr(),
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "certificate_title".tr(),
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    )
                  ],
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'certificate_volunteer_name'.tr(namedArgs: {'name': userName}),
                style: GoogleFonts.greatVibes(
                  fontSize: 28,
                  color: Color(0xFFBF360C),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'certificate_achievement'.tr(namedArgs: {
                    'emoji': rankData['emoji'] ?? '',
                    'rank': rankData['label'] ?? '',
                    'score': userScore.toString()
                  }),
                  style: GoogleFonts.merriweather(
                    fontSize: 17,
                    color: Color(0xFF4E342E),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height:50),
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bên trái
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'certificate_date'.tr(namedArgs: {'date': today}),
                        style: GoogleFonts.merriweather(
                          fontSize: 15,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'certificate_location'.tr(),
                        style: GoogleFonts.merriweather(
                          fontSize: 15,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),

                  // Bên phải
                  Column(
                    children: [
                      Text(
                        'certificate_organizer'.tr(),
                        style: GoogleFonts.merriweather(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      Text(
                        'certificate_representative'.tr(),
                        style: GoogleFonts.merriweather(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Con dấu & Chữ ký
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Con dấu
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFFD32F2F), width: 3),
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white70,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "✪",
                                style: TextStyle(
                                  color: Color(0xFFD32F2F).withOpacity(0.4),
                                  fontSize: 45,
                                ),
                              ),
                            ),
                          ),

                          // Chữ ký
                          Positioned(
                            bottom: 4,
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.black87, Colors.black],
                              ).createShader(bounds),
                              child: Text(
                                "HelpConnect",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Parisienne',
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'certificate_signature_hint'.tr(),
                        style: GoogleFonts.merriweather(
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
