import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'user_rank.dart';

class HexagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double radius = size.width / 2;
    final double height = size.height;
    final double width = size.width;


    path.moveTo(width * 0.5, 0); // Top middle
    path.lineTo(width, height * 0.25); // Top right
    path.lineTo(width, height * 0.75); // Bottom right
    path.lineTo(width * 0.5, height); // Bottom middle
    path.lineTo(0, height * 0.75); // Bottom left
    path.lineTo(0, height * 0.25); // Top left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class UserRankBadge extends StatelessWidget {
  final String rank;
  final String iconName;

  const UserRankBadge({
    Key? key,
    required this.rank,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BeautifulRankPage()),
        );
      },
      child: ClipPath(
        clipper: HexagonalClipper(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF8DC), Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // No borderRadius needed here as ClipPath handles the shape
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.7),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.yellow.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: IntrinsicHeight( // Ensure children take up their natural height
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, // Explicitly center vertically
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    FontAwesomeIcons.medal,
                    color: Color(0xFFFFA500),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Wrap Text with Center to ensure vertical centering within its own space
                   Text(
                      rank,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B3B00), // Màu nâu đậm như logo thương hiệu vàng
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.orangeAccent,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}