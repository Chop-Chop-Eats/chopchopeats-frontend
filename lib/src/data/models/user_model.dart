/// 用户数据模型
/// 
/// 这个文件展示了新的分层架构中的数据模型层
/// 负责定义从 API 返回的 JSON 解析后的 Dart 对象
class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.isActive,
  });

  /// 从 JSON 创建 UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// 创建副本
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, username, email);

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email)';
  }
}
