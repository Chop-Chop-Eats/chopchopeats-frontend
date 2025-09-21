import '../../../core/enums/auth_enums.dart';

// 发送验证码 params参数
class AppAuthSmsSendParams {
  ///手机号
  final String mobile;

  ///发送场景,对应 SmsSceneEnum 枚举。1=会员用户手机号登陆, 2=会员用户修改手机, 3=会员用户修改密码, 4=会员用户忘记密码
  final SmsSceneEnum scene;

  ///用户平台类型 1-普通用户 2-私厨 3-司机
  final UserPlatformTypeEnum userPlatformType;

  AppAuthSmsSendParams({
    required this.mobile,
    required this.scene,
    required this.userPlatformType,
  });

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'scene': scene.index+1,
    'userPlatformType': userPlatformType.index+1,
  };
}

// 登录 params参数
class AppAuthLoginParams {
  ///手机验证码
  final String code;

  ///邮箱
  final String? email;

  ///手机号
  final String mobile;

  ///用户类型 1-普通用户 2-私厨 3-司机
  final UserPlatformTypeEnum userPlatformType;

  AppAuthLoginParams({
    required this.code,
    this.email,
    required this.mobile,
    required this.userPlatformType,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    if (email != null) 'email': email,
    'mobile': mobile,
    'userPlatformType': userPlatformType.index+1,
  };
}

// 登录返回参数(手机号验证码和密码登录都返回一样的结构)
class AppAuthLoginResponse {
  ///访问令牌
  final String accessToken;

  ///过期时间
  final DateTime expiresTime;

  ///社交用户 openid
  final String? openid;

  ///刷新令牌
  final String refreshToken;

  ///店铺ID
  final String? shopId;

  ///用户编号
  final String userId;

  AppAuthLoginResponse({
    required this.accessToken,
    required this.expiresTime,
    this.openid,
    required this.refreshToken,
    this.shopId,
    required this.userId,
  });

  factory AppAuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AppAuthLoginResponse(
      accessToken: json['accessToken'] as String,
      expiresTime:  DateTime.fromMillisecondsSinceEpoch(json['expiresTime'] as int),
      openid: json['openid'] as String?,
      refreshToken: json['refreshToken'] as String,
      shopId: json['shopId'] as String?,
      userId: json['userId'] as String,
    );
  }
}

// 密码登录 params参数
class AppAuthPlatformLoginParams {
  ///手机号
  final String mobile;

  ///密码
  final String password;

  ///用户平台类型 1-普通用户 2-私厨 3-司机
  final UserPlatformTypeEnum userPlatformType;

  AppAuthPlatformLoginParams({
    required this.mobile,
    required this.password,
    required this.userPlatformType,
  });

  Map<String, dynamic> toJson() => {
    'mobile': mobile,
    'password': password,
    'userPlatformType': userPlatformType.index+1 ,
  };
}

// 重置密码 params参数
class AppAuthResetPasswordParams {
  ///手机验证码
  final String code;

  ///手机号
  final String mobile;

  ///新密码
  final String password;

  ///用户类型 1-普通用户 2-私厨 3-司机
  final UserPlatformTypeEnum userPlatformType;

  AppAuthResetPasswordParams({
    required this.code,
    required this.mobile,
    required this.password,
    required this.userPlatformType,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'mobile': mobile,
    'password': password,
    'userPlatformType': userPlatformType.index+1,
  };
}
