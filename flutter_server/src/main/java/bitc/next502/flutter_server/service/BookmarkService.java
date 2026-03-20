package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.BookmarkDTO;
import java.util.List;

public interface BookmarkService {

    /**
     * 북마크 토글:
     * 이미 존재하면 삭제(false 반환), 없으면 추가(true 반환)
     */
    boolean toggleBookmark(BookmarkDTO bookmarkDTO);

    /**
     * 특정 사용자가 북마크한 영화 ID 리스트 조회
     * (Flutter 앱 시작 시 하트/별 아이콘 색칠용)
     */
    List<Integer> getMovieIdsByUser(int userNum);
}