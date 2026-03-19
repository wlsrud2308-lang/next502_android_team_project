package bitc.next502.flutter_server.controller;
import bitc.next502.flutter_server.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/num")
    public ResponseEntity<Integer> getUserNum(@RequestParam("uid") String uid) {
        int userNum = userService.getUserNumByUid(uid);

        if (userNum > 0) {
            return ResponseEntity.ok(userNum);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}