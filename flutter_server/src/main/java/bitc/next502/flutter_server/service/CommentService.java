package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.CommentDTO;
import java.util.List;

public interface CommentService {
    void insertComment(CommentDTO dto);
    List<CommentDTO> getComments(String targetType, String targetId);
}