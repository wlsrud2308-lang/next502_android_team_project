package bitc.next502.flutter_server.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class BookmarkDTO {
    private int id;
    private int userNum;
    private int movieId;
    private LocalDateTime createdAt;
}