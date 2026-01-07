class HelpGuide {
  final String id;
  final String title;
  final String content;

  HelpGuide({required this.id, required this.title, required this.content});

  factory HelpGuide.fromJson(Map<String, dynamic> json) {
    return HelpGuide(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['question'] ?? '',
      content: json['content'] ?? json['answer'] ?? '',
    );
  }
}

class InfluencerPick {
  final String id;
  final String title;
  final String description;
  final String targetType;
  final String targetId;
  final String coverUrl;

  InfluencerPick({
    required this.id,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetId,
    required this.coverUrl,
  });

  factory InfluencerPick.fromJson(Map<String, dynamic> json) {
    return InfluencerPick(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetType: json['targetType'] ?? 'material',
      targetId: json['targetId']?.toString() ?? '',
      coverUrl: json['coverUrl'] ?? '',
    );
  }
}

class HKUser {
  final String id;
  final String nickname;
  final String avatarUrl;
  final int totalDownloadCount;
  final int collectionCount;
  final String? token;

  HKUser({
    required this.id,
    required this.nickname,
    required this.avatarUrl,
    this.totalDownloadCount = 0,
    this.collectionCount = 0,
    this.token,
  });

  factory HKUser.fromJson(Map<String, dynamic> json) {
    return HKUser(
      id: json['id']?.toString() ?? '',
      nickname: json['nickname'] ?? 'User',
      avatarUrl: json['avatarUrl'] ?? json['avatar'] ?? '',
      totalDownloadCount: json['totalDownloadCount'] ?? json['total_download_count'] ?? 0,
      collectionCount: json['collectionCount'] ?? json['favorites_count'] ?? 0,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'totalDownloadCount': totalDownloadCount,
      'collectionCount': collectionCount,
      'token': token,
    };
  }
}

class Software {
  final String id;
  final String name;
  final String iconUrl;
  final List<String> formats;

  Software({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.formats = const [],
  });

  factory Software.fromJson(Map<String, dynamic> json) {
    return Software(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      // Assume icon is a full URL or relative path
      iconUrl: json['icon'] ?? json['iconUrl'] ?? '',
      formats: List<String>.from(json['formats'] ?? []),
    );
  }
}

class MarketingPopup {
  final String id;
  final String imageUrl;
  final String targetUrl;
  final String frequency;

  MarketingPopup({required this.id, required this.imageUrl, required this.targetUrl, required this.frequency});

  factory MarketingPopup.fromJson(Map<String, dynamic> json) {
    return MarketingPopup(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      targetUrl: json['target_url'] ?? '',
      frequency: json['frequency'] ?? 'daily',
    );
  }
}
