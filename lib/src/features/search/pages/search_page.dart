import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app_services.dart';
import '../../../core/constants/app_constant.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';
import '../models/search_models.dart';
import '../services/search_services.dart';
import '../widgets/search_item.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final _latitude = AppServices.appSettings.latitude;
  final _longitude = AppServices.appSettings.longitude;
  final _pageSize = AppServices.appSettings.pageSize;
  List<String> _searchHistory = [];
  final List<String> _searchSuggestions = [
    '湘菜', '恰巴塔', '蜂蜜面包', '粤菜', '牛肉串', '肉夹馍', '卤鸭脖', '白切鸡', '低GI'
  ];
  final List<bool> _isHotList = [
    true, false, false, false, true, true, false, false, false
  ];

  Future<void> _initializeApp() async {
    try {
      final searchHistory = await AppServices.cache.get<List<String>>(AppConstants.searchHistory);
      if (mounted) {
        setState(() {
          _searchHistory = searchHistory ?? [];
        });
      }
      Logger.info('SearchPage', 'searchHistory: $searchHistory');

      final keywordList = await SearchServices.getKeywordList();
      Logger.info('SearchPage', 'keywordList: $keywordList');

      final historyList = await SearchServices.getHistoryList();
      Logger.info('SearchPage', 'historyList: $historyList');
      
      final searchShop = await SearchServices.searchShop(SearchQuery(
        search: "川",
        pageNo: 1,
        pageSize: _pageSize,
        latitude: _latitude,
        longitude: _longitude,
      ));
      Logger.info('SearchPage', 'searchShop: $searchShop');

    } catch (e) {
      Logger.error('SearchPage', 'Failed to load search history: $e');
      if (mounted) {
        setState(() {
          _searchHistory = [];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 延迟执行异步操作，避免在 initState 中直接调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
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
    try {
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        // 限制历史记录数量
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
        await AppServices.cache.set(AppConstants.searchHistory, _searchHistory);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      Logger.error('SearchPage', 'Failed to save search history: $e');
    }
  }

  // 清除搜索历史
  Future<void> _clearSearchHistory() async {
    try {
      await AppServices.cache.remove(AppConstants.searchHistory);
      if (mounted) {
        setState(() {
          _searchHistory.clear();
        });
      }
      Logger.info('SearchPage', '清除搜索历史');
    } catch (e) {
      Logger.error('SearchPage', 'Failed to clear search history: $e');
    }
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 返回按钮
        GestureDetector(
          onTap: () => Navigate.pop(context),
          child:Center(
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
            decoration: BoxDecoration(
              color: Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CommonSpacing.width(16.w),
                CommonImage(
                  imagePath: 'assets/images/search.png',
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(20.r),
            ),
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
              child: CommonImage(
                imagePath: 'assets/images/search_delete.png',
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