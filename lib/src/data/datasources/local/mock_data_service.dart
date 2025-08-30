import '../../models/category_model.dart';
import '../../models/restaurant_model.dart';

/// 模拟数据服务 - 用于开发阶段提供模拟数据
class MockDataService {
  static const MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  const MockDataService._internal();

  /// 获取分类数据
  List<CategoryModel> getCategories() {
    return [
      const CategoryModel(
        id: 'local_specialties',
        imagePath: 'assets/images/specialty1.png',
        title: '地方特色菜',
        subtitle: 'Local Specialties',
        description: '品味地道的本地特色美食',
        imgToRight: true,
        sortOrder: 1,
      ),
      const CategoryModel(
        id: 'wheat_dishes',
        imagePath: 'assets/images/specialty2.png',
        title: '特色面食',
        subtitle: 'Wheat Dishes',
        description: '各种特色面条和面食',
        imgToRight: true,
        sortOrder: 2,
      ),
      const CategoryModel(
        id: 'braised',
        imagePath: 'assets/images/specialty3.png',
        title: '卤味熟食',
        subtitle: 'Braised',
        description: '精选卤味和熟食',
        sortOrder: 3,
      ),
      const CategoryModel(
        id: 'bento',
        imagePath: 'assets/images/specialty3.png',
        title: '便当快餐',
        subtitle: 'Bento',
        description: '快捷便当和快餐',
        sortOrder: 4,
      ),
      const CategoryModel(
        id: 'bakery',
        imagePath: 'assets/images/specialty5.png',
        title: '烘焙甜点',
        subtitle: 'Bakery',
        description: '新鲜烘焙的甜点和面包',
        sortOrder: 5,
      ),
      const CategoryModel(
        id: 'lean_meals',
        imagePath: 'assets/images/specialty6.png',
        title: '减脂轻食',
        subtitle: 'Lean Meals',
        description: '健康低脂的轻食选择',
        sortOrder: 6,
      ),
    ];
  }

