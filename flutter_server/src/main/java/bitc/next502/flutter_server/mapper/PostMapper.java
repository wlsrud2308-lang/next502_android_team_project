package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.PostDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PostMapper {
    PostDTO getPostDetail(Long postId);

    void insertLikeHistory(Long postId, int userNum);

    void incrementLikeCount(Long postId);

    int checkLikeHistory(Long postId, int userNum);
}