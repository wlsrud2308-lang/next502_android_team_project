package bitc.next502.flutter_server.controller;

import bitc.next502.flutter_server.dto.UserDTO;
import bitc.next502.flutter_server.dto.WithdrawalDTO;
import bitc.next502.flutter_server.service.LoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/flutter")
public class LoginController {


  private final LoginService loginService;

  @PostMapping("/signup")
  public Object signup(@RequestBody UserDTO user){
    loginService.signupUser(user);
    return user;
  }


  @PostMapping("/withdraw")
  public ResponseEntity<String> withdraw(@RequestBody WithdrawalDTO dto) {

    loginService.withdrawUser(dto);
    return ResponseEntity.ok("탈퇴 완료");
  }

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