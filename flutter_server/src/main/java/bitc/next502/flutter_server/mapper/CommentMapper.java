package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.CommentDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface CommentMapper {

    //  댓글 등록
    void insertComment(CommentDTO dto);


    List<CommentDTO> getComments(int postId);


    void updateComment(CommentDTO dto);


    void deleteComment(CommentDTO dto);
}