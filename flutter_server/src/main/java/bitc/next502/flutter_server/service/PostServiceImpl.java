package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.mapper.PostMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostMapper postMapper;

    @Override
    public PostDTO getPostDetail(Long postId) {
        PostDTO post = postMapper.getPostDetail(postId);

        if (post == null) {
            throw new RuntimeException("해당 ID의 게시글이 없습니다: " + postId);
        }

        return post;
    }
}