package bitc.next502.flutter_server.dto;


import lombok.Data;

import java.util.List;

@Data
public class CreditsDTO {
  private List<CastDTO> cast;   // 배우 리스트
  private List<CrewDTO> crew;   // 감독/작업자 리스트
}