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

    //  댓글 저장
    @PostMapping
    public String insertComment(@RequestBody CommentDTO dto) {
        service.insertComment(dto);
        return "ok";
    }

    //  댓글 조회 (postId 기준으로 변경)
    @GetMapping("/{postId}")
    public List<CommentDTO> getComments(@PathVariable int postId) {
        return service.getComments(postId);
    }

    //  댓글 수정 추가
    @PutMapping
    public String updateComment(@RequestBody CommentDTO dto) {
        service.updateComment(dto);
        return "updated";
    }

    //  댓글 삭제 추가
    @DeleteMapping
    public String deleteComment(@RequestBody CommentDTO dto) {
        service.deleteComment(dto);
        return "deleted";
    }
}