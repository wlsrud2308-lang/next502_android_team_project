import '../dto/post_dto.dart';
import '../dto/comment_dto.dart'; // 추가

abstract class PostService {
  Future<PostDto> getPostDetail(String postId);
  Future<bool> pushLike(String postId, int userNum);

  Future<List<CommentDto>> getComments(String postId);
}