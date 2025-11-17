import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/coupon_models.dart';

class CouponServers {

  /// 获取我的优惠券列表
  static Future<CouponListModel> getMyCouponList(CouponListQuery query) async {
    final response = await ApiClient().get(
      ApiPaths.getMyCouponListApi, 
      queryParameters: query.toJson()
    );
    Logger.info('CouponServers', '获取我的优惠券列表: ${response.data}');
    return CouponListModel.fromJson(response.data);
  }
}