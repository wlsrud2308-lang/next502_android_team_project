import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'post_service.dart';

class PostServiceImpl implements PostService {
  final String baseUrl = "http://10.0.2.2:8080";

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  @override
  Future<int> getUserNumByUid(String uid) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/num').replace(
        queryParameters: {'uid': uid},
      );

      final response = await http.get(uri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is int) return decoded;
        return decoded['userNum'] as int;
      } else {
        print("❌ [getUserNumByUid 실패]: ${response.statusCode}");
        throw Exception('유저 번호 조회 실패');
      }
    } catch (e) {
      print("❌ [getUserNumByUid 에러]: $e");
      rethrow;
    }
  }

  // 1. 게시판별 목록 조회
  @override
  Future<List<PostDto>> getPostsByBoard(String? boardType) async {
    try {
      final uri = Uri.parse('$baseUrl/api/post').replace(
        queryParameters: boardType != null ? {'boardType': boardType} : null,
      );

      final response = await http.get(uri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => PostDto.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ [getPostsByBoard 에러]: $e");
      return [];
    }
  }

  @override
  Future<PostDto> getPostDetail(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/post/$postId'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return PostDto.fromJson(decodedData);
      } else {
        throw Exception('게시글 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ [getPostDetail 에러]: $e");
      rethrow;
    }
  }

  // 2. 게시글 등록
  @override
  Future<bool> insertPost(String title, String content, int userNum, {String? boardType, String? category}) async {
    try {
      final body = jsonEncode({
        "boardType": boardType ?? "자유",
        "category": category ?? "잡담",
        "title": title,
        "content": content,
        "userNum": userNum,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/post'),
        headers: _headers,
        body: body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ [게시글 등록 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> updatePost(PostDto post) async {
    try {
      final body = jsonEncode(post.toJson());
      final response = await http.put(
        Uri.parse('$baseUrl/api/post/update'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == "true";
      }
      return false;
    } catch (e) {
      print("❌ [게시글 수정 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> deletePost(int postId, int userNum) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/post/$postId?userNum=$userNum'),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == "true";
      }
      return false;
    } catch (e) {
      print("❌ [게시글 삭제 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> pushLike(int postId, int userNum) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/post/like/$postId?userNum=$userNum'),
      );
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == "true";
      }
      return false;
    } catch (e) {
      print("❌ [추천 통신 에러]: $e");
      return false;
    }
  }

  // --- 댓글 관련 로직 ---

  @override
  Future<List<CommentDto>> getComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/comments/$postId'),
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => CommentDto.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("🔥 [댓글 조회 에러]: $e");
      return [];
    }
  }

  @override
  Future<bool> insertComment(String content, int postId, int userNum, String targetType, {int? targetId}) async {
    try {
      final body = jsonEncode({
        'content': content,
        'postId': postId,
        'userNum': userNum,
        'targetType': targetType,
        'targetId': targetId,
      });

      final response = await http.post(Uri.parse('$baseUrl/comments'), headers: _headers, body: body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ [댓글 등록 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> updateComment(int commentId, int userNum, String content) async {
    try {
      final body = jsonEncode({"commentId": commentId, "userNum": userNum, "content": content});
      final response = await http.put(Uri.parse('$baseUrl/comments'), headers: _headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      print("❌ [댓글 수정 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteComment(int commentId, int userNum) async {
    try {
      final body = jsonEncode({"commentId": commentId, "userNum": userNum});
      final response = await http.delete(Uri.parse('$baseUrl/comments'), headers: _headers, body: body);
      return response.statusCode == 200;
    } catch (e) {
      print("❌ [댓글 삭제 에러]: $e");
      return false;
    }
  }

  @override
  Future<List<PostDto>> searchPosts(String query) async {
    try {
      if (query.isEmpty) return [];

      final uri = Uri.parse('$baseUrl/api/post/search').replace(
        queryParameters: {'query': query},
      );

      final response = await http.get(uri, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => PostDto.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ [searchPosts 에러]: $e");
      return [];
    }
  }

  // ====================== 인기글 조회
  @override
  Future<List<PostDto>> getPopularPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/post/popular'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => PostDto.fromJson(item)).toList();
      } else {
        print("❌ [getPopularPosts 에러]: 상태 코드 ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ [getPopularPosts 예외]: $e");
      return [];
    }
  }
}