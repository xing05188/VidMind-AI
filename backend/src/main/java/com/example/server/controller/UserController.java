package com.example.server.controller;

import com.example.server.dto.AuthRequest;
import com.example.server.dto.AuthResponse;
import com.example.server.entity.User;
import com.example.server.mapper.UserMapper;
import com.example.server.service.AuthService;
import com.example.server.utils.MinioUtils;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/user")
public class UserController {

    private final AuthService authService;
    private final UserMapper userMapper;
    private final MinioUtils minioUtils;

    public UserController(AuthService authService, UserMapper userMapper, MinioUtils minioUtils) {
        this.authService = authService;
        this.userMapper = userMapper;
        this.minioUtils = minioUtils;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody AuthRequest request) {
        return response(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        return response(authService.login(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<AuthResponse> logout(@RequestHeader("Authorization") String authorization) {
        authService.revokeSession(authorization);
        return response(new AuthResponse(200, "已退出登录", null, null));
    }

    @PostMapping("/avatar")
    public ResponseEntity<AuthResponse> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        try {
            Long userId = authService.resolveUser(authorization);
            return response(authService.updateAvatar(userId, file));
        } catch (SecurityException e) {
            return response(new AuthResponse(401, e.getMessage(), null, null));
        }
    }

    @GetMapping("/avatar/{userId}")
    public ResponseEntity<StreamingResponseBody> avatar(@PathVariable Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null || user.getAvatar() == null || user.getAvatar().isBlank()) {
            return ResponseEntity.notFound().build();
        }
        try {
            String contentType = minioUtils.contentType(user.getAvatar());
            String avatarUrl = user.getAvatar();
            StreamingResponseBody body = output -> {
                try (InputStream inputStream = minioUtils.open(avatarUrl)) {
                    inputStream.transferTo(output);
                } catch (Exception e) {
                    throw new java.io.IOException("头像读取失败", e);
                }
            };
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .cacheControl(CacheControl.maxAge(1, TimeUnit.DAYS).cachePublic())
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline")
                    .body(body);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    private ResponseEntity<AuthResponse> response(AuthResponse result) {
        return ResponseEntity.status(result.code()).body(result);
    }
}
