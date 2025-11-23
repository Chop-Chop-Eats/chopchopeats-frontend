
# TODO

1. [ ] 店铺详情与商品详情数据串联：按顺序调用 `getShopApi`、`getSaleProductListApi`、`getAvailableCouponListApi`、配送时间相关接口，并把结果映射到 UI。
2. [ ] 全局购物车状态管理：基于 `OrderServices` 构建跨页面共享的 provider，维护 shopId+diningDate 粒度的 items、费用、优惠券等数据结构。
3. [ ] 购物车 UI 串接：`shop_cart.dart` 订阅全局状态，支持数量角标、总价/配送费展示、列表弹窗、清空按钮联动 `clearCartApi`。
4. [ ] 购物车操作闭环：SKU 操作调用 `addCartApi`/`updateCartQuantityApi` 并及时刷新 `getCartListApi`，确保商品卡与购物车同步。
5. [ ] 下单流程确认页：汇总购物车条目与配送信息，组装 `CreateOrderParams` 调用 `createOrderApi`，并在成功后触发 SPI 创建。
6. [ ] 支付与结果：调用 `createSPIApi` 接入 Stripe 支付，处理成功/失败状态并在完成后清理/刷新购物车。
7. [ ] 跨店铺下单策略（等待业务确认，暂定状态，收到结论后再决定是否允许跨店铺合并订单）。

思路梳理
先梳理已经具备的接口、模型与 UI 占位，搞清楚哪些数据可以直接复用，哪些需要全局状态管理补齐。
核心流程分成三段：店铺/商品详情加载 → 全局购物车管理（跨店铺、跨日期） → 下单与支付。每段明确输入/输出以及依赖的 API 即可串联。
目前 ShopCart 组件只是静态 UI，需要在全局状态与服务层打通后才能真正串起数量、金额、弹窗列表与下单按钮。
已有资源定位
API 地址均集中在 lib/src/core/network/api_paths.dart，订单与购物车相关接口完备，可直接配合服务层调用。
api_paths.dartLines 109-135
  // [订单模块]  // 创建交易订单  static const String createOrderApi = "/app-api/trade/app-order/create";  // 添加购物车  static const String addCartApi = "/app-api/trade/cart/add";  // 获取购物车列表  static const String getCartListApi = "/app-api/trade/cart/list";  // 清空购物车  static const String clearCartApi = "/app-api/trade/cart/clear";  // 更新购物车商品数量  static const String updateCartQuantityApi = "/app-api/trade/cart/update-quantity";  // 创建 Stripe PaymentIntent  static const String createSPIApi = "/app-api/trade/stripe-payment-intent/create";  // 计算配送预估费用  static const String getDeliveryFeeEstimateApi = "/app-api/merchant/geocoding/test/delivery-fee-estimate";  // 获取可配送时间列表  static const String getAvailableDeliveryTimesApi = "/app-api/merchant/shop/available-delivery-times";  // 检查当前是否在配送时间范围内  static const String checkDeliveryTimeApi = "/app-api/merchant/shop/check-delivery-time";
