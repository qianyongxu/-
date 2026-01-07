import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/material_model.dart';
import '../models/app_models.dart';
import 'dart:io';

class ApiService {
  // static const String baseUrl = 'http://192.168.0.24:3000/api';
  // static const String baseUrl = 'http://127.0.0.1:3000/api';
  // static const String baseUrl = 'http://hk.xbjy123.com/api';
  static const String baseUrl = 'https://hk.xbjy123.com/api';

  // Helper to ensure URLs are valid
  String _fixUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Handle relative paths from backend
    if (url.startsWith('/')) {
      // Check if it's already a full relative path or needs prefix
      if (url.startsWith('/uploads')) {
        return 'https://hk-1301306766.cos.ap-guangzhou.myqcloud.com$url';
      }
      return 'https://hk.xbjy123.com$url';
    }
    // Handle uploads path specifically if needed, though usually backend returns full or relative
    // Fallback for simple filenames to COS
    return 'https://hk-1301306766.cos.ap-guangzhou.myqcloud.com/uploads/$url';
  }

  Future<List<MaterialModel>> getMaterials({
    String? type,
    String? category,
    String? query,
  }) async {
    String url = '$baseUrl/materials';
    Map<String, String> queryParams = {};
    if (type != null) queryParams['type'] = type;
    if (category != null) queryParams['category'] = category;
    if (query != null) queryParams['q'] = query;

    if (queryParams.isNotEmpty) {
      url += '?' + Uri(queryParameters: queryParams).query;
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic jsonResponse = jsonDecode(response.body);
      List<dynamic> data = [];

      if (jsonResponse is List) {
        data = jsonResponse;
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('data')) {
          data = jsonResponse['data'];
        }
      }

      return data.map((json) {
        var item = MaterialModel.fromJson(json);
        // Fix image URLs
        return MaterialModel(
          id: item.id,
          title: item.title,
          thumbnail: _fixUrl(item.thumbnail),
          fileUrl: _fixUrl(item.fileUrl),
          downloads: item.downloads,
          type: item.type,
          sizeMb: item.sizeMb,
          supportedSoftware: item.supportedSoftware,
          tags: item.tags,
          software: item.software,
          files: item.files,
        );
      }).toList();
    } else {
      throw Exception('Failed to load materials');
    }
  }

  Future<List<HelpGuide>> getHelpGuides() async {
    final response = await http.get(Uri.parse('$baseUrl/help-guides'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => HelpGuide.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load guides');
    }
  }

  Future<List<InfluencerPick>> getInfluencerPicks() async {
    final response = await http.get(Uri.parse('$baseUrl/influencer-picks'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InfluencerPick.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load picks');
    }
  }

  Future<List<Software>> getSoftwareList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/software'));
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body);
        List<dynamic> data = [];

        if (jsonResponse is List) {
          data = jsonResponse;
        } else if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['code'] == 200) {
          data = jsonResponse['data'];
        }

        return data.map((json) {
          // Handle relative paths for icons if necessary
          var sw = Software.fromJson(json);
          if (sw.iconUrl.isNotEmpty && !sw.iconUrl.startsWith('http')) {
            return Software(
              id: sw.id,
              name: sw.name,
              iconUrl: '$baseUrl/uploads/${sw.iconUrl}',
              formats: sw.formats,
            );
          }
          return sw;
        }).toList();
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  Future<void> submitFeedback(
    String content,
    String contact,
    List<File> images,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/feedback'));
    request.fields['content'] = content;
    request.fields['contact'] = contact;

    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final response = await request.send();
    if (response.statusCode != 201) {
      throw Exception('Failed to submit feedback');
    }
  }

  Future<HKUser> loginWithWeChat(
    String code, {
    Map<String, dynamic>? deviceInfo,
  }) async {
    // Correct Endpoint: /api/auth/login (mapped in backend index.js + authRoutes.js)
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'type': 'app', // Explicitly tell backend this is an App login code
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userMap = Map<String, dynamic>.from(data['user']);
      if (data['token'] != null) {
        userMap['token'] = data['token'];
      }
      return HKUser.fromJson(userMap);
    } else if (response.statusCode == 403) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'banned') {
        throw Exception('Account Banned');
      }
      throw Exception('Login failed: ${response.body}');
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<bool> downloadMaterial(String materialId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/materials/$materialId/download'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Download failed');
    }
  }

  Future<bool> toggleFavorite(String materialId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/favorites/toggle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'materialId': materialId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFavorite'] ?? false;
    }
    throw Exception('Failed to toggle favorite');
  }

  Future<bool> checkFavorite(String materialId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/favorites/$materialId?userId=$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFavorite'] ?? false;
    }
    return false;
  }

  Future<List<MaterialModel>> getFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/favorites'),
    );
    if (response.statusCode == 200) {
      final dynamic jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse
            .map((json) => MaterialModel.fromJson(json))
            .toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse.containsKey('data')) {
          return (jsonResponse['data'] as List)
              .map((json) => MaterialModel.fromJson(json))
              .toList();
        } else if (jsonResponse.containsKey('code') &&
            jsonResponse['code'] == 200) {
          return (jsonResponse['data'] as List)
              .map((json) => MaterialModel.fromJson(json))
              .toList();
        }
      }
    }
    return [];
  }

  Future<HKUser> getUser(String userId, {String? token}) async {
    final headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers['Authorization'] = 'Bearer jwt_token_$userId';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return HKUser.fromJson(data['user']);
    }
    throw Exception('Failed to get user');
  }

  Future<MarketingPopup?> getActivePopup() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/marketing-popups/active'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) return MarketingPopup.fromJson(data);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}
