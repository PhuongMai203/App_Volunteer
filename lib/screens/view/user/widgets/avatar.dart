import 'package:flutter/material.dart';

class AvatarWithCrown extends StatelessWidget {
  final String? avatarUrl;

  const AvatarWithCrown({Key? key, this.avatarUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatarImage = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? NetworkImage(avatarUrl!)
        : const AssetImage('assets/default_avatar.png') as ImageProvider;

    final screenWidth = MediaQuery.of(context).size.width;
    final avatarOuterRadius = screenWidth * 0.12; // 12% chiều rộng màn hình
    final avatarInnerRadius = avatarOuterRadius - 2;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.teal.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: avatarOuterRadius,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: avatarInnerRadius,
          backgroundImage: avatarImage,
        ),
      ),
    );
  }
}
