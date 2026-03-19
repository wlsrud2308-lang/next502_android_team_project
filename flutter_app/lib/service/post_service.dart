import '../models/post_model.dart';
import '../models/comment_model.dart';

abstract class PostService {

  Future<int> getUserNumByUid(String uid);

  // 1. 게시판별 목록 조회
  Future<List<PostDto>> getPostsByBoard(String? boardType);

  // 2. 상세 조회
  Future<PostDto> getPostDetail(int postId);

  // 3. 게시글 작성
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

  // 6. 좋아요(추천)
  Future<bool> pushLike(int postId, int userNum);

  // 7. 댓글 목록 조회
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

  // 11. 게시글 검색 (검색어로 게시글을 필터링)
  Future<List<PostDto>> searchPosts(String query);  // 새로운 메서드 추가

  Future<List<PostDto>> getPopularPosts();
}