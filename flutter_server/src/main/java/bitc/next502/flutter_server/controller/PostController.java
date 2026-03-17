package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/post")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @GetMapping("/{postId}")
    public ResponseEntity<PostDTO> getPostDetail(@PathVariable("postId") Long postId) {
        return ResponseEntity.ok(postService.getPostDetail(postId));
    }

    @PostMapping("/like/{postId}")
    public ResponseEntity<Boolean> pushLike(
            @PathVariable("postId") Long postId,
            @RequestParam("userNum") int userNum) {

        boolean result = postService.pushLike(postId, userNum);
        return ResponseEntity.ok(result);
    }
}