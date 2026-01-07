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

  /// 初始化每日菜单数据（从当前日期算未来7天）
  /// 
  /// 从今天开始，生成未来7天（今天 + 未来6天）
  /// 例如：今天是10.21周二，应该显示10.21今天 到 10.27周一
  void _initializeDailyMenu() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _dailyMenuItems = List.generate(7, (index) {
      final date = today.add(Duration(days: index));
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
    
    // 设置默认选中项为今天（索引0）
    _selectedIndex = 0;
    
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
