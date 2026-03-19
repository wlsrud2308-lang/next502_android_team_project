package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.mapper.LoginMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LoginServiceImpl implements LoginService {

  private final LoginMapper loginMapper;

  @Override
  public void signupUser(UserDTO user) {
    loginMapper.insertUser(user);
  }

  // 🔥 누락되었던 메서드 구현부 추가
  @Override
  public UserDTO getUserByUid(String uid) {
    return loginMapper.getUserByUid(uid);
  }
}