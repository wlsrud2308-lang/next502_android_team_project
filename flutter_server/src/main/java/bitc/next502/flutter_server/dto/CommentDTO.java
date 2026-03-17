package bitc.next502.flutter_server.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CommentDTO {
    private int commentId;
    private String content;
    private String userNum;
    private String targetType;
    private String targetId;
    private String nickname;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
