import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/app_services.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/custom_sliver_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/providers/favorite_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../models/home_models.dart';
import '../widgets/location_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_grid.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/section_header.dart';
import '../../../core/widgets/restaurant/restaurant_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _latitude = AppServices.appSettings.latitude;
  final _longitude = AppServices.appSettings.longitude;

  @override
  void initState() {
    super.initState();
    // 加载分类数据和甄选私厨数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
      ref.read(selectedChefProvider.notifier).loadSelectedChef(
        latitude: _latitude,
        longitude: _longitude,
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
                // _buildTipText(),
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
        child: HomeSearchBar(
          hintText: AppLocalizations.of(context)!.searchHintHome,
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
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.loadingFailedMessage(error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击重试按钮');
                ref.read(categoryProvider.notifier).refresh();
              },
              child: Text(l10n.tryAgainText),
            ),
          ],
        ),
      );
    }

    // 如果没有数据，显示空状态
    if (categories.isEmpty) {
      Logger.warn('HomePage', '显示空状态 - 没有分类数据');
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(l10n.noCategoryData),
        ),
      );
    }

    final topRowCategories = categories.take(2).toList();
    final bottomRowCategories = categories.skip(2).take(4).toList();

    // 转换数据模型
    final topRowCategoryData = topRowCategories.map((category) {
      return CategoryData(
        imagePath: category.selectedIcon ?? category.icon ?? '',
        title: category.localizedCategoryName ?? '', 
        subtitle: category.description ?? '', 
        imgToRight: true, 
      );
    }).toList();
    
    final bottomRowCategoryData = bottomRowCategories.map((category) {
    
      return CategoryData(
        imagePath: category.selectedIcon ?? category.icon ?? '',
        title: category.localizedCategoryName ?? '',
        subtitle: category.description ?? '',
        imgToRight: false,
      );
    }).toList();

    return CategoryGrid(
      topRowCategories: topRowCategoryData,
      bottomRowCategories: bottomRowCategoryData,
      onCategoryTap: (categoryData) {
        final categoryItem = categories.firstWhere(
          (item) => item.localizedCategoryName == categoryData.title,
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
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.loadingFailedMessage(error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击Banner重试按钮');
                ref.read(bannerProvider.notifier).loadBannerList();
              },
              child: Text(l10n.tryAgainText),
            ),
          ],
        ),
      );
    }

    if (banners.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(l10n.noBannerData),
        ),
      );
    }

    return BannerCarousel(
      bannerImages: banners.map((banner) => banner.imageUrl).toList(),
      onBannerTap: _onBannerTap,
    );
  }

  // Widget _buildTipText() {
  //   return const TipTextSection(
  //     topText: "The taste of home",
  //     normalText: '一起寻找',
  //     highlightText: '家的味道',
  //     bottomText: "without the cooking",
  //   );
  // }

  Widget _buildPrivateKitchensHeader() {
    return SectionHeader(
      title: AppLocalizations.of(context)!.selectedChef,
      iconPath: 'assets/images/fire.png', // 可以添加火苗图标
    );
  }

  Widget _buildRestaurantList() {
    // 监听甄选私厨数据状态
    final restaurants = ref.watch(selectedChefRestaurantsProvider);
    final isLoading = ref.watch(selectedChefLoadingProvider);
    final error = ref.watch(selectedChefErrorProvider);
    
    // 监听收藏操作的 loading 状态
    final hasFavoriteProcessing = ref.watch(hasFavoriteProcessingProvider);

    // 显示加载状态
    if (isLoading && restaurants.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: const CommonIndicator(),
      );
    }

    // 显示错误状态
    if (error != null && restaurants.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.loadingFailedMessage(error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Logger.info('HomePage', '用户点击甄选私厨重试按钮');
                ref.read(selectedChefProvider.notifier).refresh(
                  latitude: _latitude,
                  longitude: _longitude,
                );
              },
              child: Text(l10n.tryAgainText),
            ),
          ],
        ),
      );
    }

    // 如果没有数据，显示空状态
    if (restaurants.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(l10n.noRestaurantData),
        ),
      );
    }

    return RestaurantList(
      restaurants: restaurants,
      isInteractionDisabled: hasFavoriteProcessing, // 收藏操作进行中时禁用交互
    );
  }


  // 事件处理方法
  void _onCategoryTap(CategoryListItem category) {
    Logger.info('HomePage', '点击分类: ${category.localizedCategoryName} (ID: ${category.id})');
    // 跳转到分类详情页面
    Navigate.push(
      context,
      Routes.categoryDetail,
      arguments: {
        'categoryId': category.id,
        'categoryName': category.localizedCategoryName ?? category.categoryName,
      },
    );
  }

  void _onBannerTap(int index) {
    Logger.info('HomePage', '点击Banner: $index');
  }

}
