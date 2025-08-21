import 'package:intl/intl.dart';

/// 安全解构string
String asString(dynamic value) => value?.toString() ?? '';

/// 安全解析函数，可以处理 int, double, String 和 null
int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

/// 将多种格式的日期字符串统一转换为 "MMM dd, yyyy" 格式。
/// 如果字符串为 null、为空，或者无法被任何支持的格式解析，将返回原始字符串（或空字符串）。
String formatCustomDate(String? dateString) {
  if (dateString == null || dateString.trim().isEmpty) {
    return '';
  }

  //    注意：将更具体的格式（带时间）放在前面，以确保优先匹配。
  final List<DateFormat> supportedFormats = [
    // --- 需要转换的格式 ---
    DateFormat('yyyy-MM-dd HH:mm:ss'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('MM-dd-yyyy HH:mm:ss'),
    DateFormat('MM-dd-yyyy'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('MM/dd/yyyy'),
  ];

  DateTime? parsedDateTime;
  DateFormat? matchedFormat;

  // 遍历所有支持的格式，使用严格模式逐一尝试解析
  for (final format in supportedFormats) {
    try {
      // 使用 parseStrict 要求整个字符串完全匹配格式，避免误解析
      parsedDateTime = format.parseStrict(dateString);
      matchedFormat = format;
      // 一旦成功，立即跳出循环
      break;
    } catch (e) {
      // 解析失败，继续尝试下一个格式
    }
  }

  //  如果解析成功，则根据输入格式决定输出格式
  if (parsedDateTime != null && matchedFormat != null) {
    // 检查用于解析的格式字符串中是否包含时间相关的字符（H, h, m, s）
    final bool inputHadTime = matchedFormat.pattern!.contains(RegExp(r'[Hhms]'));

    if (inputHadTime) {
      // 如果输入包含时间，则输出也带上时间 ,HH:mm:ss
      final outputFormat = DateFormat('MMM dd, yyyy ', 'en_US');
      return outputFormat.format(parsedDateTime);
    } else {
      // 否则，只输出日期
      final outputFormat = DateFormat('MMM dd, yyyy', 'en_US');
      return outputFormat.format(parsedDateTime);
    }
  }

  // 如果所有格式都尝试失败，则返回原始字符串
  return dateString;
}

// --- 电话号码屏蔽辅助方法 ---
String maskPhoneNumber(String phoneNumber) {
  // 确保号码长度足够，避免异常
  if (phoneNumber.length > 4) {
    final lastFour = phoneNumber.substring(phoneNumber.length - 4);
    return '******$lastFour';
  }
  // 如果号码太短，直接返回，或者返回固定掩码
  return phoneNumber;
}

/// 将一个数字字符串格式化为带千分位和'₱'前缀的货币格式。
String formatPeso(String? amountString) {
  // 安全性检查：处理 null 或空字符串的情况
  if (amountString == null || amountString.isEmpty) {
    return '₱0';
  }

  // 将字符串转换为 double 类型，如果转换失败则返回默认值
  // 使用 tryParse 不会抛出异常，而是返回 null
  final double? amount = double.tryParse(amountString);
  if (amount == null) {
    return '₱0';
  }

  // 创建 NumberFormat 实例
  //    - '#,##0.##' 是一个格式化模式:
  //      - #,##0 会添加千分位逗号
  //      - .## 会保留最多两位小数（如果存在）
  //    - 'en_US' 确保分隔符是逗号 (,)，小数点是句点 (.)
  final formatter = NumberFormat('#,##0.##', 'en_US');

  // 格式化数字并拼接前缀
  return '₱${formatter.format(amount)}';
}
