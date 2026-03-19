package bitc.next502.flutter_server.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class PostDTO {
    private Long postId;
    private String boardType;
    private String category;
    private String title;
    private String content;
    private String authorName;
    private int viewCnt;
    private int likeCnt;
    private int commentCnt;
    private String createdAt;
    private int userNum;
}