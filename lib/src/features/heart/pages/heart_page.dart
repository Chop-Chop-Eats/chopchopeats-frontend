import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/base_page.dart';
import '../../../core/widgets/restaurant/restaurant_card.dart';
import '../../../data/models/restaurant_model.dart';
import '../../home/models/home_models.dart';

class HeartPage extends ConsumerStatefulWidget {
  const HeartPage({super.key});

  @override
  ConsumerState<HeartPage> createState() => _HeartPageState();
}

class _HeartPageState extends ConsumerState<HeartPage> {
  // final MockDataService _mockDataService = MockDataService();
  List<RestaurantModel> _restaurants = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      // _restaurants = _mockDataService.getRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "收藏", 
      content: _buildContent()
    );
  }

  Widget _buildContent(){
    return ListView.builder(
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return RestaurantCard(
          restaurant: ChefItem.fromJson(restaurant.toSelectedChefResponse()),
          onTap: () => _onRestaurantTap(restaurant),
          onFavoriteTap: () => _onFavoriteTap(restaurant),
        );
      },
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
        content: Text(
          '已${restaurant.isFavorite ? '取消收藏' : '收藏'} ${restaurant.name}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }             
}
