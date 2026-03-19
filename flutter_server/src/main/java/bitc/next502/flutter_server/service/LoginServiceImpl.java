package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.dto.WithdrawalDTO;
import bitc.next502.flutter_server.mapper.LoginMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LoginServiceImpl implements LoginService {

  private final LoginMapper loginMapper;

  // 1. 회원가입
  @Override
  public void signupUser(UserDTO user) {
    loginMapper.insertUser(user);
  }

  // 2. 유저 정보 조회 (UID 기준)
  @Override
  public UserDTO getUserByUid(String uid) {
    return loginMapper.getUserByUid(uid);
  }

  // 서비스 탈퇴 (사유 저장 + 유저 삭제)
  @Override
  @Transactional
  public void withdrawUser(WithdrawalDTO dto) {
    //  탈퇴 사유 테이블에 데이터 저장
    loginMapper.insertWithdrawalReason(dto);

    //  유저 테이블에서 해당 유저 삭제
    loginMapper.deleteUserByUid(dto.getUid());
  }
}