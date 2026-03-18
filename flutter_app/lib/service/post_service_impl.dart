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

  @override
  Future<bool> insertPost(String title, String content, int userNum) async {
    try {
      final body = jsonEncode({
        "title": title,
        "content": content,
        "userNum": userNum,
        "viewCnt": 0,
        "likeCnt": 0,
        "commentCnt": 0,
      });
      print("📤 [게시글 등록 요청] Body: $body");

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
      print("📤 [게시글 수정 요청] 전체 데이터 전송: $body");

      final response = await http.put(
        Uri.parse('$baseUrl/api/post/update'),
        headers: _headers,
        body: body,
      );

      print("📢 [게시글 수정 응답] 코드: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("⚠️ [수정 실패 사유]: ${response.body}");
      }
      return response.statusCode == 200;
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
      return response.statusCode == 200;
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
  Future<bool> insertComment(String content, int postId, int userNum) async {
    try {
      final body = jsonEncode({
        'content': content,
        'postId': postId,
        'userNum': userNum,
      });
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ [댓글 등록 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> updateComment(int commentId, int userNum, String content) async {
    try {
      final body = jsonEncode({
        "commentId": commentId,
        "userNum": userNum,
        "content": content,
      });
      final response = await http.put(
        Uri.parse('$baseUrl/comments'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ [댓글 수정 에러]: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteComment(int commentId, int userNum) async {
    try {
      final body = jsonEncode({
        "commentId": commentId,
        "userNum": userNum,
      });
      final response = await http.delete(
        Uri.parse('$baseUrl/comments'),
        headers: _headers,
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("❌ [댓글 삭제 에러]: $e");
      return false;
    }
  }
}