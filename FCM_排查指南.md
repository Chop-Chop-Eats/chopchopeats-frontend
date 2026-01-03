# FCM 通知接收问题排查指南

## 📋 排查步骤

### 第一步：确认 Token 上报状态

**查看日志**：
```bash
adb logcat | grep "PushService"
```

**检查点**：
- [ ] 是否看到 `✅ Token 上报成功` 日志？
- [ ] 如果看到 `❌ Token 上报失败`，检查网络连接和 API 接口

**如果没有看到 Token 上报成功的日志**：
- Token 可能没有成功上报到后端
- 后端使用的 Token 可能是旧的
- 需要重新获取 Token 并确认上报成功

---

### 第二步：确认后端推送的消息格式

**关键问题**：后端推送的消息**必须包含 `notification` 字段**，否则在后台/终止状态下系统不会显示通知！

**正确的消息格式**（参考 `FIREBASE_FCM_IMPLEMENTATION_GUIDE.md`）：
```json
{
  "notification": {
    "title": "消息标题",
    "body": "消息内容"
  },
  "data": {
    "title": "消息标题",
    "body": "消息内容",
    "messageId": "消息ID",
    "messageTypeId": "1",
    "contentType": "订单消息",
    "orderId": "ORDER123",
    "shopId": "SHOP456"
  }
}
```

**只有 `data` 字段的问题**：
- ❌ 应用在前台：可以接收到（通过 `onMessage`），但需要手动显示本地通知
- ❌ 应用在后台：系统**不会自动显示通知**
- ❌ 应用已终止：系统**不会自动显示通知**

**同时包含 `notification` 和 `data` 字段**：
- ✅ 应用在前台：通过 `onMessage` 接收，可以手动显示本地通知
- ✅ 应用在后台：系统**自动显示通知**
- ✅ 应用已终止：系统**自动显示通知**

**请与后端确认**：
1. 推送的消息是否包含 `notification` 字段？
2. 如果只有 `data` 字段，需要添加 `notification` 字段

---

### 第三步：测试不同应用状态下的消息接收

#### 3.1 前台测试

1. **保持应用在前台运行**
2. **发送测试消息**
3. **查看日志**：
   ```bash
   adb logcat | grep "PushService"
   ```
4. **预期日志**：
   - `🔔 前台收到消息: xxx`
   - `准备显示通知: title=xxx, body=xxx`
   - `✅ 通知已发送，ID: xxx`

5. **如果没有看到 `🔔 前台收到消息`**：
   - 检查 `FirebaseMessaging.onMessage.listen` 是否正常注册
   - 检查后端推送的 Token 是否正确
   - 检查网络连接

#### 3.2 后台测试

1. **将应用切换到后台**（按 Home 键）
2. **发送测试消息**
3. **预期结果**：
   - 系统通知栏应该显示通知
   - 如果看到通知 → 说明消息格式正确，FCM 配置正常
   - 如果没有看到通知 → 检查消息格式（必须有 `notification` 字段）

4. **查看日志**（应用切换到前台后）：
   ```bash
   adb logcat | grep "PushService"
   ```
   - 应该看到 `🔔 后台消息收到: xxx`（如果应用在后台）

#### 3.3 终止状态测试

1. **完全关闭应用**（从任务管理器移除）
2. **发送测试消息**
3. **预期结果**：
   - 系统通知栏应该显示通知
   - 点击通知后应用启动
   - 应用启动后处理初始消息（通过 `getInitialMessage`）

4. **查看日志**（应用启动后）：
   ```bash
   adb logcat | grep "PushService"
   ```

---

### 第四步：检查 Android 配置

#### 4.1 检查 `google-services.json`

```bash
# 确认文件存在
ls -la android/app/google-services.json

# 检查文件内容（确认包名是否正确）
cat android/app/google-services.json | grep package_name
```

- [ ] 文件是否存在？
- [ ] 文件中的 `package_name` 是否与 `build.gradle.kts` 中的 `applicationId` 一致？

#### 4.2 检查 SHA-1 证书指纹

**获取 SHA-1**：
```bash
# Debug 版本
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release 版本（如果使用自定义密钥）
keytool -list -v -keystore <你的密钥库路径> -alias <你的别名>
```

**检查点**：
- [ ] SHA-1 是否已添加到 Firebase Console？
- [ ] Firebase Console 路径：项目设置 → 你的 Android 应用 → SHA 证书指纹

#### 4.3 检查 AndroidManifest.xml

**确认以下配置存在**：
```xml
<!-- Android 13+ 通知权限 -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- FCM 通知配置 -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/ic_notification" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="@string/default_notification_channel_id" />
```

#### 4.4 重新构建应用

```bash
flutter clean
flutter pub get
flutter build apk --debug
# 或
flutter run
```

---

### 第五步：使用 Firebase Console 测试

1. **进入 Firebase Console**：https://console.firebase.google.com/
2. **选择你的项目**
3. **Cloud Messaging** → **发送第一条消息** 或 **新建通知**
4. **填写通知内容**：
   - 通知标题：测试标题
   - 通知文本：测试内容
5. **点击"下一步"**
6. **选择"发送测试消息"**
7. **输入 FCM Token**（从应用日志中获取）
8. **点击"测试"**

**预期结果**：
- 应用在前台：应该看到通知
- 应用在后台：系统通知栏应该显示通知
- 应用已终止：系统通知栏应该显示通知

**如果 Firebase Console 测试成功，但后端推送失败**：
- 问题在后端推送的消息格式
- 检查后端推送代码，确保包含 `notification` 字段

---

## 🔍 常见问题总结

### 问题 1：只看到 Token，但没有收到通知

**可能原因**：
1. ❌ 后端推送的消息**只有 `data` 字段，没有 `notification` 字段**
2. ❌ Token 没有成功上报到后端（后端使用的是旧 Token）
3. ❌ 应用在前台，但本地通知显示失败
4. ❌ 通知权限被拒绝（虽然日志显示已授权）

**解决方法**：
1. **检查后端推送消息格式**（最重要！）
2. **确认 Token 上报成功**（查看日志）
3. **测试应用在后台/终止状态**（更容易发现问题）
4. **使用 Firebase Console 测试**（验证 FCM 配置是否正确）

### 问题 2：应用在前台能收到，但后台/终止状态收不到

**原因**：后端推送的消息**只有 `data` 字段，没有 `notification` 字段**

**解决方法**：后端推送消息必须包含 `notification` 字段

### 问题 3：Token 上报失败

**可能原因**：
- 网络连接问题
- API 接口错误
- 认证问题

**解决方法**：
- 查看错误日志
- 检查网络连接
- 检查 API 接口配置

---

## 📝 下一步行动

1. **首先检查日志**：查看是否有 `✅ Token 上报成功` 和 `🔔 前台收到消息` 日志
2. **与后端确认消息格式**：确保包含 `notification` 字段
3. **测试不同应用状态**：前台、后台、终止状态
4. **使用 Firebase Console 测试**：验证 FCM 配置是否正确

