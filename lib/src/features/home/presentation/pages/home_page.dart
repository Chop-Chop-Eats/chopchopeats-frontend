import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_sliver_app_bar.dart';
import '../widgets/location_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_grid.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/tip_text_section.dart';
import '../widgets/section_header.dart';
import '../widgets/restaurant_list.dart';
import '../widgets/restaurant_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 分类数据
  final List<CategoryData> _topRowCategories = const [
    CategoryData(
      imagePath: 'assets/images/specialty1.png',
      title: '地方特色菜',
      subtitle: 'Local Specialties',
      imgToRight: true,
    ),
    CategoryData(
      imagePath: 'assets/images/specialty2.png',
      title: '特色面食',
      subtitle: 'Wheat Dishes',
      imgToRight: true,
    ),
  ];

  final List<CategoryData> _bottomRowCategories = const [
    CategoryData(
      imagePath: 'assets/images/specialty3.png',
      title: '卤味熟食',
      subtitle: 'Braised',
    ),
    CategoryData(
      imagePath: 'assets/images/specialty3.png',
      title: '便当快餐',
      subtitle: 'Bento',
    ),
    CategoryData(
      imagePath: 'assets/images/specialty5.png',
      title: '烘焙甜点',
      subtitle: 'Bakery',
    ),
    CategoryData(
      imagePath: 'assets/images/specialty6.png',
      title: '减脂轻食',
      subtitle: 'Lean Meals',
    ),
  ];

  // Banner数据
  final List<String> _bannerImages = const [
    'assets/images/banner.png',
    'assets/images/banner.png',
    'assets/images/banner.png',
  ];

  // 餐厅数据
  final List<RestaurantData> _restaurants = const [
    RestaurantData(
      imagePath: 'assets/images/restaurant1.png',
      name: 'Nethai烘培厨房',
      tags: '烘培甜点 • Bakery',
      rating: '4.8',
      deliveryTime: '12:00配送',
      distance: '1.2 km',
    ),
    RestaurantData(
      imagePath: 'assets/images/restaurant2.png',
      name: '岑式老面包(蜂蜜小面包)',
      tags: '烘培甜点 • Bakery',
      rating: '4.5',
      deliveryTime: '12:00/18:00配送',
      distance: '1.2 km',
    ),
    RestaurantData(
      imagePath: 'assets/images/restaurant3.png',
      name: '味研所·陕西面馆',
      tags: '特色面食 • Local Specialties',
      rating: '4.9',
      deliveryTime: '11:00配送',
      distance: '1.2 km',
    ),
  ];

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
      titleWidget: const HomeSearchBar(
        hintText: '想吃点什么?',
      ),
    );
  }

  Widget _buildCategories() {
    return CategoryGrid(
      topRowCategories: _topRowCategories,
      bottomRowCategories: _bottomRowCategories,
      onCategoryTap: _onCategoryTap,
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
    return RestaurantList(
      restaurants: _restaurants,
      onRestaurantTap: _onRestaurantTap,
      onFavoriteTap: _onFavoriteTap,
    );
  }

  // 事件处理方法
  void _onCategoryTap(CategoryData category) {
    // TODO: 处理分类点击事件
    debugPrint('点击分类: ${category.title}');
  }

  void _onBannerTap(int index) {
    // TODO: 处理Banner点击事件
    debugPrint('点击Banner: $index');
  }

  void _onRestaurantTap(RestaurantData restaurant) {
    // TODO: 处理餐厅点击事件
    debugPrint('点击餐厅: ${restaurant.name}');
  }

  void _onFavoriteTap(RestaurantData restaurant) {
    // TODO: 处理收藏点击事件
    debugPrint('收藏餐厅: ${restaurant.name}');
  }
}
