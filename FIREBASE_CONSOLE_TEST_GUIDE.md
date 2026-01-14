# Firebase Console 推送测试指南

## 方法一：使用 Cloud Messaging 发送测试消息（推荐）

### 步骤 1：访问 Firebase Console
打开浏览器，访问：
```
https://console.firebase.google.com/
```

### 步骤 2：选择项目
点击你的项目：**chop-chop-app-473015**

### 步骤 3：进入 Cloud Messaging
在左侧菜单中找到并点击：
```
Engage（参与互动） → Messaging（消息传递）
```
或者直接点击：
```
All products（所有产品） → Cloud Messaging
```

### 步骤 4：创建测试消息
1. 点击 **"Send your first message"（发送第一条消息）** 
   或 **"Create your first campaign"（创建第一个广告系列）**
   
2. 在 **"Notification（通知）"** 部分填写：
   - **Notification title（通知标题）**：`测试消息`
   - **Notification text（通知文本）**：`这是一条测试推送消息`
   - **Notification image（可选）**：留空

3. 点击右侧的 **"Send test message"（发送测试消息）** 按钮

### 步骤 5：输入 FCM Token
1. 在弹出的窗口中，会看到 **"Add an FCM registration token"** 输入框
2. 从你的应用日志中复制 FCM Token
   - 查找日志：`📱 当前 Token: <your-token>`
   - 或者查找：`4. 当前 FCM Token: <your-token>`
3. 将 Token 粘贴到输入框中
4. 点击 **"+"** 号添加
5. 点击 **"Test"（测试）** 按钮

### 步骤 6：观察结果
- ✅ **前台运行**：应该立即在应用中看到通知弹出
- ✅ **后台运行**：系统通知栏应该显示通知
- ✅ **应用关闭**：系统通知栏应该显示通知

## 方法二：使用 Composer 发送广播消息

### 步骤 1-3：同上

### 步骤 4：填写完整表单
1. **Notification（通知）**：填写标题和文本
2. 点击 **"Next"（下一步）**
3. **Target（目标）**：选择 **"User segment"** → **"All users"**
4. 点击 **"Next"（下一步）**
5. **Scheduling（计划）**：选择 **"Now"（立即）**
6. 点击 **"Next"（下一步）**
7. **Conversion events（可选）**：跳过
8. 点击 **"Next"（下一步）**
9. **Additional options（附加选项）**：
   - 可以添加 **Custom data（自定义数据）**：
     ```
     messageTypeId: 1
     orderId: TEST123
     ```
10. 点击 **"Review"（审核）**
11. 点击 **"Publish"（发布）**

**注意**：这种方式会发送给所有已注册的设备。

## 方法三：使用 Notifications Composer（旧版界面）

如果看到的是旧版界面：

1. 左侧菜单 → **Cloud Messaging**
2. 点击 **"Send your first message"** 或 **"New notification"**
3. 填写：
   - Notification title: `测试消息`
   - Notification text: `这是测试内容`
4. 点击 **"Send test message"**
5. 输入 FCM Token
6. 点击 **"Test"**

## 快速访问链接

### 直接访问 Cloud Messaging 页面：
```
https://console.firebase.google.com/project/chop-chop-app-473015/notification
```

### 或者：
```
https://console.firebase.google.com/project/chop-chop-app-473015/messaging
```

## 如何获取 FCM Token

### 方法 1：从应用日志中获取
重新运行应用后，查看日志输出：
```
========== 推送服务调试信息 ==========
...
4. 当前 FCM Token: eyJhbGciOiJFUz...（这是你的 Token）
...
```

复制这个 Token 值。

### 方法 2：在 iOS 设备上
打开 Xcode：
1. Window → Devices and Simulators
2. 选择你的设备
3. 点击 "Open Console"
4. 搜索 "FCM Token" 或 "当前 Token"

### 方法 3：在 Android 设备上
```bash
adb logcat | grep "当前 Token"
```

## 测试场景

### 场景 1：应用在前台
1. 保持应用在前台运行
2. 从 Firebase Console 发送测试消息
3. **预期结果**：应该看到应用内弹出通知（本地通知）
4. **日志**：应该看到 `🔔 前台收到消息`

### 场景 2：应用在后台
1. 按 Home 键将应用切换到后台
2. 从 Firebase Console 发送测试消息
3. **预期结果**：系统通知栏显示通知
4. 点击通知应该能打开应用

### 场景 3：应用完全关闭
1. 从任务管理器完全关闭应用
2. 从 Firebase Console 发送测试消息
3. **预期结果**：系统通知栏显示通知
4. 点击通知应该能启动应用

## 常见问题

### Q: 找不到 "Send test message" 按钮？
A: 确保：
1. 你在 **Cloud Messaging** 或 **Messaging** 页面
2. 已经创建了一个消息（填写了标题和文本）
3. 按钮通常在右上角或页面顶部

### Q: 输入 Token 后无法点击 Test？
A: 检查：
1. Token 是否完整（通常很长，100+ 字符）
2. 没有多余的空格或换行
3. 点击 "+" 号添加 Token 到列表中

### Q: 点击 Test 后没有反应？
A: 可能原因：
1. Token 已过期（重新运行应用获取新 Token）
2. 网络问题
3. 设备离线

### Q: 测试成功，但后端推送还是收不到？
A: 说明问题在后端：
1. 后端使用的 Token 可能不对
2. 后端推送的消息格式可能有问题（缺少 notification 字段）
3. 让后端参考 Firebase Console 成功的消息格式

## 成功的标志

如果 Firebase Console 测试成功：
- ✅ FCM 配置正确
- ✅ 设备可以接收推送
- ✅ Token 有效
- ✅ 网络连接正常
- ✅ 推送权限已授予

如果后端推送失败，但 Firebase Console 成功：
- 问题 100% 在后端的推送实现
- 让后端检查消息格式和 Token 使用

## 截图位置参考

在 Firebase Console 中：
```
项目首页
├── Engage (参与互动)
│   ├── Messaging (消息传递) ← 在这里
│   ├── In-App Messaging
│   └── Remote Config
└── Build (构建)
    ├── Authentication
    └── Cloud Messaging ← 或者在这里
```

## 下一步

1. ✅ 重新运行应用，获取调试信息和 Token
2. ✅ 访问 Firebase Console
3. ✅ 使用上面的 Token 发送测试消息
4. ✅ 观察结果并报告

如果 Firebase Console 测试成功，说明配置完全正确，问题在后端！
