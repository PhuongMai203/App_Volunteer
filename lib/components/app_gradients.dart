import 'package:flutter/material.dart';

class AppGradients {
  // Gradient loang từ màu hồng nhạt đến cam đào nhạt
  static const LinearGradient peachPinkToOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8D1D0), // Hồng nhạt
      Color(0xFFFBDFBC), // Cam đào nhạt
      Color(0xFFD8BFD8)
    ],
  );
}
