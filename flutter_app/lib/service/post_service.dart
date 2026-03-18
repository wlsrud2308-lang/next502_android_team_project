import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

abstract class PostService {
  // 1. 상세 조회 (String -> int)
  Future<PostDto> getPostDetail(int postId);

  // 2. 게시글 작성
  Future<bool> insertPost(String title, String content, int userNum);

  // 3. 게시글 수정 (String -> int)
  Future<bool> updatePost(PostDto post);

  // 4. 게시글 삭제 (String -> int)
  Future<bool> deletePost(int postId, int userNum);

  // 5. 좋아요 (String -> int)
  Future<bool> pushLike(int postId, int userNum);

  // 6. 댓글 목록 (String -> int)
  Future<List<CommentDto>> getComments(int postId);

  // 7. 댓글 등록 (String -> int)
  Future<bool> insertComment(String content, int postId, int userNum);

  // 8. 댓글 수정
  Future<bool> updateComment(int commentId, int userNum, String content);

  // 9. 댓글 삭제
  Future<bool> deleteComment(int commentId, int userNum);
}