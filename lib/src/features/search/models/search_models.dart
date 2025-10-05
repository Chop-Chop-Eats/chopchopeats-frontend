/// keyword Item
class KeywordItem {
  ///图标
  final String? icon;

  ///主键ID
  final int id;

  ///关键词
  final String keyWord;

  ///排序
  final int sort;

  KeywordItem({
    this.icon,
    required this.id,
    required this.keyWord,
    required this.sort,
  });

  factory KeywordItem.fromJson(Map<String, dynamic> json) {
    return KeywordItem(
      icon: json['icon'],
      id: json['id'],
      keyWord: json['keyWord'],
      sort: json['sort'],
    );
  }
}

/// history Item
class HistoryItem {
  ///创建时间
  final DateTime createTime;

  ///主键ID
  final int id;

  ///搜索词
  final String searchWord;

  ///更新时间
  final DateTime updateTime;

  HistoryItem({
    required this.createTime,
    required this.id,
    required this.searchWord,
    required this.updateTime,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      createTime: DateTime.fromMillisecondsSinceEpoch(json['createTime'] as int),
      id: json['id'],
      searchWord: json['searchWord'],
      updateTime: DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
    );
  }
}
