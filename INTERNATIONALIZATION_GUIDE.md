# 国际化实施指南

## 概述

本项目已成功实现国际化（i18n）功能，支持中文、英文两种语言，并提供三种语言模式：跟随系统、强制中文、强制英文。

## 已完成的工作

### 1. 基础设施

#### 1.1 语言模式枚举
**文件**: `lib/src/core/enums/language_mode.dart`
- 定义了三种语言模式：`system`（跟随系统）、`zh`（中文）、`en`（英文）
- 提供了 `fromString` 方法用于字符串转换
- 提供了 `displayName` 用于UI显示

#### 1.2 语言服务
**文件**: `lib/src/core/l10n/locale_service.dart`
- 提供全局的语言访问，供 Model 层使用
- 实现了 `getLocalizedText` 方法，支持中英文字段的兜底逻辑
- 当某个语言的文本为空时，自动回退到另一个语言

#### 1.3 语言状态管理
**文件**: `lib/src/core/providers/language_provider.dart`
- 基于 Riverpod 实现语言状态管理
- 提供 `languageProvider` 用于语言切换

### 2. 应用设置改造

#### 2.1 AppSettings 更新
**文件**: `lib/src/core/config/app_setting.dart`
- 将 `_locale` 改为 `_languageMode`
- 实现了 `updateLanguageMode` 方法
- 增加了 `locale` getter，根据语言模式返回对应的 Locale
- 默认语言模式改为 `system`（跟随系统）

#### 2.2 常量更新
**文件**: `lib/src/core/constants/app_constant.dart`
- 将 `languageCode` 改为 `languageMode`

### 3. App 配置

#### 3.1 App.dart 更新
**文件**: `lib/src/core/config/app.dart`
- 添加了 `localeResolutionCallback`，实现智能语言解析
- 强制模式时使用设置的语言
- 跟随系统模式时使用设备语言
- 默认使用中文
- 实时更新 `LocaleService`

### 4. Model 层国际化

为所有包含中英文字段的 Model 添加了本地化便捷属性：

#### 4.1 ChefItem
**文件**: `lib/src/features/home/models/home_models.dart`
- `localizedShopName`: 本地化的店铺名称
- `localizedCategoryName`: 本地化的分类名称

#### 4.2 CategoryListItem
**文件**: `lib/src/features/home/models/home_models.dart`
- `localizedCategoryName`: 本地化的分类名称

#### 4.3 ShopModel
**文件**: `lib/src/features/detail/models/detail_model.dart`
- `localizedShopName`: 本地化的店铺名称
- `localizedDescription`: 本地化的店铺介绍
- `localizedTagList`: 本地化的店铺标签列表

#### 4.4 SaleProduct
**文件**: `lib/src/features/detail/models/detail_model.dart`
- `localizedName`: 本地化的商品名称
- `localizedDescription`: 本地化的商品描述

#### 4.5 FavoriteItem
**文件**: `lib/src/features/heart/models/heart_models.dart`
- `localizedShopName`: 本地化的店铺名称
- `localizedCategoryName`: 本地化的分类名称

### 5. 应用文案国际化

#### 5.1 AppLocalizations 扩展
**文件**: `lib/src/core/l10n/app_localizations.dart`

新增文案分类：
- **底部导航**: tabHome, tabHeart, tabMessage, tabOrder, tabMine
- **通用按钮**: btnConfirm, btnCancel, btnSave, btnDelete, btnEdit, btnSearch, btnClear, btnViewAll
- **提示信息**: loadingText, noDataText, networkErrorText, emptyListText, tryAgainText
- **店铺相关**: distanceUnit, deliveryFee, operatingHours, rating, newShop, hotProduct, favorite, unfavorite
- **分类相关**: allCategories, selectedChef
- **搜索相关**: searchPlaceholder, searchHistory, hotSearchKeywords, clearHistory
- **详情页相关**: productDetail, shopIntroduction, addToCart, selectSpec, stock, price
- **语言设置**: languageSettings, languageSystem, languageChinese, languageEnglish

#### 5.2 中文实现
**文件**: `lib/src/core/l10n/app_localizations_zh.dart`
- 实现了所有文案的中文翻译

#### 5.3 英文实现
**文件**: `lib/src/core/l10n/app_localizations_en.dart`
- 实现了所有文案的英文翻译

### 6. UI 层更新

#### 6.1 我的页面
**文件**: `lib/src/features/mine/pages/mine_page.dart`
- 添加了简易的语言切换器
- 使用 RadioListTile 实现三种语言模式切换
- 使用 AppLocalizations 替换硬编码文案

#### 6.2 底部导航栏
**文件**: `lib/src/core/widgets/custom_bottom_nav_bar.dart`
- 所有导航标签使用 AppLocalizations
- 支持实时语言切换

## 使用指南

### 1. 在 UI 中使用国际化文案

```dart
// 获取 AppLocalizations 实例
final l10n = AppLocalizations.of(context)!;

// 使用文案
Text(l10n.tabHome)
Text(l10n.loadingText)
```

