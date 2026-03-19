import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dto/comment_dto.dart';
import '../dto/post_dto.dart';
import 'post_service.dart';

class PostServiceImpl implements PostService {
  final String baseUrl = "http://10.0.2.2:8080";

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // 1. 게시판별 목록 조회 (추가된 기능)
  // boardType: '자유', '국내', '해외' 또는 null(전체)
  @override
  Future<List<PostDto>> getPostsByBoard(String? boardType) async {
    try {
      // 쿼리 파라미터 생성 (예: ?boardType=국내)
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

  // 2. 게시글 등록 (boardType, category 파라미터 대응)
  @override
  Future<bool> insertPost(String title, String content, int userNum, {String? boardType, String? category}) async {
    try {
      final body = jsonEncode({
        "boardType": boardType ?? "자유", // 기본값 설정
        "category": category ?? "잡담",   // 기본값 설정
        "title": title,
        "content": content,
        "userNum": userNum,
      });

      print("📤 [게시글 등록 요청] Body: $body");

      final response = await http.post(
        Uri.parse('$baseUrl/api/post'),
        headers: _headers,
        body: body,
      );

      // 서버가 201 Created 또는 200 OK를 반환하는지 확인
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

      // 서버 Controller가 ResponseEntity<Boolean>을 주므로 응답 바디 확인
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

  // --- 댓글 관련 로직 (기존 유지) ---

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
}