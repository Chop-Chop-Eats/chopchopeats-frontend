import '../../../core/network/api_paths.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger/logger.dart';
import '../models/payment_models.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  /// 获取 Stripe 配置
  Future<StripeConfig?> getStripeConfig() async {
    try {
      final response = await _apiClient.get(ApiPaths.getStripePublicKeyApi);
      if (response.data['code'] == 0) {
        return StripeConfig.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      Logger.error('PaymentService', '获取Stripe配置失败: $e');
      return null;
    }
  }

  /// 获取已绑定的卡片列表
  Future<List<StripePaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(ApiPaths.getPaymentMethodListApi);
      if (response.data['code'] == 0) {
        final List list = response.data['data'];
        return list.map((e) => StripePaymentMethodModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      Logger.error('PaymentService', '获取支付方式列表失败: $e');
      return [];
    }
  }

  /// 绑定新卡片 (将 Stripe 返回的 paymentMethodId 发送给后端)
  Future<bool> addPaymentMethod(String stripePaymentMethodId, {bool isDefault = false}) async {
    try {
      final response = await _apiClient.post(
        ApiPaths.addPaymentMethodApi,
        data: {
          'stripePaymentMethodId': stripePaymentMethodId,
          'isDefault': isDefault,
        },
      );
      return response.data['code'] == 0;
    } catch (e) {
      Logger.error('PaymentService', '添加支付方式失败: $e');
      return false;
    }
  }
}
