import '../dto/post_dto.dart';

abstract class PostService {
  Future<PostDto> getPostDetail(String postId);

  Future<bool> pushLike(String postId, int userNum);
}