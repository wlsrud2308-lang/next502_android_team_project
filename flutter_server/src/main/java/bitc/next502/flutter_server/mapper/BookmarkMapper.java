package bitc.next502.flutter_server.mapper;

import bitc.next502.flutter_server.dto.BookmarkDTO;
import bitc.next502.flutter_server.dto.MoviesDTO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface BookmarkMapper {

    // 1. 특정 유저가 특정 영화를 이미 북마크했는지 확인 (결과가 0보다 크면 존재함)
    int checkBookmark(BookmarkDTO bookmarkDTO);

    // 2. 북마크 추가 (Insert)
    void insertBookmark(BookmarkDTO bookmarkDTO);

    // 3. 북마크 삭제 (Delete)
    void deleteBookmark(BookmarkDTO bookmarkDTO);

    // 4. 유저별 북마크한 모든 영화 ID 리스트 조회
    List<Integer> getMovieIdsByUser(int userNum);

    List<MoviesDTO> selectBookmarkDetailsByUser(int userNum);
}