import 'dart:async';

import 'package:flutter/material.dart';
import 'package:omni_calendar_view/omni_calendar_view.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../core/theme/app_theme.dart';
import 'calendar_view.dart';

class CalendarPopupUtils {
  static Future<DateTime?> showCalendar(
    BuildContext context,
    OmniCalendarController controller,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final Completer<DateTime?> completer = Completer<DateTime?>();
    PopupManager.show(
      PopupConfig(
        animation: PopupAnimation.fade,
        onDismiss: () {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarView(
                  controller: controller,
                  showLunar: false,
                  locale: LocaleService.currentLocale,
                  showSurroundingDays: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          PopupManager.hideLast();
                          if (!completer.isCompleted) {
                            completer.complete(null);
                          }
                        },
                        child: Text(l10n.btnCancel),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                        ),
                        onPressed: () {
                          PopupManager.hideLast();
                          if (!completer.isCompleted) {
                            // 对于单选，返回 selectedDate
                            completer.complete(controller.selectedDate);
                          }
                        },
                        child: Text(l10n.btnConfirm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return completer.future;
  }
}

