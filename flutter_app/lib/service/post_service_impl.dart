import 'dart:convert';
import 'package:http/http.dart' as http;
import '../dto/post_dto.dart';
import 'post_service.dart';

class PostServiceImpl implements PostService {
  final String baseUrl = "http://10.0.2.2:8080";

  @override
  Future<PostDto> getPostDetail(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/post/$postId'),
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        return PostDto.fromJson(decodedData);
      } else {
        throw Exception('게시글 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("getPostDetail 에러: $e");
      rethrow;
    }
  }

  @override
  Future<bool> pushLike(String postId, int userNum) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/post/like/$postId?userNum=$userNum'),
      );

      print("서버 응답 바디: '${response.body}'");

      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == "true";
      }
      return false;
    } catch (e) {
      print("추천 통신 에러: $e");
      return false;
    }
  }
}