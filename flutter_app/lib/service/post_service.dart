import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

abstract class PostService {
  Future<PostDto> getPostDetail(String postId);
  Future<bool> pushLike(String postId, int userNum);

  Future<bool> insertComment(String content, String postId, int userNum);

  Future<List<CommentDto>> getComments(String postId);
}