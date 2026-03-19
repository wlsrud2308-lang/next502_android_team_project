package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/post")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    // 1. 게시판별 목록 조회 (추가)
    // 호출 예: GET /api/post?boardType=국내
    // boardType이 없으면 전체 목록 반환
    @GetMapping
    public ResponseEntity<List<PostDTO>> getPostList(
            @RequestParam(value = "boardType", required = false) String boardType) {
        List<PostDTO> list = postService.getPostsByBoard(boardType);
        return ResponseEntity.ok(list);
    }

    // 2. 게시글 상세 조회 (조회수 증가 포함)
    @GetMapping("/{postId}")
    public ResponseEntity<PostDTO> getPostDetail(@PathVariable("postId") Long postId) {
        PostDTO post = postService.getPostDetail(postId);
        return ResponseEntity.ok(post);
    }

    // 3. 게시글 등록 (추가)
    // Flutter에서 boardType, category, title 등을 JSON으로 전달
    @PostMapping
    public ResponseEntity<String> insertPost(@RequestBody PostDTO postDTO) {
        try {
            postService.insertPost(postDTO);
            return ResponseEntity.status(HttpStatus.CREATED).body("게시글 등록 성공");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("등록 실패: " + e.getMessage());
        }
    }

    // 4. 게시글 수정
    @PutMapping("/update")
    public ResponseEntity<Boolean> updatePost(@RequestBody PostDTO postDTO) {
        boolean result = postService.updatePost(postDTO);
        return ResponseEntity.ok(result);
    }

    // 5. 게시글 삭제
    @DeleteMapping("/{postId}")
    public ResponseEntity<Boolean> deletePost(
            @PathVariable("postId") Long postId,
            @RequestParam("userNum") int userNum) {

        boolean result = postService.deletePost(postId, userNum);
        return ResponseEntity.ok(result);
    }

    // 6. 좋아요 추천
    @PostMapping("/like/{postId}")
    public ResponseEntity<Boolean> pushLike(
            @PathVariable("postId") Long postId,
            @RequestParam("userNum") int userNum) {

        boolean result = postService.pushLike(postId, userNum);
        return ResponseEntity.ok(result);
    }
}