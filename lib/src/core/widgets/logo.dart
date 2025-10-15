import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'common_image.dart';

class Logo extends StatelessWidget {

  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(196, 196, 196, 0.25),
            offset: Offset(0, 2.h),
            blurRadius: 12.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: CommonImage(imagePath: "assets/images/logo.png", height: 80.h , borderRadiusClip: BorderRadius.circular(24.r)),
    );
  }
}
