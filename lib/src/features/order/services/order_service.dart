import 'package:chop_user/src/core/network/api_client.dart';
import 'package:chop_user/src/core/network/api_paths.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/core/utils/json_utils.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';

class OrderPageResult {
  final int total;
  final List<AppTradeOrderPageRespVO> list;

  OrderPageResult({required this.total, required this.list});
}

class OrderService {
  final ApiClient _client = ApiClient();

  Future<OrderPageResult> getOrderPage({
    required int pageNo,
    required int pageSize,
    int? statusGroup,
  }) async {
    final params = {
      'pageNo': pageNo,
      'pageSize': pageSize,
      if (statusGroup != null) 'statusGroup': statusGroup,
    };
    final response = await _client.get(ApiPaths.getOrderListApi, queryParameters: params);
    
    // API 拦截器已经提取了 data 字段，所以 response.data 就是实际数据
    final data = response.data as Map<String, dynamic>;
    
    Logger.info('OrderService', '开始解析订单列表数据');
    final total = JsonUtils.parseInt(data, 'total') ?? 0;
    Logger.info('OrderService', 'total: $total');
    
    final rawList = data['list'];
    Logger.info('OrderService', 'rawList类型: ${rawList.runtimeType}, 长度: ${rawList is List ? rawList.length : 'N/A'}');
    
    List<AppTradeOrderPageRespVO>? parsedList;
    try {
      parsedList = JsonUtils.parseList(data, 'list', (e) {
        Logger.info('OrderService', '解析订单: ${e['orderNo']}');
        return AppTradeOrderPageRespVO.fromJson(e);
      });
      Logger.info('OrderService', '成功解析 ${parsedList?.length ?? 0} 个订单');
    } catch (e, stack) {
      Logger.error('OrderService', '解析订单列表失败: $e');
      Logger.error('OrderService', '堆栈: $stack');
      rethrow;
    }
    
    return OrderPageResult(
      total: total,
      list: parsedList ?? [],
    );
  }

  Future<AppTradeOrderDetailRespVO> getOrderDetail(String orderNo) async {
    final response = await _client.get(ApiPaths.getOrderDetailApi, queryParameters: {'orderNo': orderNo});
    return AppTradeOrderDetailRespVO.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> cancelOrder(String orderNo, String cancelReason) async {
    final data = {
      'orderNo': orderNo,
      'cancelReason': cancelReason,
    };
    final response = await _client.put(ApiPaths.cancelOrderApi, data: data);
    return JsonUtils.parseBool(response.data, 'data') ?? false;
  }
}
