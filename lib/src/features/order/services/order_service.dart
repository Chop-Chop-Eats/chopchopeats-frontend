import 'package:chop_user/src/core/network/api_client.dart';
import 'package:chop_user/src/core/network/api_paths.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:chop_user/src/core/utils/json_utils.dart';

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
    final data = response.data['data'];
    
    return OrderPageResult(
      total: JsonUtils.parseInt(data, 'total') ?? 0,
      list: JsonUtils.parseList(data, 'list', (e) => AppTradeOrderPageRespVO.fromJson(e)) ?? [],
    );
  }

  Future<AppTradeOrderDetailRespVO> getOrderDetail(String orderNo) async {
    final response = await _client.get(ApiPaths.getOrderDetailApi, queryParameters: {'orderNo': orderNo});
    return AppTradeOrderDetailRespVO.fromJson(response.data['data']);
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
