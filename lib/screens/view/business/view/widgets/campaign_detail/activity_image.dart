import 'package:flutter/material.dart';
import '../../../../../../components/app_colors.dart';

class ActivityImage extends StatelessWidget {
  final String imageUrl;

  const ActivityImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 220,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 220,
        color: AppColors.pureWhite,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }
}
