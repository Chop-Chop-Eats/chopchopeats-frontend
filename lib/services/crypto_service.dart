// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:crypto/crypto.dart' as crypto;
// import 'package:encrypt/encrypt.dart' as encrypt;
// import '../common/constant/app_constant.dart';
//
// class CryptoService {
//   final encrypt.Encrypter _encrypter;
//
//   // 构造函数接收一个公钥字符串
//   CryptoService({required String publicKeyString})
//       : _encrypter = _initializeEncrypter(publicKeyString);
//
//   // 工厂构造函数，使用 App 常量中的公钥
//   factory CryptoService.fromAppConstants() {
//     return CryptoService(publicKeyString: AppConstants.publicKey);
//   }
//
//   static encrypt.Encrypter _initializeEncrypter(String publicKeyString) {
//     final rsaParser = encrypt.RSAKeyParser();
//     final publicKey = rsaParser.parse(publicKeyString);
//     return encrypt.Encrypter(encrypt.RSA(publicKey: publicKey as dynamic));
//   }
//
//   /// 加密给定的字符串
//   String encryptData(String data) {
//     final encrypted = _encrypter.encrypt(data);
//     // 获取 RSA 加密后的标准 Base64 字符串
//     final base64String = encrypted.base64;
//     // 将此 Base64 字符串视为普通文本，进行 UTF-8 编码
//     final utf8Bytes = utf8.encode(base64String);
//     // 对这些 UTF-8 字节进行 Base64-URL-Safe 编码
//     return base64Url.encode(utf8Bytes);
//   }
//
//
//   /// 加密整个 POST 请求体，平移自旧项目的逻辑。
//   ///
//   /// [body]: 原始请求体 Map。
//   /// [uuid]: 用于生成 AES Key 的设备唯一标识符。
//   Map<String, dynamic> encryptPostBody({
//     required Map<String, dynamic> body,
//     required String uuid,
//   }) {
//     final encryptedBody = <String, dynamic>{};
//     // 使用 uuid 的 sha256 哈希值作为 AES Key
//     // SHA256 输出为 32 字节，正好是 AES-256 的密钥长度
//     final List<int> keyBytes = crypto.sha256.convert(utf8.encode(uuid)).bytes;
//     final encrypt.Key key = encrypt.Key(Uint8List.fromList(keyBytes));
//     // IV 固定为 16 个零
//     final encrypt.IV iv = encrypt.IV.allZerosOfLength(16);
//     // 创建 AES 加密器
//     final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
//     // 遍历 Map 的每一个键值对
//     body.forEach((fieldKey, fieldValue) {
//       // 规则：如果 key 是 'token'，则不加密，直接放入新 Map
//       if (fieldKey == 'token') {
//         encryptedBody[fieldKey] = fieldValue;
//       } else {
//         // 对其他字段进行加密
//         final String valueToEncrypt = fieldValue.toString();
//         // 如果值为空，则直接返回空字符串，保持和旧逻辑一致
//         if (valueToEncrypt.isEmpty) {
//           encryptedBody[fieldKey] = '';
//         } else {
//           // AES 加密
//           final encrypted = encrypter.encrypt(valueToEncrypt, iv: iv);
//           // 获取加密结果的 Base64 字符串
//           final base64String = encrypted.base64;
//           // 对 Base64 字符串进行 UTF8 编码，然后再进行 Base64 URL Safe 编码
//           final finalEncryptedValue = base64Url.encode(utf8.encode(base64String));
//           encryptedBody[fieldKey] = finalEncryptedValue;
//         }
//       }
//     });
//     return encryptedBody;
//   }
// }