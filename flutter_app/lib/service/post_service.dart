import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

abstract class PostService {
  // 1. 상세 조회
  Future<PostDto> getPostDetail(int postId);

  // 2. 게시글 작성
  Future<bool> insertPost(String title, String content, int userNum);

  // 3. 게시글 수정
  Future<bool> updatePost(PostDto post);

  // 4. 게시글 삭제
  Future<bool> deletePost(int postId, int userNum);

  // 5. 좋아요
  Future<bool> pushLike(int postId, int userNum);

  // 6. 댓글 목록
  Future<List<CommentDto>> getComments(int postId);

  // 7. 댓글 및 대댓글 등록
  Future<bool> insertComment(
      String content,
      int postId,
      int userNum,
      String targetType,
      {int? targetId}
      );

  // 8. 댓글 수정
  Future<bool> updateComment(int commentId, int userNum, String content);

  // 9. 댓글 삭제
  Future<bool> deleteComment(int commentId, int userNum);
}