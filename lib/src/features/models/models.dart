// 多处可以复用的model

/// 通用的Query 含有 经/纬度 pageNo pageSize
class CommonQuery {
  final double latitude;
  final double longitude;
  final int pageNo;
  final int pageSize;

  CommonQuery({
    required this.latitude,
    required this.longitude,
    required this.pageNo,
    required this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
  }
}
