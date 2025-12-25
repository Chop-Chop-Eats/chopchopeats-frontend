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
      
      // ApiInterceptor 已经将 response.data 替换为后端返回的 data 字段
      if (response.data == null) return null;
      
      return StripeConfig.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      Logger.error('PaymentService', '获取Stripe配置失败: $e');
      return null;
    }
  }

  /// 获取已绑定的卡片列表
  Future<List<StripePaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get(ApiPaths.getPaymentMethodListApi);
      
      // ApiInterceptor 已经将 response.data 替换为后端返回的 data 字段
      // 所以 response.data 直接就是列表
      final data = response.data;
      
      if (data == null) return [];
      
      // 确保 data 是 List 类型
      if (data is! List) {
        Logger.error('PaymentService', '返回数据格式错误: $data');
        return [];
      }
      
      return data.map((e) {
        try {
          return StripePaymentMethodModel.fromJson(e as Map<String, dynamic>);
        } catch (e) {
          Logger.error('PaymentService', '解析支付方式失败: $e');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('PaymentService', '获取支付方式列表失败: $e');
      Logger.error('PaymentService', 'Stack trace: $stackTrace');
      return [];
    }
  }

  /// 绑定新卡片 (将 Stripe 返回的 paymentMethodId 发送给后端)
  Future<bool> addPaymentMethod(String stripePaymentMethodId, {bool isDefault = false}) async {
    try {
      await _apiClient.post(
        ApiPaths.addPaymentMethodApi,
        data: {
          'stripePaymentMethodId': stripePaymentMethodId,
          'isDefault': isDefault,
        },
      );
      // ApiInterceptor 会在业务失败时抛出异常，所以能执行到这里就是成功
      return true;
    } catch (e) {
      Logger.error('PaymentService', '添加支付方式失败: $e');
      return false;
    }
  }

  /// 使用卡片详情添加支付方式（后端会调用 Stripe API 创建 PaymentMethod）
  Future<bool> addPaymentMethodWithDetails({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String postalCode,
    bool isDefault = false,
  }) async {
    try {
      await _apiClient.post(
        ApiPaths.addPaymentMethodApi,
        data: {
          'cardNumber': cardNumber,
          'expMonth': expMonth,
          'expYear': expYear,
          'cvc': cvc,
          'postalCode': postalCode,
          'isDefault': isDefault,
        },
      );
      // ApiInterceptor 会在业务失败时抛出异常，所以能执行到这里就是成功
      return true;
    } catch (e) {
      Logger.error('PaymentService', '添加支付方式失败: $e');
      return false;
    }
  }

  /// 删除支付方式（卡片）
  Future<bool> deletePaymentMethod(String id) async {
    try {
      await _apiClient.delete('${ApiPaths.deletePaymentMethodApi}/$id');
      // ApiInterceptor 会在业务失败时抛出异常，所以能执行到这里就是成功
      return true;
    } catch (e) {
      Logger.error('PaymentService', '删除支付方式失败: $e');
      return false;
    }
  }
}
