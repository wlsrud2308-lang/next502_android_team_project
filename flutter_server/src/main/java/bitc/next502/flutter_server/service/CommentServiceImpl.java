package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.CommentDTO;
import bitc.next502.flutter_server.mapper.CommentMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CommentServiceImpl implements CommentService {

    private final CommentMapper mapper;

    public CommentServiceImpl(CommentMapper mapper) {
        this.mapper = mapper;
    }

    @Override
    public void insertComment(CommentDTO dto) {
        mapper.insertComment(dto);
    }

    @Override
    public List<CommentDTO> getComments(int postId) {
        return mapper.getComments(postId);
    }

    @Override
    public void updateComment(CommentDTO dto) {
        mapper.updateComment(dto);
    }

    @Override
    public void deleteComment(CommentDTO dto) {
        mapper.deleteComment(dto);
    }

}