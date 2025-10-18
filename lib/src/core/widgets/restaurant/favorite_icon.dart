import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../common_image.dart';

class FavoriteIcon extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteIcon({super.key, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
    onTap: onTap,
    child: CommonImage(imagePath: isFavorite ? "assets/images/heart_s.png" : "assets/images/heart.png", width: 20.w, height: 20.h));
  }
}