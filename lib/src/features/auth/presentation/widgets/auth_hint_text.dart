import 'package:flutter/material.dart';

class AuthHintText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;

  const AuthHintText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Text(
        text,
        style: style ?? TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        textAlign: textAlign,
      ),
    );
  }
}
