package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.PostDTO;

public interface PostService {
    PostDTO getPostDetail(Long postId);
}