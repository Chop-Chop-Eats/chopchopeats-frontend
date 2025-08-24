import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthTitle extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AuthTitle({
    super.key,
    required this.title,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style ?? TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}
