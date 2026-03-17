package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.PostDTO;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PostMapper {
    PostDTO getPostDetail(Long postId);
}