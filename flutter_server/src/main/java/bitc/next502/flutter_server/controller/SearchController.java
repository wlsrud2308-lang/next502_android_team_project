package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.MoviesDTO;
import bitc.next502.flutter_server.dto.PostDTO;
import bitc.next502.flutter_server.dto.SearchResultDTO;
import bitc.next502.flutter_server.service.MoviesService;
import bitc.next502.flutter_server.service.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/flutter")
@RequiredArgsConstructor
public class SearchController {

  private final MoviesService moviesService;
  private final PostService postService;

  // 🔹 영화 + 게시글 통합 검색
  @GetMapping("/search")
  public ResponseEntity<SearchResultDTO> search(@RequestParam("query") String query) {
    // 1️⃣ 영화 검색
    List<MoviesDTO> movies = moviesService.searchMovies(query);

    // 2️⃣ 게시글 검색
    List<PostDTO> posts = postService.searchPosts(query);

    // 3️⃣ 통합 결과 반환
    SearchResultDTO result = new SearchResultDTO(movies, posts);
    return ResponseEntity.ok(result);
  }
}