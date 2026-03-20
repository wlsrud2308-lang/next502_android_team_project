package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.BookmarkDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import bitc.next502.flutter_server.mapper.BookmarkMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BookmarkServiceImpl implements BookmarkService {

    private final BookmarkMapper bookmarkMapper;

    // 1. 북마크 토글 (추가 또는 삭제)
    @Override
    @Transactional
    public boolean toggleBookmark(BookmarkDTO bookmarkDTO) {
        // 해당 유저가 이 영화를 이미 북마크했는지 확인 (결과: 0 또는 1)
        int count = bookmarkMapper.checkBookmark(bookmarkDTO);

        if (count > 0) {
            // 이미 존재하면 삭제 (북마크 취소)
            bookmarkMapper.deleteBookmark(bookmarkDTO);
            return false; // "삭제됨" 의미로 false 반환
        } else {
            // 존재하지 않으면 추가 (북마크 등록)
            bookmarkMapper.insertBookmark(bookmarkDTO);
            return true; // "추가됨" 의미로 true 반환
        }
    }

    // 2. 유저별 북마크한 영화 ID 목록 조회
    @Override
    @Transactional(readOnly = true)
    public List<Integer> getMovieIdsByUser(int userNum) {
        return bookmarkMapper.getMovieIdsByUser(userNum);
    }

    @Override
    public List<MoviesDTO> getBookmarkDetails(int userNum) {
        return bookmarkMapper.selectBookmarkDetailsByUser(userNum);
    }
}
