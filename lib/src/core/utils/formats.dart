import '../../features/home/models/home_models.dart';

/// 格式化营业时间
String formatOperatingHours(List<OperatingHour>? operatingHours) {
  if (operatingHours == null || operatingHours.isEmpty) {
    return '营业时间未知';
  }

  // 取第一个营业时间作为显示
  final firstHour = operatingHours.first;
  if (firstHour.time != null && firstHour.remark != null) {
    return '${firstHour.time} ${firstHour.remark}';
  } else if (firstHour.time != null) {
    return firstHour.time!;
  } else if (firstHour.remark != null) {
    return firstHour.remark!;
  }

  return '营业时间未知';
}
