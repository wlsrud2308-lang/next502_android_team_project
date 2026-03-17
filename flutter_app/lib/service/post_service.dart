import 'package:dio/dio.dart';

import '../dto/post_dto.dart';

abstract class PostService {
  Future<PostDto> getPostDetail(String postId);
}

class PostServiceImpl implements PostService {
  final Dio _dio = Dio();
  final String _baseUrl = "http://10.0.2.2:8080/api/posts";

  @override
  Future<PostDto> getPostDetail(String postId) async {
    try {
      final response = await _dio.get('$_baseUrl/$postId');
      if (response.statusCode == 200) {
        return PostDto.fromJson(response.data);
      }
      throw Exception("서버 응답 에러");
    } catch (e) {
      throw Exception("네트워크 에러: $e");
    }
  }
}