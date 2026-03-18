package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;

public interface PostService {
    PostDTO getPostDetail(Long postId);

    boolean pushLike(Long postId, int userNum);

    boolean updatePost(PostDTO postDTO);

    boolean deletePost(Long postId, int userNum);
}