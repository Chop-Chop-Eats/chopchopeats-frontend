# 项目架构重构说明

## 概述

本项目已成功重构为分层架构模式，将代码组织到 `src` 目录中，并建立了清晰的层次结构。

## 目录结构

```
lib
├─ main.dart                      // 应用入口，仅用于配置环境和调用 AppBootstrap
└─ src                            // 所有核心源码都在这里
   ├─ app.dart                     // 根 Widget (App class)
   ├─ app_bootstrap.dart           // 应用启动引导程序
   ├─ app_services.dart            // 应用服务管理（将逐步迁移到 Riverpod）
   │
   ├─ core                         // 核心/共享模块 (应用无关的底层能力)
   │  ├─ config                    // 环境配置
   │  │  ├─ app_config.dart
   │  │  ├─ app_environment.dart
   │  │  ├─ environment_config.dart
   │  │  └─ app_setting.dart
   │  ├─ constants                 // 常量定义
   │  │  ├─ app_constant.dart
   │  │  └─ cache_constant.dart
   │  ├─ error                     // 错误和异常处理
   │  │  └─ error_handler.dart
   │  ├─ l10n                      // 本地化文件
   │  │  ├─ app_localizations.dart
   │  │  ├─ app_localizations_en.dart
   │  │  └─ app_localizations_zh.dart
   │  ├─ network                   // 网络层封装
   │  │  ├─ api_client.dart
   │  │  ├─ api_exception.dart
   │  │  ├─ api_interceptors.dart
   │  │  ├─ api_response.dart
   │  │  ├─ crypto_service.dart
   │  │  ├─ header_provider.dart
   │  │  ├─ http.dart
   │  │  ├─ api_paths.dart
   │  │  └─ api_client_provider.dart
   │  ├─ routing                   // 路由管理
   │  │  ├─ router.dart
   │  │  ├─ routes.dart
   │  │  └─ navigate.dart
   │  ├─ theme                     // 主题配置
   │  │  └─ app_theme.dart
   │  ├─ utils                     // 通用工具
   │  │  ├─ logger/
   │  │  │  ├─ logger.dart
   │  │  │  ├─ log_filter.dart
   │  │  │  ├─ log_output.dart
   │  │  │  └─ log_types.dart
   │  │  └─ translate_methods.dart
   │  └─ widgets                   // 全局共享的通用组件
   │     └─ logo.dart
   │
   ├─ data                         // 数据层
   │  ├─ datasources               // 数据源 (与具体实现绑定)
   │  │  ├─ local                  // 本地数据源
   │  │  │  └─ cache_service.dart   // 缓存服务的具体实现
   │  │  └─ remote                 // 远程数据源
   │  │     └─ user_api_service.dart // 用户相关 API 服务
   │  ├─ models                    // 数据模型
   │  │  └─ user_model.dart        // 用户数据模型
   │  └─ repositories              // 数据仓库
   │     └─ user_repository.dart   // 用户仓库
   │
   └─ features                     // 功能模块
      ├─ common_widgets            // 功能模块间共享的业务组件
      │  └─ custom_bottom_nav_bar.dart
      ├─ splash                    // 闪屏页
      │  └─ presentation
      │     └─ pages
      │        └─ splash_page.dart
      ├─ auth                      // 认证模块 (原 login)
      │  └─ presentation
      │     ├─ pages
      │     │  └─ login_page.dart
      │     └─ providers           // 状态管理 (Riverpod, Bloc, etc.)
      ├─ home                      // 主页模块
      │  └─ presentation
      │     ├─ pages
      │     │  └─ home_page.dart
      │     └─ widgets             // home 模块内部使用的组件
      ├─ mine                      // 我的页面模块
      │  └─ presentation
      │     ├─ pages
      │     │  └─ mine_page.dart
      │     └─ widgets
      ├─ main_screen.dart          // 主屏幕
      └─ error_page.dart          // 错误页面
```

## 架构优势

### 1. 清晰的分层结构
- **Core 层**: 提供基础设施和共享能力
- **Data 层**: 处理所有数据相关逻辑
- **Features 层**: 实现具体的业务功能

### 2. 依赖注入
- 使用 Riverpod 替代静态服务定位器
- 依赖关系明确，易于测试和维护
- 自动管理服务生命周期

### 3. 数据层设计
- **Repository 模式**: 为上层提供统一的数据访问接口
- **数据源分离**: 本地和远程数据源职责明确
- **缓存策略**: 智能的缓存机制，提升用户体验

### 4. 模块化设计
- 每个功能模块独立，便于团队协作
- 清晰的模块边界，降低耦合度
- 支持按需加载和懒加载

## 迁移指南

### 从旧架构迁移
1. **更新 Import 路径**: 所有文件都已更新为新的相对路径
2. **使用 Provider**: 逐步将 AppServices 中的静态服务迁移到 Riverpod Provider
3. **数据访问**: 通过 Repository 访问数据，而不是直接调用 API 服务

### 开发新功能
1. **创建数据模型**: 在 `data/models/` 中定义数据结构
2. **实现数据源**: 在 `data/datasources/` 中实现具体的数据获取逻辑
3. **创建仓库**: 在 `data/repositories/` 中协调数据源
4. **实现 UI**: 在 `features/` 中实现具体的业务逻辑和界面

## 最佳实践

### 1. 依赖注入
```dart
// 在 Widget 中使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRepository = ref.watch(userRepositoryProvider);
    // 使用 userRepository
  }
}
```

### 2. 错误处理
```dart
// 统一的错误处理
try {
  final user = await userRepository.getUser(userId);
} catch (e) {
  ErrorHandler.handle(e, context);
}
```

### 3. 缓存策略
```dart
// Repository 自动处理缓存
final user = await userRepository.getUser(userId);
// 优先从缓存获取，网络失败时使用缓存数据
```

## 下一步计划

1. **完善 Provider**: 为所有服务创建对应的 Provider
2. **状态管理**: 为每个功能模块添加状态管理
3. **测试覆盖**: 添加单元测试和集成测试
4. **文档完善**: 补充 API 文档和使用示例

## 注意事项

- 所有新的 import 路径都已更新
- 部分 Provider 需要进一步完善（如 SharedPreferences）
- 建议逐步迁移，避免一次性大改动
- 保持向后兼容性，确保现有功能正常工作
