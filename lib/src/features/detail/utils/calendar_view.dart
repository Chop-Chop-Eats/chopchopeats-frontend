import 'package:flutter/material.dart';
import 'package:omni_calendar_view/omni_calendar_view.dart';

class CalendarView extends StatelessWidget {
  final OmniCalendarController controller;
  final SelectionType? selectionType;
  final bool showLunar;
  final Locale locale;
  final bool showSurroundingDays;

  const CalendarView({
    super.key,
    required this.controller,
    required this.showLunar,
    required this.locale,
    required this.showSurroundingDays,
    this.selectionType
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24 , vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16)
      ),
      child: OmniCalendarView(
        selectionType: selectionType ?? SelectionType.single , // 指定日历类型 单选、范围选择
        controller: controller,
        showLunar: showLunar,
        showSurroundingDays: showSurroundingDays,
        locale: locale,
      ),
    );
  }
}
