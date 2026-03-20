package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.BookmarkDTO;
import bitc.next502.flutter_server.service.BookmarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/bookmark") // 기존 API들과 경로 통일
public class BookmarkController {

    @Autowired
    private BookmarkService bookmarkService;

    // 북마크 토글 (추가/삭제를 하나로 처리)
    @PostMapping
    public ResponseEntity<Boolean> toggleBookmark(@RequestBody BookmarkDTO bookmarkDTO) {
        // 서비스에서 이미 존재하면 삭제, 없으면 추가하는 로직 구현
        boolean isAdded = bookmarkService.toggleBookmark(bookmarkDTO);
        return ResponseEntity.ok(isAdded);
    }

    // 특정 유저의 북마크 리스트 조회 (앱 시작 시 아이콘 표시용)
    @GetMapping("/{userNum}")
    public List<Integer> getMyBookmarks(@PathVariable int userNum) {
        return bookmarkService.getMovieIdsByUser(userNum);
    }
}