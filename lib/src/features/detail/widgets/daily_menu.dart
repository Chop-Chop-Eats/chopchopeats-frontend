import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../home/widgets/section_header.dart';

/// 每日菜单数据模型
class DailyMenuItem {
  final String date; // 格式如: 10/21
  final String weekdayDisplay; // 显示用的星期文本，如：周一、Today、Mon
  final int weekday; // 1-7 代表周一到周日，用于接口调用
  final DateTime dateTime; // 完整的日期时间
  
  DailyMenuItem({
    required this.date,
    required this.weekdayDisplay,
    required this.weekday,
    required this.dateTime,
  });
}

/// 每日菜单组件
class DailyMenu extends StatefulWidget {
  final Function(int weekday, DailyMenuItem item) onDateChanged;

  const DailyMenu({
    super.key,
    required this.onDateChanged,
  });

  @override
  State<DailyMenu> createState() => _DailyMenuState();
}

class _DailyMenuState extends State<DailyMenu> {
  int _selectedIndex = 0; // 当前选中的日期索引
  List<DailyMenuItem> _dailyMenuItems = []; // 每日菜单列表

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中初始化，此时 context 已经准备好
    _initializeDailyMenu();
  }

  /// 初始化每日菜单数据（生成本周7天的菜单项）
  /// 貌似是推翻了之前的设定
  /// 显示本周7天，但今天排在第一个
  /// 排序规则：今天、今天之后的日期（本周内）、今天之前的日期（本周内）
  /// 例如：今天是周三，显示顺序为：周三、周四、周五、周六、周日、周一、周二
  void _initializeDailyMenu() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 计算本周一的日期
    // weekday: 1=周一, 2=周二, ..., 7=周日
    // 要回到周一，需要减去 (weekday - 1) 天
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    
    // 先生成本周完整的7天数据
    final allDaysOfWeek = List.generate(7, (index) {
      final date = mondayOfThisWeek.add(Duration(days: index));
      final weekday = date.weekday; // 1-7 代表周一到周日
      
      // 格式化日期显示 MM/dd
      final dateString = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      
      // 获取星期显示文本
      String weekdayDisplay;
      if (date.isAtSameMomentAs(today)) {
        // 如果是今天，显示"今天"
        weekdayDisplay = l10n.today;
      } else {
        // 根据weekday获取对应的星期文本
        weekdayDisplay = _getWeekdayText(weekday, l10n);
      }
      
      return DailyMenuItem(
        date: dateString,
        weekdayDisplay: weekdayDisplay,
        weekday: weekday,
        dateTime: date,
      );
    });
    
    // 重新排序：今天放第一个，之后是今天之后的日期，最后是今天之前的日期
    final todayIndex = allDaysOfWeek.indexWhere((item) => item.dateTime.isAtSameMomentAs(today));
    if (todayIndex != -1) {
      // 今天及之后的日期
      final todayAndAfter = allDaysOfWeek.sublist(todayIndex);
      // 今天之前的日期
      final beforeToday = allDaysOfWeek.sublist(0, todayIndex);
      // 合并：今天开始 + 之前的日期
      _dailyMenuItems = [...todayAndAfter, ...beforeToday];
      // 今天在第一个位置
      _selectedIndex = 0;
    } else {
      // 如果今天不在本周范围内（理论上不会发生），使用原顺序
      _dailyMenuItems = allDaysOfWeek;
      _selectedIndex = 0;
    }
    
    if (mounted) {
      setState(() {});
      // 在 setState 之后，使用 addPostFrameCallback 延迟通知，避免布局错误
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final selectedItem = _dailyMenuItems[_selectedIndex];
          widget.onDateChanged(selectedItem.weekday, selectedItem);
        }
      });
    }
  }

  /// 根据weekday值获取对应的星期文本
  String _getWeekdayText(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

  /// 切换每日菜单
  void _changeDailyItem(int index, DailyMenuItem item) {
    if (_selectedIndex == index) return; // 如果已经选中，则不处理
    
    setState(() {
      _selectedIndex = index;
    });
    
    // 通知父组件日期变化
    widget.onDateChanged(item.weekday, item);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // 每日菜单标题
        SectionHeader(
          title: l10n.dailyMenu,
          iconPath: 'assets/images/fire.png',
          size: 18.sp,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        // 每日菜单列表
        if (_dailyMenuItems.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _dailyMenuItems.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildDailyItem(
                    date: item.date,
                    weekday: item.weekdayDisplay,
                    selected: _selectedIndex == index,
                    onTap: () => _changeDailyItem(index, item),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  /// 构建每日菜单项
  Widget _buildDailyItem({
    required String date, // 日期 格式：MM/dd
    required String weekday, // 星期显示文本
    required bool selected, // 是否选中
    required VoidCallback onTap, // 点击回调
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryOrange : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      margin: EdgeInsets.only(right: 8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            weekday,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          CommonSpacing.medium,
          Text(
            date,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
