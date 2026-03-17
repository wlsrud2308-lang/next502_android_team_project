package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.CommentDTO;
import bitc.next502.flutter_server.service.CommentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/comments")
public class CommentController {

    private final CommentService service;

    public CommentController(CommentService service) {
        this.service = service;
    }

    // 댓글 저장
    @PostMapping
    public String insertComment(@RequestBody CommentDTO dto) {
        service.insertComment(dto);
        return "ok";
    }

    // 댓글 조회
    @GetMapping("/{targetType}/{targetId}")
    public List<CommentDTO> getComments(
            @PathVariable String targetType,
            @PathVariable String targetId
    ) {
        return service.getComments(targetType, targetId);
    }
}
