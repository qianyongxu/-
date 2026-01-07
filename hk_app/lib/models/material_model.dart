class MaterialFile {
  final String name;
  final String url;
  final String format;
  final String size;
  final String previewUrl;

  MaterialFile({
    required this.name,
    required this.url,
    required this.format,
    required this.size,
    required this.previewUrl,
  });

  factory MaterialFile.fromJson(Map<String, dynamic> json) {
    return MaterialFile(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      format: json['format'] ?? '',
      size: json['size'] ?? '',
      previewUrl: json['previewUrl'] ?? json['preview_url'] ?? '',
    );
  }
}

class SoftwareModel {
  final String name;
  final String logo;

  SoftwareModel({required this.name, required this.logo});

  factory SoftwareModel.fromJson(Map<String, dynamic> json) {
    return SoftwareModel(
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

class MaterialModel {
  final String id;
  final String title;
  final String type;
  final String thumbnail;
  final String fileUrl;
  final int downloads;
  final double sizeMb;
  final List<String> supportedSoftware;
  final List<SoftwareModel> softwareObjects; // Added this
  final List<String> tags;
  final String software;
  final List<MaterialFile> files;

  MaterialModel({
    required this.id,
    required this.title,
    required this.type,
    required this.thumbnail,
    required this.fileUrl,
    required this.downloads,
    this.sizeMb = 0.0,
    this.supportedSoftware = const [],
    this.softwareObjects = const [],
    this.tags = const [],
    this.software = '',
    this.files = const [],
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    var filesList = <MaterialFile>[];
    var rawFiles = json['Files'] ?? json['files'];
    if (rawFiles != null && rawFiles is List) {
      filesList = (rawFiles as List)
          .map((f) => MaterialFile.fromJson(f))
          .toList();
    }

    // Parse Softwares from backend object list to String list
    List<String> softwareList = [];
    List<SoftwareModel> swObjects = [];

    if (json['Softwares'] != null && json['Softwares'] is List) {
      swObjects = (json['Softwares'] as List)
          .map((s) => SoftwareModel.fromJson(s))
          .toList();
      softwareList = swObjects.map((s) => s.name).toList();
    } else if (json['supportedSoftware'] != null &&
        json['supportedSoftware'] is List) {
      softwareList = List<String>.from(json['supportedSoftware']);
      // Fallback: create dummy objects if logo missing
      swObjects = softwareList.map((name) => SoftwareModel(name: name, logo: '')).toList();
    }

    // Parse Tags from backend object list to String list
    List<String> tagsList = [];
    if (json['Tags'] != null && json['Tags'] is List) {
      tagsList = (json['Tags'] as List)
          .map((t) => t['name']?.toString() ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    } else if (json['tags'] != null && json['tags'] is List) {
      // Handle simple string list or object list
      var list = json['tags'] as List;
      if (list.isNotEmpty && list.first is Map) {
        tagsList = list
            .map((t) => t['name']?.toString() ?? '')
            .where((t) => t.isNotEmpty)
            .toList();
      } else {
        tagsList = List<String>.from(list);
      }
    }

    return MaterialModel(
      // Handle both int and String IDs
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      // Map 'category' (server) to 'type' (app), fallback to 'type'
      type: json['category'] ?? json['type'] ?? 'unknown',
      // Map 'preview_url' (server) to 'thumbnail' (app)
      thumbnail: json['preview_url'] ?? json['thumbnail'] ?? '',
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? '',
      // Map 'download_count' (server) to 'downloads' (app)
      downloads: json['download_count'] ?? json['downloads'] ?? 0,
      // Map 'file_size' (server) to sizeMb
      sizeMb: (json['file_size'] is num)
          ? (json['file_size'] as num) / (1024 * 1024)
          : 0.0,
      supportedSoftware: softwareList,
      softwareObjects: swObjects,
      tags: tagsList,
      software: softwareList.isNotEmpty ? softwareList.first : '',
      files: filesList,
    );
  }
}
