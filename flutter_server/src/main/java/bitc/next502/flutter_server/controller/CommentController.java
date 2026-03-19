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


    @PostMapping
    public String insertComment(@RequestBody CommentDTO dto) {
        System.out.println("댓글 저장 요청: " + dto);

        service.insertComment(dto);
        return "ok";
    }


    @GetMapping("/{postId}")
    public List<CommentDTO> getComments(@PathVariable int postId) {
        return service.getComments(postId);
    }


    @PutMapping
    public String updateComment(@RequestBody CommentDTO dto) {
        service.updateComment(dto);
        return "updated";
    }


    @DeleteMapping
    public String deleteComment(@RequestBody CommentDTO dto) {
        System.out.println("삭제 요청 DTO: " + dto);
        service.deleteComment(dto);
        return "deleted";
    }
}