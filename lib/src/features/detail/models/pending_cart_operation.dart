import 'dart:convert';
import 'package:hive/hive.dart';

part 'pending_cart_operation.g.dart';

/// 购物车操作类型
@HiveType(typeId: 0)
enum CartOperationType {
  /// 添加商品到购物车
  @HiveField(0)
  add,

  /// 更新购物车商品数量
  @HiveField(1)
  update,

  /// 从购物车移除商品
  @HiveField(2)
  remove,
}

/// 待同步的购物车操作
@HiveType(typeId: 1)
class PendingCartOperation {
  /// 操作类型
  @HiveField(0)
  final CartOperationType type;

  /// 操作唯一标识
  @HiveField(1)
  final String operationId;

  /// 操作参数（存储为 JSON 字符串，因为 Hive 不支持 Map<String, dynamic>）
  @HiveField(2)
  final String paramsJson;
  
  /// 操作参数（从 JSON 解析）
  Map<String, dynamic> get params => jsonDecode(paramsJson) as Map<String, dynamic>;

  /// 创建时间
  @HiveField(3)
  final DateTime createdAt;

  /// 重试次数
  @HiveField(4)
  final int retryCount;

  /// 商品ID（用于操作合并）
  @HiveField(5)
  final String? productId;

  /// 商品规格ID（用于操作合并）
  @HiveField(6)
  final String? productSpecId;

  PendingCartOperation({
    required this.type,
    required this.operationId,
    Map<String, dynamic>? params,
    String? paramsJson,
    required this.createdAt,
    this.retryCount = 0,
    this.productId,
    this.productSpecId,
  }) : paramsJson = paramsJson ?? (params != null ? jsonEncode(params) : '{}');

  /// 创建添加操作
  factory PendingCartOperation.add({
    required String operationId,
    required Map<String, dynamic> params,
    DateTime? createdAt,
  }) {
    return PendingCartOperation(
      type: CartOperationType.add,
      operationId: operationId,
      params: params,
      createdAt: createdAt ?? DateTime.now(),
      productId: params['productId'] as String?,
      productSpecId: params['productSpecId'] as String?,
    );
  }

  /// 创建更新操作
  factory PendingCartOperation.update({
    required String operationId,
    required Map<String, dynamic> params,
    DateTime? createdAt,
  }) {
    return PendingCartOperation(
      type: CartOperationType.update,
      operationId: operationId,
      params: params,
      createdAt: createdAt ?? DateTime.now(),
      productId: params['productId'] as String?,
      productSpecId: params['productSpecId'] as String?,
    );
  }

  /// 创建删除操作
  factory PendingCartOperation.remove({
    required String operationId,
    required Map<String, dynamic> params,
    DateTime? createdAt,
  }) {
    return PendingCartOperation(
      type: CartOperationType.remove,
      operationId: operationId,
      params: params,
      createdAt: createdAt ?? DateTime.now(),
      productId: params['productId'] as String?,
      productSpecId: params['productSpecId'] as String?,
    );
  }

  /// 增加重试次数
  PendingCartOperation incrementRetry() {
    return PendingCartOperation(
      type: type,
      operationId: operationId,
      paramsJson: paramsJson,
      createdAt: createdAt,
      retryCount: retryCount + 1,
      productId: productId,
      productSpecId: productSpecId,
    );
  }

  /// 获取操作键（用于合并相同商品的操作）
  String get operationKey {
    if (productId != null && productSpecId != null) {
      return '$productId|$productSpecId';
    }
    return operationId;
  }

  /// 是否可以与另一个操作合并
  bool canMergeWith(PendingCartOperation other) {
    if (type == CartOperationType.remove ||
        other.type == CartOperationType.remove) {
      return false; // 删除操作不能合并
    }
    return operationKey == other.operationKey;
  }

  /// 转换为JSON（用于持久化）
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'operationId': operationId,
      'params': params,
      'paramsJson': paramsJson,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'productId': productId,
      'productSpecId': productSpecId,
    };
  }

  /// 从JSON创建（用于恢复）
  factory PendingCartOperation.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    CartOperationType type;
    switch (typeStr) {
      case 'add':
        type = CartOperationType.add;
        break;
      case 'update':
        type = CartOperationType.update;
        break;
      case 'remove':
        type = CartOperationType.remove;
        break;
      default:
        throw Exception('Unknown operation type: $typeStr');
    }

    final paramsData = json['params'] as Map<String, dynamic>?;
    final paramsJsonStr = json['paramsJson'] as String?;
    
    return PendingCartOperation(
      type: type,
      operationId: json['operationId'] as String,
      params: paramsData,
      paramsJson: paramsJsonStr,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      productId: json['productId'] as String?,
      productSpecId: json['productSpecId'] as String?,
    );
  }

  @override
  String toString() {
    return 'PendingCartOperation(type: $type, operationId: $operationId, '
        'productId: $productId, productSpecId: $productSpecId, '
        'retryCount: $retryCount)';
  }
}
