package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;
import java.util.List;

public interface PostService {
    // 1. 게시판별 목록 조회
    List<PostDTO> getPostsByBoard(String boardType);

    // 2. 게시글 상세 조회
    PostDTO getPostDetail(Long postId);

    // 3. 게시글 작성
    void insertPost(PostDTO postDTO);

    // 4. 게시글 수정
    boolean updatePost(PostDTO postDTO);

    // 5. 게시글 삭제
    boolean deletePost(Long postId, int userNum);

    // 6. 좋아요 기능
    boolean pushLike(Long postId, int userNum);

    // 7. 게시글 검색
    List<PostDTO> searchPosts(String query);  // 검색 메서드 추가

    List<PostDTO> getPopularPosts();
}