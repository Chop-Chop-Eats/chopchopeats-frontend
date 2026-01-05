

class AppMerchantShopCommentCreateReqVO {
  final String shopId;
  final String orderId;
  final String? comment;
  final int rate;
  final List<String>? image;

  AppMerchantShopCommentCreateReqVO({
    required this.shopId,
    required this.orderId,
    this.comment,
    required this.rate,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'orderId': orderId,
      'comment': comment,
      'rate': rate,
      'image': image,
    };
  }
}
