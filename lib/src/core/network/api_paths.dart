/// 管理所有的 API 路径
class ApiPaths {
  ApiPaths._();

  // 可访问后台列表
  static const String enableApi = "/end/enables";
  // 催收用户登录
  static const String loginApi = "/collector/login";
  // 催收成员信息
  static const String infoApi = "/collector/info";
  // 筛选-获取查询项
  static const String optionQueryApi = "/option/queries";
  // 正在催收
  static const String ongoingListApi = "/collection/list/ongoing";
  // 承诺还款
  static const String promiseListApi = "/collection/list/promise";
  // 已催列表
  static const String contactedListApi = "/collection/list/contacted";
  // 催收详情-用户信息
  static const String infoClientApi = "/collection/info/client";
  // 催收详情-订单详情
  static const String infoOrderApi = "/collection/info/order";
  // 催收详情-历史借款
  static const String infoHistoryApi = "/collection/info/loan_histories";
  // 获取还款链接
  static const String repaymentLinkApi = "/collection/repayment/link/list";
  // 获取放款方式
  static const String repaymentMethodApi = "/collection/repayment/methods";
  // 生成还款链接
  static const String generateRepaymentApi = "/collection/repayment/link/generate";
  // 获取催记列表
  static const String reminderListApi = "/collection/reminder/list";
  // 催记单选项
  static const String addCollectOptionsApi = "/option/reminder/radios";
  // 添加催记
  static const String submitAddCollectApi = "/collection/reminder/add";
  // 获取短信模版
  static const String smsTemplateApi = "/sms/collectionTemplate";
  // 发送短信
  static const String sendSmsApi = "/sms/sendCollectionSms";
}
