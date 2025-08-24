import 'package:chop_user/src/core/routing/navigate.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? padding;

  const AuthHeader({
    super.key,
    this.onBackPressed,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 24.0, left: 24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed ?? () => Navigate.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
