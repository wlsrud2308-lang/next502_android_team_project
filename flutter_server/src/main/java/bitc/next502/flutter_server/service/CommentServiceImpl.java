package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.CommentDTO;
import bitc.next502.flutter_server.mapper.CommentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;

    @Override
    public void insertComment(CommentDTO dto) {
        commentMapper.insertComment(dto);
    }

    @Override
    public List<CommentDTO> getComments(int postId) {
        return commentMapper.getComments(postId);
    }

    @Override
    public void updateComment(CommentDTO dto) {
        commentMapper.updateComment(dto);
    }

    @Override
    public void deleteComment(CommentDTO dto) {
        commentMapper.deleteComment(dto);
    }
}