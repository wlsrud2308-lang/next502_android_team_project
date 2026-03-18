package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CommentDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface CommentMapper {

    void insertComment(CommentDTO dto);

    List<CommentDTO> getComments(int postId);

    int updateComment(CommentDTO dto);

    int deleteComment(CommentDTO dto);
}