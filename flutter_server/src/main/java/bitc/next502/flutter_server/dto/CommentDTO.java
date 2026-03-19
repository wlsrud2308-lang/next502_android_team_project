package bitc.next502.flutter_server.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CommentDTO {
    private int commentId;
    private String content;
    private int userNum;
    private int postId;
    private String targetType;
    private Integer targetId;
    private String nickname;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
