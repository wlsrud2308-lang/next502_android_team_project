import '../dto/post_dto.dart';
import '../dto/comment_dto.dart';

abstract class PostService {
  // 1. 게시판별 목록 조회 (💡 새로 추가)
  // boardType: '자유', '국내', '해외' 또는 null(전체)
  Future<List<PostDto>> getPostsByBoard(String? boardType);

  // 2. 상세 조회
  Future<PostDto> getPostDetail(int postId);

  // 3. 게시글 작성 (💡 파라미터에 boardType, category 추가)
  Future<bool> insertPost(
      String title,
      String content,
      int userNum,
      {String? boardType, String? category}
      );

  // 4. 게시글 수정
  Future<bool> updatePost(PostDto post);

  // 5. 게시글 삭제
  Future<bool> deletePost(int postId, int userNum);

  // 6. 좋아요
  Future<bool> pushLike(int postId, int userNum);

  // 7. 댓글 목록
  Future<List<CommentDto>> getComments(int postId);

  // 8. 댓글 및 대댓글 등록
  Future<bool> insertComment(
      String content,
      int postId,
      int userNum,
      String targetType,
      {int? targetId}
      );

  // 9. 댓글 수정
  Future<bool> updateComment(int commentId, int userNum, String content);

  // 10. 댓글 삭제
  Future<bool> deleteComment(int commentId, int userNum);
}