package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class MovieDTO {
    // 플러터에서 보낸 JSON 키값과 정확히 똑같은 이름이어야 데이터가 담깁니다!
    private String rnum;
    private String rank;
    private String rankInten;
    private String rankOldAndNew;
    private String movieCd;
    private String movieNm;
    private String openDt;
}