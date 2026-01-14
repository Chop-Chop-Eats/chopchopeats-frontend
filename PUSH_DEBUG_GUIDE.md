# 推送消息接收问题排查指南

## 问题现象
Token 上报成功，但收不到推送消息。其他设备（相同账号）可以收到消息，说明后端推送正常。

## 快速排查步骤

### 1. 检查推送服务状态
在应用中调用调试方法（可以在开发者菜单或测试页面添加按钮）：
```dart
await PushService().printDebugInfo();
```

查看日志输出，确认：
- ✅ Firebase 已初始化
- ✅ 有 FCM Token
- ✅ 通知权限已授权
- ✅ 用户已登录

### 2. 使用 Firebase Console 测试

**重要**：这可以排除后端问题，验证 FCM 本身是否工作。

1. 打开 [Firebase Console](https://console.firebase.google.com/)
2. 选择项目 `chop-chop-app-473015`
3. 进入 **Cloud Messaging** → **Send your first message**
4. 填写通知内容：
   - 标题：`测试消息`
   - 文本：`这是一条测试消息`
5. 点击 **Send test message**
6. 粘贴从日志中获取的 FCM Token
7. 点击 **Test**

**预期结果**：
- 前台运行：应立即看到通知
- 后台运行：系统通知栏显示通知
- 已终止：系统通知栏显示通知

**如果 Firebase Console 测试成功**：
- ✅ FCM 配置正确
- ✅ 设备可以接收推送
- ❌ 问题在后端推送的消息格式

**如果 Firebase Console 测试失败**：
- 继续下面的排查步骤

### 3. iOS 特定检查

#### 3.1 检查 APNs 证书（最常见问题）
```bash
# 检查 entitlements 文件
cat ios/Runner/Runner.entitlements
```

应该包含：
```xml
<key>aps-environment</key>
<string>development</string>  <!-- 开发环境 -->
<!-- 或 -->
<string>production</string>    <!-- 生产环境 -->
```

#### 3.2 检查 Xcode 配置
1. 打开 `ios/Runner.xcworkspace`
2. 选择 Runner target
3. **Signing & Capabilities** 标签
4. 确认有 **Push Notifications** capability
5. 确认 Team 和 Provisioning Profile 已配置

#### 3.3 检查是否在模拟器上测试
**⚠️ iOS 模拟器不支持真实的推送通知！**

必须使用真机测试：
```bash
flutter run -d <your-device-id>
```

查看可用设备：
```bash
flutter devices
```

#### 3.4 重新注册 APNs
有时需要重置 APNs 注册：
```bash
# 1. 完全卸载应用
# 2. 清理构建
flutter clean
# 3. 重新安装
flutter run -d <your-device-id>
```

### 4. Android 特定检查

#### 4.1 检查 google-services.json
```bash
cat android/app/google-services.json | grep project_id
cat android/app/google-services.json | grep package_name
```

确认：
- `project_id` 应该是 `chop-chop-app-473015`
- `package_name` 应该与 `android/app/build.gradle.kts` 中的 `applicationId` 一致

#### 4.2 检查通知权限（Android 13+）
在设备上手动检查：
1. 设置 → 应用 → Chop User
2. 通知 → 确认已允许

#### 4.3 检查 Google Play Services
```bash
# 在真机上运行，确保安装了 Google Play Services
adb shell pm list packages | grep google
```

### 5. 后端消息格式检查

**关键**：后端必须同时发送 `notification` 和 `data` 字段！

#### 正确的消息格式：
```json
{
  "message": {
    "token": "设备的FCM Token",
    "notification": {
      "title": "订单更新",
      "body": "您的订单已完成"
    },
    "data": {
      "messageId": "123",
      "messageTypeId": "1",
      "orderId": "ORDER123",
      "title": "订单更新",
      "body": "您的订单已完成"
    },
    "apns": {
      "payload": {
        "aps": {
          "alert": {
            "title": "订单更新",
            "body": "您的订单已完成"
          },
          "sound": "default",
          "badge": 1
        }
      }
    },
    "android": {
      "notification": {
        "sound": "default",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    }
  }
}
```

#### 错误的消息格式（只有 data）：
```json
{
  "message": {
    "token": "设备的FCM Token",
    "data": {
      "messageId": "123",
      "messageTypeId": "1"
    }
  }
}
```
❌ 这种格式在后台/终止状态下**不会显示通知**！

### 6. 网络环境检查

#### 6.1 中国大陆网络问题
- FCM 在中国大陆可能无法访问
- 需要使用 VPN 或企业网络
- APNs（iOS）也可能受影响

#### 6.2 企业/学校网络
- 某些网络可能屏蔽推送服务端口
- 尝试切换到移动数据网络测试

### 7. 日志分析

#### 7.1 查看完整日志（iOS）
```bash
# 使用 Xcode 查看设备日志
# Xcode → Window → Devices and Simulators → 选择设备 → Open Console
```

搜索关键词：
- `PushService`
- `FCM`
- `APNS`
- `FirebaseMessaging`

#### 7.2 查看完整日志（Android）
```bash
# 实时查看
adb logcat | grep -E "PushService|FCM|FirebaseMessaging"

# 保存到文件
adb logcat -d > logcat.txt
```

#### 7.3 关键日志标记

**成功的日志应该包含**：
```
✅ 推送服务初始化完成！
✅ 前台消息监听器已注册
✅ Token 上报成功
```

**收到消息时的日志**：
```
🔔 前台收到消息: <messageId>
或
🔔 后台消息收到: <messageId>
```

**如果没有看到这些日志**：
- 消息没有到达设备
- 检查 FCM Token 是否正确
- 检查后端是否真的发送了消息

### 8. 对比其他设备

既然其他设备可以收到消息，对比以下信息：

| 项目 | 工作的设备 | 问题设备 |
|------|-----------|---------|
| 操作系统 | ? | ? |
| 系统版本 | ? | ? |
| 网络环境 | ? | ? |
| 构建版本 | ? | ? |
| FCM Token | ? | ? |
| 登录账号 | 相同 | 相同 |

找出差异点可能是问题关键。

## 常见原因总结

### iOS
1. **APNs 证书未配置或过期**（最常见）
2. **使用模拟器测试**（模拟器不支持真实推送）
3. **Push Notifications capability 未添加**
4. **网络无法访问 APNs**（中国大陆）
5. **Provisioning Profile 不匹配**

### Android
1. **google-services.json 配置错误**
2. **SHA-1 证书指纹未添加到 Firebase**
3. **Google Play Services 未安装或版本过低**
4. **通知权限被拒绝**（Android 13+）
5. **网络无法访问 FCM**

### 后端
1. **只发送 data 没有 notification**（最常见）
2. **Token 过期或无效**
3. **消息格式错误**
4. **服务端网络问题**

## 下一步操作

1. **调用 `PushService().printDebugInfo()`** 查看当前状态
2. **使用 Firebase Console 发送测试消息** 验证 FCM 是否工作
3. **检查设备类型** 确保不是在模拟器上测试
4. **对比日志** 查看工作设备和问题设备的日志差异
5. **联系后端** 确认消息格式包含 `notification` 字段

## 获取帮助

提供以下信息可以更快定位问题：
1. 操作系统和版本（iOS 17.x / Android 13）
2. 设备类型（真机/模拟器）
3. 网络环境（WiFi/移动网络/VPN）
4. `printDebugInfo()` 的完整输出
5. Firebase Console 测试结果
6. 应用日志（至少包含 PushService 相关的部分）
7. 后端发送的消息格式示例
