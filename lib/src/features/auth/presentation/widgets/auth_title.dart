import 'package:flutter/material.dart';

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
      style: style ?? const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: textAlign ?? TextAlign.left,
    );
  }
}
