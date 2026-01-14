# 前台收不到推送消息 - 排查清单

## 当前状态
- ✅ Token 已上报成功
- ✅ 后端消息格式正确（包含 notification）
- ✅ iOS 配置正确（Push Notifications capability 已启用）
- ❌ 前台收不到消息

## 立即执行的排查步骤

### 步骤 1：确认最新代码运行
```bash
# 完全清理并重新运行
flutter clean
flutter pub get
flutter run
```

等待应用启动，查看日志中是否有：
```
✅ 前台消息监听器已注册
🎉 推送服务初始化完成！
```

### 步骤 2：确认 Token 一致性

**从日志中获取的 Token：**
```
dGWf2jNjO04Ho_MxSsqphw:APA91bFGXQ1mg7yhClVd0nu1a5zlWP_8dGsZTUsk_fpZdxKilxb2NaE8faoQ0KgF55lhZQomUYf0ZKXNTg1JaQ1QnB39rQUvW4xVOGwXpsQII5u82kzL8Bg
```

**关键问题：后端使用的是哪个 Token？**

可能的情况：
1. ❌ 后端用的是旧的 Token（之前上报的）
2. ❌ 后端用的是另一台设备的 Token
3. ❌ 后端数据库中存储的 Token 不对

**验证方法：**
让后端打印日志，确认：
- 推送时使用的 Token 是什么？
- 是否与你当前设备的 Token 一致？

### 步骤 3：检查后端推送是否成功

让后端在发送推送后检查 FCM 的响应：

**成功的响应：**
```json
{
  "name": "projects/chop-chop-app-473015/messages/xxxxx"
}
```

**失败的响应（示例）：**
```json
{
  "error": {
    "code": 404,
    "message": "Requested entity was not found.",
    "status": "NOT_FOUND"
  }
}
```

常见错误：
- `INVALID_ARGUMENT`: Token 格式错误
- `NOT_FOUND`: Token 不存在或已过期
- `SENDER_ID_MISMATCH`: Token 不属于这个项目
- `UNREGISTERED`: Token 已失效

### 步骤 4：下单测试并观察日志

**保持应用在前台运行**，下单后立即查看日志：

**期望看到：**
```
✅✅✅ 监听器被触发！收到消息: xxx
🔔 前台收到消息: xxx
✅ 包含 notification 字段:
   - title: 订单已接单
   - body: ...
```

**如果只看到初始化日志，没有收到消息的日志：**
- 消息没有到达设备
- 后端可能：
  1. 没有发送
  2. 使用了错误的 Token
  3. FCM 返回了错误

**如果看到错误日志：**
```
❌ 前台消息监听器错误: xxx
```
说明监听器有问题，需要修复。

### 步骤 5：检查网络连接

**确认设备可以连接 FCM：**
- iOS 需要能访问：`fcm.googleapis.com`
- iOS 需要能访问：`*.push.apple.com`（APNs）

**测试方法：**
```bash
# 在设备上测试（通过 Safari）
https://fcm.googleapis.com
```

如果在中国大陆：
- FCM 可能无法直接访问
- APNs 连接可能很慢
- 可能需要 VPN

### 步骤 6：检查是否有多个账号登录

**问题场景：**
- 用户 A 登录后上报了 Token（绑定到用户 A）
- 然后退出登录
- 用户 B 登录（但没有重新上报 Token）
- 后端向用户 B 推送，但数据库中用户 B 没有 Token

**验证：**
让后端检查数据库，当前登录用户（`df4d116136ce473e8d4e35cf75897a00` 对应的用户）的 Token 是什么？

### 步骤 7：手动测试 Token 的有效性

使用 curl 直接测试 Token（需要 Firebase Server Key）：

```bash
curl -X POST https://fcm.googleapis.com/v1/projects/chop-chop-app-473015/messages:send \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "dGWf2jNjO04Ho_MxSsqphw:APA91bFGXQ1mg7yhClVd0nu1a5zlWP_8dGsZTUsk_fpZdxKilxb2NaE8faoQ0KgF55lhZQomUYf0ZKXNTg1JaQ1QnB39rQUvW4xVOGwXpsQII5u82kzL8Bg",
      "notification": {
        "title": "测试",
        "body": "手动测试"
      }
    }
  }'
```

## 最可能的原因排序

### 1. Token 不匹配 ⭐⭐⭐⭐⭐
**症状：** 前台收不到消息，无任何日志
**原因：** 后端使用的 Token 与当前设备不一致
**解决：** 
- 重启应用确保 Token 上报
- 让后端确认使用的 Token
- 检查数据库中的 Token 记录

### 2. APNs 未配置 ⭐⭐⭐⭐
**症状：** Firebase Console 测试失败
**原因：** Firebase 项目未配置 APNs 认证密钥
**影响：** iOS 设备无法接收推送
**解决：** 需要 Firebase 管理员配置 APNs

### 3. 后端推送失败但未发现 ⭐⭐⭐
**症状：** 后端以为发送成功，但实际失败
**原因：** 后端没有检查 FCM 响应
**解决：** 让后端打印 FCM 返回结果

### 4. Token 过期 ⭐⭐
**症状：** Token 存在但无效
**原因：** 应用重装、时间过长等导致 Token 失效
**解决：** 删除应用重装，重新上报 Token

### 5. 网络问题 ⭐⭐
**症状：** 无法连接 FCM/APNs
**原因：** 防火墙、中国大陆网络限制
**解决：** 使用 VPN 或切换网络

## 快速验证脚本

将以下信息发给后端开发者：

```
设备 Token: 
dGWf2jNjO04Ho_MxSsqphw:APA91bFGXQ1mg7yhClVd0nu1a5zlWP_8dGsZTUsk_fpZdxKilxb2NaE8faoQ0KgF55lhZQomUYf0ZKXNTg1JaQ1QnB39rQUvW4xVOGwXpsQII5u82kzL8Bg

用户 Token:
df4d116136ce473e8d4e35cf75897a00

平台: iOS
设备ID: [从数据库查]

请验证：
1. 数据库中这个用户的推送 Token 是否为上面的 Token？
2. 下单推送时，使用的 Token 是什么？
3. FCM 返回的响应是什么？（成功还是失败？）
4. 是否有错误日志？
```

## 临时调试方案

如果以上都无法定位问题，在应用中添加一个测试按钮：

```dart
// 在某个测试页面添加
ElevatedButton(
  onPressed: () async {
    // 模拟接收消息
    final testMessage = RemoteMessage(
      messageId: 'test-${DateTime.now().millisecondsSinceEpoch}',
      data: {'test': 'data'},
    );
    // 这样可以验证消息处理逻辑是否正常
    Logger.info("TEST", "模拟消息已创建");
  },
  child: Text('测试消息处理'),
)
```

## 下一步行动

**优先级 1：** 确认后端使用的 Token 是否正确
- 让后端打印推送时使用的 Token
- 对比你设备上的 Token

**优先级 2：** 检查后端推送结果
- 让后端打印 FCM 的响应
- 确认是否真的发送成功

**优先级 3：** 重新运行应用
- `flutter clean && flutter run`
- 确保使用最新代码
- 下单后立即查看日志

完成这些步骤后，把结果告诉我！
