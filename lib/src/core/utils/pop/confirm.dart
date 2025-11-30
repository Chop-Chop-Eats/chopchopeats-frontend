import 'package:flutter/material.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../theme/app_theme.dart';

class Confirm {
  static Future<bool?> show(
    String content, {
    required String confirmText,
    required String cancelText,
    Color confirmBgColor = AppTheme.primaryOrange,
    Border? cancelBorder,
    Color cancelBgColor = Colors.white,
  }) async {
    return await Pop.confirm(
      showCloseButton: false,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmBgColor: AppTheme.primaryOrange,
      cancelBorder: Border.all(color: AppTheme.primaryOrange),
      cancelBgColor: Colors.white,
    );
  }
}

final confirm = _Confirm();

class _Confirm {
  Future<bool?> call(
    String content, {
    required String confirmText,
    required String cancelText,
    Color confirmBgColor = AppTheme.primaryOrange,
    Border? cancelBorder,
    Color cancelBgColor = Colors.white,
  }) {
    return Confirm.show(
      content,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmBgColor: confirmBgColor,
      cancelBorder: cancelBorder,
      cancelBgColor: cancelBgColor,
    );
  }
}
