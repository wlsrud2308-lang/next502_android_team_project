package bitc.next502.flutter_server.dto;

import lombok.Data;

@Data
public class WithdrawalDTO {
    private String uid;    // 파이어베이스 UID (유저 식별용)
    private String email;  // 탈퇴 기록용 이메일
    private String reason; // 탈퇴 사유
}