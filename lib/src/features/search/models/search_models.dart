/// keyword Item
class KeywordItem {
  ///图标
  final String? icon; // 不为空说明 isHot 为true

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
      createTime: DateTime.fromMillisecondsSinceEpoch(
        json['createTime'] as int,
      ),
      id: json['id'],
      searchWord: json['searchWord'],
      updateTime: DateTime.fromMillisecondsSinceEpoch(
        json['updateTime'] as int,
      ),
    );
  }
}

/// 搜索query
class SearchQuery {
  ///纬度
  final double latitude;

  ///经度
  final double longitude;

  ///页码，从 1 开始
  final int pageNo;

  ///每页条数，最大值为 100
  final int pageSize;

  ///查询内容（全文检索）
  final String? search;

  SearchQuery({
    required this.latitude,
    required this.longitude,
    required this.pageNo,
    required this.pageSize,
    this.search,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'pageNo': pageNo,
      'pageSize': pageSize,
      if (search != null) 'search': search,
    };
  }
}
