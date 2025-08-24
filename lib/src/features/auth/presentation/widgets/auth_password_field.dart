import 'package:flutter/material.dart';

/// 专门的密码输入字段组件
/// 
/// 包含密码显示/隐藏切换功能，自动管理密码可见性状态
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefix;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefix,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
                counterText: '',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
