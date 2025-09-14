import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app_services.dart';
import '../../../../core/constants/app_constant.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/utils/logger/logger.dart';
import '../../../../core/widgets/common_spacing.dart';
import '../widgets/search_item.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  final List<String> _searchSuggestions = [
    '湘菜', '恰巴塔', '蜂蜜面包', '粤菜', '牛肉串', '肉夹馍', '卤鸭脖', '白切鸡', '低GI'
  ];
  final List<bool> _isHotList = [
    true, false, false, false, true, true, false, false, false
  ];

  Future<void> _initializeApp() async {
    final searchHistory = await AppServices.cache.get<List<String>>(AppConstants.searchHistory);
    setState(() {
      _searchHistory = searchHistory ?? [];
    });
    Logger.info('SearchPage', 'searchHistory: $searchHistory');
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 执行搜索
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _addToSearchHistory(query);
      Logger.info('SearchPage', '搜索: $query');
      // TODO: 执行实际搜索逻辑
    }
  }

  // 选择历史记录项
  void _selectHistoryItem(String item) {
    _searchController.text = item;
    _performSearch();
  }

  // 选择推荐项
  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _performSearch();
  }

  // 添加到搜索历史
  Future<void> _addToSearchHistory(String query) async {
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query);
      // 限制历史记录数量
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.take(10).toList();
      }
      await AppServices.cache.set(AppConstants.searchHistory, _searchHistory);
      setState(() {});
    }
  }

  // 清除搜索历史
  Future<void> _clearSearchHistory() async {
    await AppServices.cache.remove(AppConstants.searchHistory);
    setState(() {
      _searchHistory.clear();
    });
    Logger.info('SearchPage', '清除搜索历史');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null, 
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w), 
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                _buildSearchBar(),
                SizedBox(height: 24.h),
                _buildSearchHistory(),
                SizedBox(height: 24.h),
                _buildSearchSuggestion(),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        )
      )
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // 返回按钮
        GestureDetector(
          onTap: () => Navigate.pop(context),
          child: Container(
            width: 24.w,
            height: 24.h,
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: Colors.black,
            ),
          ),
        ),
        CommonSpacing.width(12.w),
        // 搜索输入框
        Expanded(
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                CommonSpacing.width(16.w),
                Image.asset(
                  'assets/images/search.png',
                  width: 16.w,
                  height: 16.h,
                ),
                CommonSpacing.width(8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '湘菜',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF86909C),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CommonSpacing.width(12.w),
        // 搜索按钮
        GestureDetector(
          onTap: _performSearch,
          child: Container(
            width: 60.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Center(
              child: Text(
                '搜索',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '搜索历史',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: _clearSearchHistory,
              child: Image.asset(
                'assets/images/search_delete.png',
                width: 16.w,
                height: 16.h,
              ),
            ),
          ],
        ),
        CommonSpacing.medium,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _searchHistory.map((item) {
            return GestureDetector(
              onTap: () => _selectHistoryItem(item),
              child: SearchItem(title: item),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildSearchSuggestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '猜你喜欢',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        CommonSpacing.medium,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _searchSuggestions.asMap().entries.map((entry) {
            int index = entry.key;
            String suggestion = entry.value;
            bool isHot = _isHotList[index];
            
            return GestureDetector(
              onTap: () => _selectSuggestion(suggestion),
              child: SearchItem(
                title: suggestion,
                isHot: isHot,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}