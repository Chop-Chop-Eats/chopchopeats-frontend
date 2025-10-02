import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/custom_sliver_app_bar.dart';
import '../../../core/widgets/common_spacing.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/restaurant_card.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../home/models/home_models.dart';

/// 分类详情页面 - 二级页面
class CategoryDetailPage extends StatefulWidget {
  final String categoryId;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  // final MockDataService _mockDataService = MockDataService();
  final ScrollController _scrollController = ScrollController();
  
  CategoryModel? _category;
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = true;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShowTitle = _scrollController.offset > 50.h;
      if (shouldShowTitle != _showTitle) {
        setState(() {
          _showTitle = shouldShowTitle;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      // final category = _mockDataService.getCategoryById(widget.categoryId);
      // final restaurants = _mockDataService.getRestaurantsByCategory(widget.categoryId);
      Logger.info('CategoryDetailPage', '加载数据成功');
      setState(() {
          // _category = category;
          // _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // 可以添加错误处理
      debugPrint('加载数据失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CommonAppBar(
          title: 'loading...',
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_category == null) {
      return Scaffold(
        appBar: CommonAppBar(
          title: '分类详情',
        ),
        body: const Center(
          child: Text('分类不存在'),
        ),
      );
    }

    return Scaffold(
      backgroundColor:Colors.white,
      appBar: null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            // 分类信息头部
            SliverToBoxAdapter(
              child: _buildCategoryHeader(),
            ),
            // 餐厅列表
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final restaurant = _restaurants[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: RestaurantCard(
                      restaurant: SelectedChefResponse.fromJson(restaurant.toSelectedChefResponse()),
                      onTap: () => _onRestaurantTap(restaurant),
                      onFavoriteTap: () => _onFavoriteTap(restaurant),
                    ),
                  );
                },
                childCount: _restaurants.length,
              ),
            ),
            // 底部间距
            SliverToBoxAdapter(
              child: CommonSpacing.height(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return CustomSliverAppBar(
      backgroundColor: Colors.white,
      expandedHeight: 64.h,
      backgroundWidget: CommonImage(
        imagePath: "assets/images/appbar_bg.png",
      ),
      titleWidget: AnimatedOpacity(
        opacity: _showTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 50),
        child: Text(
          _category?.title ?? '',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      showBackButton: true,
      backButtonColor: Colors.black,
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      margin: EdgeInsets.only(top: 16.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _category!.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          CommonSpacing.height(2),
          Text(
            _category!.subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _onRestaurantTap(RestaurantModel restaurant) {
    Logger.info('CategoryDetailPage', '点击餐厅: ${restaurant.name}');
    // 可以显示一个简单的对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('评分: ${restaurant.formattedRating}'),
            Text('配送时间: ${restaurant.deliveryTime}'),
            Text('距离: ${restaurant.distance}'),
            Text('地址: ${restaurant.address}'),
            Text(restaurant.formattedDeliveryFee),
            Text(restaurant.formattedMinOrder),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _onFavoriteTap(RestaurantModel restaurant) {
    // TODO: 处理收藏逻辑
    debugPrint('收藏餐厅: ${restaurant.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已${restaurant.isFavorite ? '取消收藏' : '收藏'} ${restaurant.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
