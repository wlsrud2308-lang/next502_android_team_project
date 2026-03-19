package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.service.LoginServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/flutter")
public class LoginController {

  private final LoginServiceImpl loginService;

  @PostMapping("/signup")
  public Object signup(@RequestBody UserDTO user){
    loginService.signupUser(user);
    return user;
  }

  // 플러터에서 UID로 내 정보 조회
  @GetMapping("/user/{uid}")
  public ResponseEntity<UserDTO> getUserInfo(@PathVariable("uid") String uid) {
    UserDTO user = loginService.getUserByUid(uid);
    if (user != null) {
      return ResponseEntity.ok(user);
    } else {
      return ResponseEntity.notFound().build();
    }
  }
}