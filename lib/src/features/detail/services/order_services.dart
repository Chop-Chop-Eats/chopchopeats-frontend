import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../../home/models/home_models.dart';
import '../models/order_model.dart';

class OrderServices {
  /// 创建订单
  Future<String> createOrder(CreateOrderParams params) async {
    final response = await ApiClient().post(
      ApiPaths.createOrderApi,
      data: params.toJson(),
    );
    Logger.info('OrderServices', '创建订单: ${response.data}');
    return response.data;
  }

  /// 添加购物车
  Future<void> addCart(AddCartParams params) async {
    final response = await ApiClient().post(
      ApiPaths.addCartApi,
      data: params.toJson(),
    );
    Logger.info('OrderServices', '添加购物车: ${response.data}');
    return response.data;
  }

  /// 获取购物车列表
  Future<List<CartItemModel>> getCartList(GetCartListQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getCartListApi,
      queryParameters: query.toJson(),
    );
    Logger.info('OrderServices', '获取购物车列表: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  /// 清空购物车
  Future<void> clearCart(String shopId, String diningDate) async {
    Logger.info('OrderServices', '准备清空购物车: shopId=$shopId, diningDate=$diningDate');
    Logger.info('OrderServices', '使用API路径: ${ApiPaths.clearCartApi}');
    
    final response = await ApiClient().delete(
      ApiPaths.clearCartApi,
      data: {
        'shopId': shopId,
        'diningDate': diningDate,
      },
    );
    Logger.info('OrderServices', '清空购物车成功: ${response.data}');
    return response.data;
  }

  /// 删除购物车商品
  Future<void> deleteCartItem(String cartId) async {
    final response = await ApiClient().delete(
      ApiPaths.deleteCartItemApi,
      queryParameters: {'id': cartId},
    );
    Logger.info('OrderServices', '删除购物车商品: ${response.data}');
    return response.data;
  }

  /// 更新购物车数量
  Future<void> updateCartQuantity(UpdateCartParams params) async {
    final response = await ApiClient().put(
      ApiPaths.updateCartQuantityApi,
      data: params.toJson(),
    );
    Logger.info('OrderServices', '更新购物车数量: ${response.data}');
    return response.data;
  }

  /// 创建 Stripe PaymentIntent
  Future<SPIModel> createSPI(String orderNo ) async {
    final response = await ApiClient().post(
      ApiPaths.createSPIApi,
      data: {
        'orderNo': orderNo,
      },
    );
    Logger.info('OrderServices', '创建 Stripe PaymentIntent: ${response.data}');
    if (response.data is Map<String, dynamic>) {
      return SPIModel.fromJson(response.data);
    } else {
      throw Exception('API 返回的数据格式不正确，期望 Map<String, dynamic> 类型');
    }
  }

  /// 计算配送预估费用
  Future<DeliveryFeeModel> getDeliveryFee(DeliveryFeeQuery query) async {
    final response = await ApiClient().post(
      ApiPaths.getDeliveryFeeEstimateApi,
      data: query.toJson(),
    );
    Logger.info('OrderServices', '计算配送预估费用: ${response.data}');
    return DeliveryFeeModel.fromJson(response.data);
  }

    /// 获取可配送时间列表 diningDate 格式为 YYYY-MM-DD
  Future<List<OperatingHour>> getAvailableDeliveryTimes(String shopId , String diningDate) async {
    final response = await ApiClient().get(
      ApiPaths.getAvailableDeliveryTimesApi,
      queryParameters: {
        'shopId': shopId,
        'diningDate': diningDate,
      },
    );
    Logger.info('OrderServices', '获取可配送时间列表: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => OperatingHour.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

}
