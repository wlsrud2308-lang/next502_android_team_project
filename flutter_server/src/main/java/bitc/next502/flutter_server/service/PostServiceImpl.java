package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.mapper.PostMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostMapper postMapper;

    // 1. 게시판별 목록 조회 (필수 구현)
    @Override
    @Transactional(readOnly = true)
    public List<PostDTO> getPostsByBoard(String boardType) {
        // boardType이 null이면 MyBatis XML 설정에 따라 전체 리스트를 가져옵니다.
        return postMapper.getPostsByBoard(boardType);
    }

    // 2. 게시글 상세 조회 (기존 로직 유지)
    @Override
    @Transactional
    public PostDTO getPostDetail(Long postId) {
        // 조회수 증가
        postMapper.updateViewCount(postId);

        PostDTO post = postMapper.getPostDetail(postId);

        if (post == null) {
            throw new RuntimeException("해당 ID의 게시글이 없습니다: " + postId);
        }

        return post;
    }

    // 3. 게시글 등록 (필수 구현)
    @Override
    @Transactional
    public void insertPost(PostDTO postDTO) {
        // boardType, category 등이 포함된 DTO를 DB에 저장합니다.
        postMapper.insertPost(postDTO);
    }

    // 4. 게시글 수정 (반환 타입 boolean으로 일치시킴)
    @Override
    @Transactional
    public boolean updatePost(PostDTO postDTO) {
        int result = postMapper.updatePost(postDTO);
        return result > 0; // 성공 시 true 반환
    }

    // 5. 게시글 삭제 (반환 타입 boolean)
    @Override
    @Transactional
    public boolean deletePost(Long postId, int userNum) {
        int result = postMapper.deletePost(postId, userNum);
        return result > 0;
    }

    // 6. 좋아요 기능 (추천 중복 체크 포함)
    @Override
    @Transactional
    public boolean pushLike(Long postId, int userNum) {
        // 이미 추천한 이력이 있는지 확인
        if (postMapper.checkLikeHistory(postId, userNum) > 0) {
            return false;
        }

        postMapper.insertLikeHistory(postId, userNum);
        postMapper.incrementLikeCount(postId);
        return true;
    }

    // 7. 게시글 검색 기능 추가
    @Override
    @Transactional(readOnly = true)
    public List<PostDTO> searchPosts(String query) {
        return postMapper.searchPosts(query);  // MyBatis의 searchPosts 쿼리 호출
    }

}