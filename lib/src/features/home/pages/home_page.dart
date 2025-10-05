import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/custom_sliver_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../providers/home_provider.dart';
import '../models/home_models.dart';
import '../widgets/location_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_grid.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/tip_text_section.dart';
import '../widgets/section_header.dart';
import '../widgets/restaurant_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {

  @override
  void initState() {
    super.initState();
    // 加载分类数据和甄选私厨数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(selectedChefProvider.notifier).loadSelectedChef(
        latitude: 43.6532,
        longitude: -79.3832,
      );
      ref.read(bannerProvider.notifier).loadBannerList();
    });
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
      expandedHeight: 120.h,
      locationWidget: LocationBar(
        location: 'Northwalk Rd, Toronto',
        onLocationTap: () {
          Logger.info('HomePage', '点击位置');
        },
      ),
      contentPadding: EdgeInsets.only(left: 16.w, right: 16.w, top: 32.h),
      backgroundWidget: CommonImage(imagePath: "assets/images/appbar_bg.png"),
      titleWidget: GestureDetector(
        onTap: () { 
          Navigate.push(context, Routes.search);
        },
        child: const HomeSearchBar(
          hintText: '想吃点什么?',
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ref.watch(categoriesProvider);
    final isLoading = ref.watch(categoryLoadingProvider);
    final error = ref.watch(categoryErrorProvider);

    // 显示加载状态
    if (isLoading && categories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: const CommonIndicator(),
      );
    }

    // 显示错误状态
    if (error != null && categories.isEmpty) {
      Logger.error('HomePage', '显示错误状态: $error');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击重试按钮');
                ref.read(categoryProvider.notifier).refresh();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 如果没有数据，显示空状态
    if (categories.isEmpty) {
      Logger.warn('HomePage', '显示空状态 - 没有分类数据');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('暂无分类数据'),
        ),
      );
    }

    final topRowCategories = categories.take(2).toList();
    final bottomRowCategories = categories.skip(2).take(4).toList();

    // 转换数据模型
    final topRowCategoryData = topRowCategories.map((category) {
      return CategoryData(
        imagePath: category.selectedIcon ?? category.icon ?? '',
        title: category.categoryName ?? '', 
        subtitle: category.description ?? '', 
        imgToRight: true, 
      );
    }).toList();
    
    final bottomRowCategoryData = bottomRowCategories.map((category) {
    
      return CategoryData(
        imagePath: category.selectedIcon ?? category.icon ?? '',
        title: category.categoryName ?? '',
        subtitle: category.description ?? '',
        imgToRight: false,
      );
    }).toList();

    return CategoryGrid(
      topRowCategories: topRowCategoryData,
      bottomRowCategories: bottomRowCategoryData,
      onCategoryTap: (categoryData) {
        final categoryItem = categories.firstWhere(
          (item) => item.categoryName == categoryData.title,
        );
        _onCategoryTap(categoryItem);
      },
    );
  }



  Widget _buildBanner() {
    final banners = ref.watch(bannersProvider);
    final isLoading = ref.watch(bannerLoadingProvider);
    final error = ref.watch(bannerErrorProvider);

    if (isLoading && banners.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: const CommonIndicator(),
      );
    }

    if (error != null && banners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击Banner重试按钮');
                ref.read(bannerProvider.notifier).loadBannerList();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (banners.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('暂无Banner数据'),
        ),
      );
    }

    return BannerCarousel(
      bannerImages: banners.map((banner) => banner.imageUrl).toList(),
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
    // 监听甄选私厨数据状态
    final restaurants = ref.watch(selectedChefRestaurantsProvider);
    final isLoading = ref.watch(selectedChefLoadingProvider);
    final error = ref.watch(selectedChefErrorProvider);

    // 显示加载状态
    if (isLoading && restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: const CommonIndicator(),
      );
    }

    // 显示错误状态
    if (error != null && restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击甄选私厨重试按钮');
                ref.read(selectedChefProvider.notifier).refresh(
                  latitude: 43.6532,
                  longitude: -79.3832,
                );
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 如果没有数据，显示空状态
    if (restaurants.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('暂无甄选私厨数据'),
        ),
      );
    }

    return RestaurantList(
      restaurants: restaurants,
      onRestaurantTap: _onRestaurantTap,
      onFavoriteTap: _onFavoriteTap,
    );
  }

  // 事件处理方法
  void _onCategoryTap(CategoryListItem category) {
    Logger.info('HomePage', '点击分类: ${category.categoryName} (ID: ${category.id})');

    
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
    Logger.info('HomePage', '点击Banner: $index');
  }

  void _onRestaurantTap(ChefItem restaurant) {
    Logger.info('HomePage', '点击餐厅: ${restaurant.chineseShopName} (ID: ${restaurant.id})');
    
    // 跳转到餐厅详情页面
    Navigate.push(
      context,
      Routes.detail, // 使用现有的详情页面路由
      arguments: {
        'restaurantId': restaurant.id.toString(),
        'restaurant': restaurant,
      },
    );
  }

  void _onFavoriteTap(ChefItem restaurant) {
    Logger.info('HomePage', '点击收藏餐厅: ${restaurant.chineseShopName} (ID: ${restaurant.id})');
    
    // TODO: 实现收藏功能
    // 这里可以调用收藏服务的API
  }
}
