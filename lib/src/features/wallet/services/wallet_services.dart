import '../../../core/network/api_client.dart';
import '../../../core/network/api_paths.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/wallet_models.dart';

class WalletServices {

  // 获取我的钱包信息
   static Future<MyWalletInfo> getMyWalletInfo() async {
    final response = await ApiClient().get(ApiPaths.getMyWalletInfoApi);
    Logger.info('WalletServices', 'getMyWalletInfo response: ${response.data}');
    return MyWalletInfo.fromJson(response.data);
  }

  // 获取最近钱包交易记录
  static Future<List<RecentWalletHistoryItem>> getRecentWalletHistory() async {
    final response = await ApiClient().get(ApiPaths.getRecentWalletHistoryApi);
    Logger.info('WalletServices', 'getRecentWalletHistory response: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => RecentWalletHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  // 获取全部钱包交易记录
  static Future<List<AllWalletHistoryItem>> getAllWalletHistory() async {
    final response = await ApiClient().get(ApiPaths.getAllWalletHistoryApi);
    Logger.info('WalletServices', 'getAllWalletHistory response: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => AllWalletHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }

  // 创建充值订单
  static Future<void> createRechargeCardOrder(RechargeCardOrderParams params) async {
    final response = await ApiClient().post(
      ApiPaths.createRechargeCardOrderApi,
      data: params.toJson(),
    );
    Logger.info('WalletServices', 'createRechargeCardOrder response: ${response.data}');
    return response.data;
  }

  // 充值卡列表
  static Future<List<RechargeCardItem>> getRechargeCardList() async {
    final response = await ApiClient().get(ApiPaths.getRechargeCardListApi);
    Logger.info('WalletServices', 'getRechargeCardList response: ${response.data}');
    if (response.data is List) {
      final List<dynamic> dataList = response.data as List<dynamic>;
      return dataList.map((e) => RechargeCardItem.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('API 返回的数据格式不正确，期望 List 类型');
    }
  }
}