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

// CommentController.java 수정

    @DeleteMapping
// @RequestParam 대신 @RequestBody를 사용하여 JSON 데이터를 받습니다.
    public String deleteComment(@RequestBody CommentDTO dto) {
        // 이제 Flutter에서 보낸 { "commentId": 3, "userNum": 3 } 데이터가
        // dto 객체의 commentId와 userNum 필드에 자동으로 매핑됩니다.
        System.out.println("삭제 요청 DTO: " + dto);

        service.deleteComment(dto);
        return "deleted";
    }
}