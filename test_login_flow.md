# 登录流程测试说明

## 🎯 测试目标

验证重构后的登录流程是否正常工作，包括：
1. 日志系统使用 `dart:developer` 的 `log` 工具
2. 模拟网络接口正常工作
3. 认证状态管理正确
4. 页面跳转逻辑正确

## 🚀 测试步骤

### 1. 启动应用
- 应用启动后会显示闪屏页面
- 观察控制台日志输出，应该看到：
  ```
  [SplashPage] INFO: 闪屏页面已初始化
  [SplashPage] INFO: 开始应用初始化
  ```

### 2. 闪屏页面逻辑
- 等待 2 秒的初始化延迟
- 检查认证状态（此时应该未登录）
- 自动跳转到登录页面
- 控制台应该看到：
  ```
  [SplashPage] DEBUG: 初始化延迟完成，检查认证状态
  [SplashPage] INFO: 用户未登录，跳转到登录页
  [SplashPage] DEBUG: 准备跳转到登录页
  ```

### 3. 登录页面
- 显示登录表单，包含用户名和密码输入框
- 默认填充测试账号：`admin` / `123456`
- 点击登录按钮开始登录流程
- 控制台应该看到：
  ```
  [LoginPage] INFO: 开始处理登录
  [AuthNotifier] INFO: 开始登录流程: username=admin
  [AuthRepo] INFO: 开始登录流程: username=admin
  [AuthAPI] INFO: 开始登录请求: username=admin
  [AuthAPI] INFO: 登录成功: username=admin
  [AuthRepo] INFO: 登录成功，用户数据已缓存
  [AuthNotifier] INFO: 登录成功: admin
  [LoginPage] INFO: 登录成功，准备跳转
  ```

### 4. 登录成功后的跳转
- 登录成功后自动跳转到主页
- 用户信息保存在模拟的本地存储中

### 5. 测试其他场景

#### 5.1 错误密码
- 使用错误的密码（如：`admin` / `wrong`）
- 应该显示错误信息："用户名或密码错误"
- 控制台应该看到：
  ```
  [AuthAPI] WARN: 用户名或密码错误: username=admin
  [AuthRepo] WARN: 登录失败: 用户名或密码错误
  [AuthNotifier] WARN: 登录失败: 用户名或密码错误
  ```

#### 5.2 空用户名或密码
- 清空用户名或密码字段
- 点击登录应该显示表单验证错误

#### 5.3 网络异常
- 可以修改 `AuthApiService` 中的逻辑来模拟网络异常
- 观察错误处理和日志输出

## 🔍 日志验证

### 日志等级
- **DEBUG**: 详细的调试信息
- **INFO**: 重要的流程信息
- **WARN**: 警告信息
- **ERROR**: 错误信息

### 日志格式
```
[TAG] LEVEL: message
```

### 日志输出位置
- 使用 `dart:developer` 的 `log` 工具
- 在 Flutter 开发工具的控制台中查看
- 支持按日志等级过滤

## 🛠️ 技术实现

### 1. 日志系统
- 使用 `dart:developer` 替代 `print` 语句
- 支持四个日志等级：debug、info、warn、error
- 移除了复杂的过滤器和颜色代码

### 2. 模拟网络接口
- `AuthApiService`: 模拟认证 API
- 支持登录、登出、刷新 token
- 模拟网络延迟和错误情况

### 3. 数据层
- `AuthRepository`: 协调数据操作
- `CacheService`: 抽象化的本地存储
- `MockSharedPreferences`: 模拟的本地存储实现

### 4. 状态管理
- 使用 Riverpod 管理认证状态
- 支持登录、登出、状态检查等操作

### 5. UI 层
- `SplashPage`: 闪屏页面，检查认证状态
- `LoginPage`: 登录页面，处理用户输入
- 响应式设计，显示加载状态和错误信息

## 📱 测试账号

- **用户名**: `admin`
- **密码**: `123456`

## ⚠️ 注意事项

1. 这是一个模拟实现，不包含真实的网络请求
2. 本地存储使用内存模拟，应用重启后数据会丢失
3. 所有 API 调用都有 1 秒的模拟延迟
4. 日志输出在 Flutter 开发工具的控制台中查看

## 🎉 预期结果

成功测试后，你应该能够：
1. 看到完整的登录流程日志
2. 使用测试账号成功登录
3. 看到错误处理和表单验证
4. 体验流畅的页面跳转
5. 验证新的分层架构设计
