import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_sliver_app_bar.dart';
import '../../../../core/routing/navigate.dart';
import '../../../../core/routing/routes.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/restaurant_model.dart';
import '../../../../data/datasources/local/mock_data_service.dart';
import '../widgets/location_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_grid.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/tip_text_section.dart';
import '../widgets/section_header.dart';
import '../widgets/restaurant_list.dart';
import '../../../../core/widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MockDataService _mockDataService = MockDataService();
  
  List<CategoryModel> _topRowCategories = [];
  List<CategoryModel> _bottomRowCategories = [];
  List<RestaurantModel> _restaurants = [];
  final List<String> _bannerImages = const [
    'assets/images/banner.png',
    'assets/images/banner.png',
    'assets/images/banner.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // 使用MockDataService获取数据
    _topRowCategories = _mockDataService.getTopCategories();
    _bottomRowCategories = _mockDataService.getBottomCategories();
    _restaurants = _mockDataService.getRestaurants().take(3).toList(); // 只取前3个
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 247, 253),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategories(),
                _buildBanner(),
                _buildTipText(),
                _buildPrivateKitchensHeader(),
                _buildRestaurantList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return CustomSliverAppBar(
      backgroundColor: const Color.fromARGB(255, 246, 247, 253),
      expandedHeight: 108.h,
      locationWidget: const LocationBar(
        location: 'Northwalk Rd, Toronto',
      ),
      backgroundWidget: Image.asset("assets/images/chef.png"),
      titleWidget: const HomeSearchBar(
        hintText: '想吃点什么?',
      ),
    );
  }

  Widget _buildCategories() {
    // 转换数据模型
    final topRowCategoryData = _topRowCategories.map((category) => CategoryData(
      imagePath: category.imagePath,
      title: category.title,
      subtitle: category.subtitle,
      imgToRight: category.imgToRight,
    )).toList();
    
    final bottomRowCategoryData = _bottomRowCategories.map((category) => CategoryData(
      imagePath: category.imagePath,
      title: category.title,
      subtitle: category.subtitle,
      imgToRight: category.imgToRight,
    )).toList();

    return CategoryGrid(
      topRowCategories: topRowCategoryData,
      bottomRowCategories: bottomRowCategoryData,
      onCategoryTap: (categoryData) {
        // 找到对应的CategoryModel
        final categoryModel = _topRowCategories.firstWhere(
          (model) => model.title == categoryData.title,
          orElse: () => _bottomRowCategories.firstWhere(
            (model) => model.title == categoryData.title,
          ),
        );
        _onCategoryTap(categoryModel);
      },
    );
  }



  Widget _buildBanner() {
    return BannerCarousel(
      bannerImages: _bannerImages,
      onBannerTap: _onBannerTap,
    );
  }

  Widget _buildTipText() {
    return const TipTextSection(
      topText: "The taste of home",
      normalText: '一起寻找',
      highlightText: '家的味道',
      bottomText: "without the cooking",
    );
  }

  Widget _buildPrivateKitchensHeader() {
    return const SectionHeader(
      title: '臻选私厨',
      iconPath: 'assets/images/fire.png', // 可以添加火苗图标
    );
  }

  Widget _buildRestaurantList() {
    // 转换数据模型
    final restaurantData = _restaurants.map((restaurant) => RestaurantData(
      imagePath: restaurant.imagePath,
      name: restaurant.name,
      tags: restaurant.tags,
      rating: restaurant.formattedRating,
      deliveryTime: restaurant.deliveryTime,
      distance: restaurant.distance,
    )).toList();

    return RestaurantList(
      restaurants: restaurantData,
      onRestaurantTap: (data) {
        // 找到对应的RestaurantModel
        final restaurantModel = _restaurants.firstWhere(
          (model) => model.name == data.name,
        );
        _onRestaurantTap(restaurantModel);
      },
      onFavoriteTap: (data) {
        // 找到对应的RestaurantModel
        final restaurantModel = _restaurants.firstWhere(
          (model) => model.name == data.name,
        );
        _onFavoriteTap(restaurantModel);
      },
    );
  }

  // 事件处理方法
  void _onCategoryTap(CategoryModel category) {
    debugPrint('点击分类: ${category.title} (ID: ${category.id})');
    
    // 跳转到分类详情页面
    Navigate.push(
      context,
      Routes.categoryDetail,
      arguments: {
        'categoryId': category.id,
      },
    );
  }

  void _onBannerTap(int index) {
    debugPrint('点击Banner: $index');
    // TODO: 处理Banner点击事件，可以跳转到活动页面
  }

  void _onRestaurantTap(RestaurantModel restaurant) {
    debugPrint('点击餐厅: ${restaurant.name} (ID: ${restaurant.id})');
    // TODO: 跳转到餐厅详情页面
    
    // 暂时显示餐厅信息
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
    debugPrint('收藏餐厅: ${restaurant.name} (ID: ${restaurant.id})');
    
    // TODO: 实现收藏逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已${restaurant.isFavorite ? '取消收藏' : '收藏'} ${restaurant.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
