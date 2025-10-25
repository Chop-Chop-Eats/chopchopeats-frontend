import '../../../core/utils/json_utils.dart';

/// 用户基本信息
class UserInfoModel {
  ///可使用优惠券数量
  final int? availableCouponCount;

  ///用户头像
  final String? avatar;

  ///是否成为推广员
  final bool? brokerageEnabled;

  ///用户邮箱
  final String? email;

  ///经验值
  final int experience;

  ///用户编号
  final String id;

  ///用户等级
  final Level? level;

  ///用户手机号
  final String mobile;

  ///用户昵称
  final String nickname;

  ///积分
  final int point;

  ///用户性别
  final int sex;

  ///钱包余额（现金+赠送）
  final double? walletBalance;

  UserInfoModel({
    this.availableCouponCount,
    this.avatar,
    this.brokerageEnabled,
    this.email,
    required this.experience,
    required this.id,
    this.level,
    required this.mobile,
    required this.nickname,
    required this.point,
    required this.sex,
    this.walletBalance,
  });
  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      availableCouponCount: json['availableCouponCount'],
      avatar: json['avatar'] ?? '',
      brokerageEnabled: json['brokerageEnabled']  ?? false,
      email: json['email'],
      experience: json['experience'],
      id: json['id'],
      level: json['level'] != null ? Level.fromJson(json['level']) : null,
      mobile: json['mobile'],
      nickname: json['nickname'],
      point: json['point'],
      sex: json['sex'],
      walletBalance: JsonUtils.parseDouble(json, 'walletBalance'),
    );
  }
}

///用户等级
///
///Level，用户 App - 会员等级
class Level {
  ///等级图标
  final String? icon;

  ///等级编号
  final int id;

  ///等级
  final int level;

  ///等级名称
  final String name;

  Level({this.icon, required this.id, required this.level, required this.name});
  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      icon: json['icon'],
      id: json['id'],
      level: json['level'],
      name: json['name'],
    );
  }
}
