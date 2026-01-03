# iOS Firebase 配置信息

## 📱 iOS 应用配置信息

在 Firebase Console 创建 iOS 应用时，请使用以下信息：

### 必填信息

| 配置项 | 值 |
|--------|-----|
| **Bundle ID (iOS 软件包名称)** | `com.chop.chopUser` |
| **应用昵称（可选）** | `ChopChop Eats User` |
| **App Store ID（可选）** | 暂无（开发阶段可不填） |

### 应用详细信息

- **显示名称**: Chop User
- **内部名称**: chop_user
- **开发团队**: AAQMRZ72PQ
- **版本号**: 1.0.0+2

## 🔧 Firebase Console 配置步骤

### 1. 访问 Firebase Console
```
https://console.firebase.google.com/
```

### 2. 选择项目
- 如果已有项目：选择 "ChopChop Eats" 项目
- 如果没有项目：先创建新项目

### 3. 添加 iOS 应用

1. 点击项目概览页面的 **iOS 图标** 或 "添加应用"
2. 填写以下信息：
   ```
   iOS 软件包名称: com.chop.chopUser
   应用昵称: ChopChop Eats User (可选)
   App Store ID: (留空，开发阶段不需要)
   ```
3. 点击 "注册应用"

### 4. 下载配置文件

1. 下载 `GoogleService-Info.plist` 文件
2. **重要**: 不要修改文件名
3. 将文件保存到电脑上

### 5. 添加配置文件到项目

**方法一：使用 Xcode（推荐）**
```bash
# 1. 打开 Xcode 项目
open ios/Runner.xcworkspace

# 2. 在 Xcode 中：
#    - 在左侧项目导航栏找到 "Runner" 文件夹
#    - 右键点击 "Runner" -> "Add Files to Runner..."
#    - 选择下载的 GoogleService-Info.plist 文件
#    - ✅ 勾选 "Copy items if needed"
#    - ✅ 勾选 "Runner" target
#    - 点击 "Add"
```

**方法二：手动复制**
```bash
# 复制文件到项目目录
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

### 6. 验证配置

重新运行应用：
```bash
flutter run -d <device-id>
```

成功标志：
- ✅ 不再出现 "Could not locate configuration file" 错误
- ✅ 看到 "Firebase 初始化完成" 日志
- ✅ 推送服务初始化成功

## 📋 Android 配置信息（已配置）

Android 的 Firebase 配置文件已存在：
```
✅ android/app/google-services.json
```

## ⚠️ 常见问题

### Q1: Bundle ID 在哪里确认？
A: 在以下位置可以看到：
- Xcode: Runner -> Signing & Capabilities -> Bundle Identifier
- 配置文件: `ios/Runner.xcodeproj/project.pbxproj` 搜索 `PRODUCT_BUNDLE_IDENTIFIER`
- 当前值: `com.chop.chopUser`

### Q2: 为什么需要配置文件？
A: `GoogleService-Info.plist` 包含：
- Firebase 项目 ID
- API 密钥
- Bundle ID 映射
- 推送通知配置

### Q3: 可以暂时不配置吗？
A: 可以！应用已经修改为可以在没有 Firebase 配置的情况下运行，只是推送功能不可用。

## 🔐 安全提示

- ⚠️ `GoogleService-Info.plist` 包含敏感信息
- 建议添加到 `.gitignore`（如果是私有仓库可以提交）
- 不要将配置文件分享到公开渠道

## 📚 参考文档

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Apple Push Notifications](https://developer.apple.com/documentation/usernotifications)