  /// 获取餐厅数据
  List<RestaurantModel> getRestaurants() {
    return [
      const RestaurantModel(
        id: 'nethai_bakery',
        imagePath: 'assets/images/restaurant1.png',
        name: 'Nethai烘培厨房',
        tags: '烘培甜点 • Bakery',
        description: '专业烘焙，新鲜美味的甜点和面包',
        rating: 4.8,
        deliveryTime: '12:00配送',
        distance: '1.2 km',
        address: '北京市朝阳区三里屯路19号',
        categoryIds: ['bakery'],
        deliveryFee: 3.0,
        minOrder: 20.0,
      ),
      const RestaurantModel(
        id: 'cen_bakery',
        imagePath: 'assets/images/restaurant2.png',
        name: '岑式老面包(蜂蜜小面包)',
        tags: '烘培甜点 • Bakery',
        description: '传统手工制作，蜂蜜小面包香甜可口',
        rating: 4.5,
        deliveryTime: '12:00/18:00配送',
        distance: '1.2 km',
        address: '北京市朝阳区工体北路8号',
        categoryIds: ['bakery'],
        deliveryFee: 2.5,
        minOrder: 15.0,
      ),
      const RestaurantModel(
        id: 'weiyan_noodles',
        imagePath: 'assets/images/restaurant3.png',
        name: '味研所·陕西面馆',
        tags: '特色面食 • Local Specialties',
        description: '正宗陕西面食，传统工艺制作',
        rating: 4.9,
        deliveryTime: '11:00配送',
        distance: '1.2 km',
        address: '北京市朝阳区建国门外大街1号',
        categoryIds: ['wheat_dishes', 'local_specialties'],
        deliveryFee: 4.0,
        minOrder: 25.0,
      ),
      // 添加更多特色面食餐厅
      const RestaurantModel(
        id: 'lanzhou_noodles',
        imagePath: 'assets/images/restaurant1.png',
        name: '兰州正宗牛肉面',
        tags: '特色面食 • Wheat Dishes',
        description: '兰州正宗牛肉拉面，汤清面白萝卜红',
        rating: 4.7,
        deliveryTime: '10:30配送',
        distance: '0.8 km',
        address: '北京市朝阳区东三环中路39号',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 3.5,
        minOrder: 20.0,
      ),
      const RestaurantModel(
        id: 'sichuan_noodles',
        imagePath: 'assets/images/restaurant2.png',
        name: '川味担担面',
        tags: '特色面食 • Spicy Noodles',
        description: '正宗四川担担面，麻辣鲜香',
        rating: 4.6,
        deliveryTime: '11:30配送',
        distance: '1.5 km',
        address: '北京市朝阳区光华路5号',
        categoryIds: ['wheat_dishes', 'local_specialties'],
        deliveryFee: 4.5,
        minOrder: 22.0,
      ),
      const RestaurantModel(
        id: 'beijing_noodles',
        imagePath: 'assets/images/restaurant3.png',
        name: '老北京炸酱面',
        tags: '特色面食 • Beijing Style',
        description: '传统北京炸酱面，地道京味',
        rating: 4.4,
        deliveryTime: '12:30配送',
        distance: '2.0 km',
        address: '北京市朝阳区国贸大厦B1',
        categoryIds: ['wheat_dishes', 'local_specialties'],
        deliveryFee: 5.0,
        minOrder: 28.0,
      ),
      const RestaurantModel(
        id: 'shanxi_noodles',
        imagePath: 'assets/images/restaurant1.png',
        name: '山西刀削面',
        tags: '特色面食 • Shanxi Style',
        description: '手工刀削面，劲道爽滑',
        rating: 4.3,
        deliveryTime: '13:00配送',
        distance: '1.8 km',
        address: '北京市朝阳区建外SOHO',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 4.0,
        minOrder: 25.0,
      ),
      const RestaurantModel(
        id: 'wuhan_noodles',
        imagePath: 'assets/images/restaurant2.png',
        name: '武汉热干面',
        tags: '特色面食 • Wuhan Style',
        description: '正宗武汉热干面，香浓芝麻酱',
        rating: 4.5,
        deliveryTime: '11:45配送',
        distance: '1.3 km',
        address: '北京市朝阳区世贸天阶',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 3.8,
        minOrder: 18.0,
      ),
      const RestaurantModel(
        id: 'xinjiang_noodles',
        imagePath: 'assets/images/restaurant3.png',
        name: '新疆拌面',
        tags: '特色面食 • Xinjiang Style',
        description: '新疆大盘鸡拌面，香辣可口',
        rating: 4.6,
        deliveryTime: '12:15配送',
        distance: '1.7 km',
        address: '北京市朝阳区蓝色港湾',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 4.2,
        minOrder: 30.0,
      ),
      const RestaurantModel(
        id: 'guangdong_noodles',
        imagePath: 'assets/images/restaurant1.png',
        name: '广东云吞面',
        tags: '特色面食 • Cantonese Style',
        description: '广式云吞面，鲜美汤头',
        rating: 4.4,
        deliveryTime: '11:20配送',
        distance: '1.1 km',
        address: '北京市朝阳区太古里',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 3.2,
        minOrder: 16.0,
      ),
      const RestaurantModel(
        id: 'hangzhou_noodles',
        imagePath: 'assets/images/restaurant2.png',
        name: '杭州片儿川',
        tags: '特色面食 • Hangzhou Style',
        description: '杭州特色片儿川，清淡鲜美',
        rating: 4.2,
        deliveryTime: '12:45配送',
        distance: '2.2 km',
        address: '北京市朝阳区CBD核心区',
        categoryIds: ['wheat_dishes'],
        deliveryFee: 4.8,
        minOrder: 24.0,
      ),
    ];
  }

  /// 根据分类ID获取餐厅
  List<RestaurantModel> getRestaurantsByCategory(String categoryId) {
    final allRestaurants = getRestaurants();
    return allRestaurants.where((restaurant) {
      return restaurant.categoryIds.contains(categoryId);
    }).toList();
  }

  /// 根据ID获取分类信息
  CategoryModel? getCategoryById(String categoryId) {
    final categories = getCategories();
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// 获取首页顶部分类（2个大分类）
  List<CategoryModel> getTopCategories() {
    final categories = getCategories();
    return categories.where((category) => category.imgToRight).toList();
  }

  /// 获取首页底部分类（4个小分类）
  List<CategoryModel> getBottomCategories() {
    final categories = getCategories();
    return categories.where((category) => !category.imgToRight).toList();
  }
}
