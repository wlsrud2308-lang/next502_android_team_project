package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.service.LoginServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Controller
@RequiredArgsConstructor
public class LoginController {

  private final LoginServiceImpl loginService;

  // 회원가입 처리
  @PostMapping("/flutter/signup")
  public Object signupProcess(@RequestBody Map<String, String> map) {

    map.put("email", map.get("email"));
    map.put("password", map.get("password"));
    map.put("loginId", map.get("loginId"));
    map.put("nickname", map.get("nickname"));

    UserDTO user = new UserDTO();
    user.setEmail(map.get("email"));
    user.setPassword(map.get("password"));
    user.setLoginId(map.get("loginId"));
    user.setNickname(map.get("nickname"));

    loginService.signupUser(user);

    return user;
  }
}
