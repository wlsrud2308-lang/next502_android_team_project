package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.PostDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PostMapper {

    // 1. 게시판별 목록 조회 (추가)
    List<PostDTO> getPostsByBoard(@Param("boardType") String boardType);

    // 2. 게시글 상세 조회
    PostDTO getPostDetail(Long postId);

    // 3. 게시글 등록 (추가)
    void insertPost(PostDTO postDTO);

    // 4. 게시글 수정
    // title, content, category 수정을 위해 DTO 사용
    int updatePost(PostDTO postDTO);

    // 5. 게시글 삭제
    int deletePost(@Param("postId") Long postId, @Param("userNum") int userNum);

    // 6. 조회수 증가
    void updateViewCount(Long postId);

    // 7. 좋아요 관련 로직
    int checkLikeHistory(@Param("postId") Long postId, @Param("userNum") int userNum);
    void insertLikeHistory(@Param("postId") Long postId, @Param("userNum") int userNum);
    void incrementLikeCount(Long postId);

    // 8. 게시글 검색 기능 추가
    List<PostDTO> searchPosts(@Param("query") String query);
}