### 2. 在 Model 中使用本地化属性

```dart
// 使用 Model 的本地化属性
Text(chefItem.localizedShopName)
Text(chefItem.localizedCategoryName ?? '')
Text(shopModel.localizedDescription ?? '')
Text(product.localizedName)
```

### 3. 切换语言

用户可以在"我的"页面中切换语言：
1. 跟随系统：使用设备系统语言
2. 中文：强制使用中文
3. English：强制使用英文

切换后无需重启应用，界面会立即更新。

## 技术细节

### 语言切换流程

1. 用户在 Mine Page 选择语言模式
2. 调用 `AppServices.appSettings.updateLanguageMode(mode)`
3. AppSettings 更新语言模式并持久化
4. AppSettings 通知监听者（通过 ChangeNotifier）
5. App.dart 的 AnimatedBuilder 重新构建
6. MaterialApp 的 locale 属性更新
7. localeResolutionCallback 被调用
8. LocaleService 更新当前语言
9. 所有使用 AppLocalizations 和 Model 本地化属性的 UI 自动更新

### Model 层本地化策略

使用 `LocaleService.getLocalizedText(zhText, enText)` 方法：
- 当前语言为中文时：优先返回中文，中文为空则返回英文兜底
- 当前语言为英文时：优先返回英文，英文为空则返回中文兜底

这样即使后端某些字段缺失，前端也能正常显示内容。

### 性能优化

- 语言切换不重新请求接口，只切换已加载数据的显示
- 使用 AnimatedBuilder 实现响应式更新，避免全局重建
- LocaleService 使用静态变量缓存当前语言，避免重复计算

## 待完成的工作

虽然基础设施已经完备，但以下页面的硬编码文案仍需替换为国际化文案：

### 需要更新的页面

1. **Home 相关**
   - `lib/src/features/home/pages/home_page.dart`
   - `lib/src/features/home/widgets/*.dart`

2. **搜索相关**
   - `lib/src/features/search/pages/search_page.dart`
   - `lib/src/features/search/widgets/*.dart`

3. **详情页相关**
   - `lib/src/features/detail/pages/detail_page.dart`
   - `lib/src/features/detail/widgets/*.dart`

4. **收藏页相关**
   - `lib/src/features/heart/pages/heart_page.dart`
   - `lib/src/features/heart/widgets/*.dart`

5. **订单和消息页面**
   - `lib/src/features/order/pages/order_page.dart`
   - `lib/src/features/message/pages/message_page.dart`

6. **认证相关**
   - `lib/src/features/auth/pages/*.dart`

### 更新方法

#### 步骤 1: 替换硬编码文案

```dart
// 旧代码
Text('首页')

// 新代码
final l10n = AppLocalizations.of(context)!;
Text(l10n.tabHome)
```

#### 步骤 2: 使用 Model 本地化属性

```dart
// 旧代码
Text(chefItem.chineseShopName)

// 新代码
Text(chefItem.localizedShopName)
```

```dart
// 旧代码
Text(categoryItem.categoryName ?? '')

// 新代码
Text(categoryItem.localizedCategoryName ?? '')
```

## 扩展国际化文案

如果需要添加新的国际化文案：

1. 在 `lib/src/core/l10n/app_localizations.dart` 中添加新的 getter
2. 在 `lib/src/core/l10n/app_localizations_zh.dart` 中实现中文翻译
3. 在 `lib/src/core/l10n/app_localizations_en.dart` 中实现英文翻译

示例：

```dart
// app_localizations.dart
String get newFeature;

// app_localizations_zh.dart
@override
String get newFeature => '新功能';

// app_localizations_en.dart
@override
String get newFeature => 'New Feature';
```

## 测试建议

1. **语言切换测试**
   - 测试三种语言模式的切换
   - 验证切换后界面立即更新
   - 验证持久化（重启应用后语言设置保持）

2. **兜底逻辑测试**
   - 测试某些字段为空时是否正确显示兜底语言

3. **系统语言测试**
   - 测试跟随系统模式在不同系统语言下的表现

4. **页面覆盖测试**
   - 逐个测试各个页面的国际化显示

## 注意事项

1. 所有新增的 UI 文案都应使用 AppLocalizations，不要硬编码
2. 所有使用 Model 中中英文字段的地方都应改为使用本地化属性
3. 语言切换不应触发接口重新请求（性能优化）
4. 如果接口字段缺失，前端会自动使用另一个语言兜底

## 总结

国际化基础设施已经全部完成，包括：
- ✅ 三种语言模式（跟随系统/中文/英文）
- ✅ Model 层国际化便捷属性
- ✅ 应用文案国际化字典
- ✅ 语言切换 UI（我的页面）
- ✅ 底部导航栏国际化示例
- ✅ 响应式语言更新机制

接下来只需要按照本指南逐步将其他页面的硬编码文案替换为国际化文案即可。

