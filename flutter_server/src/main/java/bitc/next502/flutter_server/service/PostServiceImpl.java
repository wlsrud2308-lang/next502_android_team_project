package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.mapper.PostMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostMapper postMapper;

    @Override
    @Transactional // 조회수 증가와 조회를 하나의 트랜잭션으로 처리
    public PostDTO getPostDetail(Long postId) {
        postMapper.updateViewCount(postId);

        PostDTO post = postMapper.getPostDetail(postId);

        if (post == null) {
            throw new RuntimeException("해당 ID의 게시글이 없습니다: " + postId);
        }

        return post;
    }

    @Override
    @Transactional
    public boolean pushLike(Long postId, int userNum) {
        if (postMapper.checkLikeHistory(postId, userNum) > 0) {
            return false;
        }

        postMapper.insertLikeHistory(postId, userNum);
        postMapper.incrementLikeCount(postId);
        return true;
    }

    @Override
    @Transactional
    public boolean updatePost(PostDTO postDTO) {
        int result = postMapper.updatePost(postDTO);
        return result > 0;
    }

    @Override
    @Transactional
    public boolean deletePost(Long postId, int userNum) {
        int result = postMapper.deletePost(postId, userNum);
        return result > 0;
    }
}