package bitc.next502.flutter_server.service;

import bitc.next502.flutter_server.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;

    @Override
    public int getUserNumByUid(String uid) {
        Integer userNum = userMapper.findUserNumByUid(uid);
        return (userNum != null) ? userNum : 0;
    }
}