OrderServices 已封装以上接口，直接提供添加/查询购物车、下单、支付、配送费用等方法，可作为全局购物车仓库的数据源。
order_services.dartLines 6-90
class OrderServices {  Future<void> createOrder(CreateOrderParams params) async { ... }  Future<void> addCart(AddCartParams params) async { ... }  Future<List<CartItemModel>> getCartList(GetCartListQuery query) async { ... }  Future<void> clearCart(String shopId  , String diningDate) async { ... }  Future<void> updateCartQuantity(UpdateCartParams params) async { ... }  Future<SPIModel> createSPI(String orderNo ) async { ... }  Future<DeliveryFeeModel> getDeliveryFee(DeliveryFeeQuery query) async { ... }}
订单模型 CreateOrderParams、OrderItem、AddCartParams 等已经准备好，后续只需把 UI/Provider 收集到的数据填进去。
order_model.dartLines 147-354
class AddCartParams { ... }class GetCartListQuery { ... }class UpdateCartParams { ... }class CartItemModel { ... }class SPIModel { ... }class DeliveryFeeQuery { ... }class DeliveryFeeModel { ... }
ShopCart 组件目前只显示静态金额/数量，需要接入全局状态（数量、总价、配送费、列表、清空逻辑、下单跳转等）。
shop_cart.dartLines 12-170
class ShopCart extends StatefulWidget { ... }Future<void> _openCartSheet() async { ... } // 仅展示静态文本与 TODO 注释Widget _buildPriceInfo(...) { ... } // 金额与配送费写死Widget _buildOrder(...) { ... } // 点击只打印日志
TODO.md 为空，可后续把规划拆成可执行任务。
功能/需求拆解
店铺详情：使用 getShopApi 获取 ShopModel，展示基础信息、配送能力、税率、服务费等；getAvailableDeliveryTimesApi/checkDeliveryTimeApi 用于判定当前能否下单。
商品详情与 SKU：getSaleProductListApi 返回商品与 SKU 详情（SaleProductModel、SaleProductSku），供商品列表与 SKU 选择弹窗使用。
优惠券：getAvailableCouponListApi 获取该店铺可领取的券，购物车/下单时可选择抵扣。
全局购物车：需要跨页面、跨店铺共享数据。服务层已经具备增删改查，缺状态管理与 UI 绑定。
订单创建：整合同一店铺同一日期的购物车条目、配送信息、优惠券、费用等，调用 createOrderApi。
支付：下单后调用 createSPIApi 拿到 clientSecret 等信息，走 Stripe SDK 流程。
物流费用：根据地址与店铺坐标调用 getDeliveryFeeEstimateApi，实时回写到购物车/下单页。
全局购物车设计建议
状态容器：在 lib/src/features/detail/providers/（或更高层全局 providers 文件夹）创建 CartState + CartNotifier（Riverpod/Provider 均可），内部结构建议 Map<String(shopId), Map<String(diningDate), CartState>>。这样既支持跨店铺，也能保证同店铺同日期的条目可单独下单。
数据源：CartNotifier 只通过 OrderServices 读写远端；初始化时根据当前用户最近访问过的店铺调用 getCartList，或在用户切换店铺/日期时懒加载。
缓存策略：维护 CartState（items、subtotal、serviceFee、tax、deliveryFee、coupon、可下单状态等）+ lastSyncedAt。所有 UI（详情页商品卡、全局悬浮购物车、下单页）观察相同 provider。
跨店铺策略：若业务允许跨店铺拼单，在全局 state 中额外维护 globalSelection（多店铺 items 列表 + 分摊配送费策略）。若后端限制 “一次下单只能同店铺”，则 UI 层要在用户跨店铺添加时提示“是否切换店铺并清空当前购物车”。
本地回显：ShopCart 需要订阅 provider，显示实时数量、金额、配送费；底部弹窗遍历 CartState.items 渲染 _buildSheetItem，按钮点击时触发 createOrder。
错误处理：把 OrderServices 的异常往上抛给 provider，由 provider 统一转为 UI 可识别的状态（loading/error/snackbar）。
无第三方库：沿用现有 Provider/Riverpod 体系，或使用已有 providers 文件夹模式，不引入额外依赖。
接口调用顺序建议
进入店铺详情
getShopApi → 渲染店铺信息、配送方式。
getSaleProductListApi（根据 周几 或 用餐日期）→ 渲染商品与 SKU。
getAvailableCouponListApi → 提示可领取/可用优惠券。
getAvailableDeliveryTimesApi + checkDeliveryTimeApi → 决定下单按钮是否可用、时间选择器候选。
如果用户已有购物车记录：getCartListApi（以 shopId + diningDate 查询）→ 更新底部购物车、商品卡数量。
商品加入购物车
用户选定 SKU/数量后构造 AddCartParams。
调用 addCartApi。
成功后立即调用 getCartListApi 以 shopId + diningDate 刷新本地 state，并更新 ShopCart UI。
若同 SKU 再次添加，可直接在本地 state 加数量同时调用 updateCartQuantityApi，减少列表全量刷新频次。
用户点击清空按钮时 → clearCartApi（需带上 shopId + diningDate），成功后清空 provider 状态。
购物车更新/结算准备
在购物车页或弹窗中变更数量 → updateCartQuantityApi，本地 state 先行更新、失败再回滚。
获取配送费：把用户当前地址经纬度与 shopId 传给 getDeliveryFeeEstimateApi，结果写入 CartState.deliveryFee。
若需要监控配送时间变动，定时或在用户选定时间后调用 checkDeliveryTimeApi 校验。
选择优惠券后更新 CartState.coupon 并重新计算 payAmount、serviceFee、taxAmount 等。
下单与支付
汇总当前店铺 + diningDate 的购物车条目，转成 List<OrderItem>（字段来自 CartItemModel）。
组装 CreateOrderParams（包含配送方式/地址/时间/费用/优惠券），调用 createOrderApi。
拿到 orderNo 后立即调用 createSPIApi，取得 clientSecret 等 Stripe 信息交给支付 SDK。
支付完成后根据后端回调或轮询刷新订单状态，必要时 clearCartApi 清空对应购物车。
显示结果页/错误提示，并更新全局订单/购物车 provider。