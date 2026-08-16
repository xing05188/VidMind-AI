package com.example.server.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.data.redis.RedisProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisPassword;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.lettuce.LettuceConnectionFactory;

/**
 * 为 Spring Data Redis（StringRedisTemplate 等）提供标准的 Lettuce 连接工厂。
 *
 * 背景：项目同时引入 redisson-spring-boot-starter 3.23.5，其 RedissonConnectionFactory
 * 与 spring-data-redis 3.5.x 接口不兼容，StringRedisTemplate 的 expire() 会落入
 * DefaultedRedisConnection 的默认方法 pExpire/expire 互相递归，导致 StackOverflowError
 * （表现：分片上传 init-upload 返回 500）。
 *
 * 此处显式提供 LettuceConnectionFactory，满足 RedissonAutoConfiguration 的
 * {@code @ConditionalOnMissingBean(RedisConnectionFactory.class)} 条件，使 Redisson 的
 * connection factory 自动退位；RedissonClient（分布式锁/限流）保持独立、互不影响。
 */
@Configuration
public class RedisConfig {

    @Bean
    @ConditionalOnMissingBean(RedisConnectionFactory.class)
    public RedisConnectionFactory redisConnectionFactory(RedisProperties properties) {
        RedisStandaloneConfiguration configuration = new RedisStandaloneConfiguration();
        configuration.setHostName(properties.getHost());
        configuration.setPort(properties.getPort());
        configuration.setDatabase(properties.getDatabase());
        if (properties.getPassword() != null) {
            configuration.setPassword(RedisPassword.of(properties.getPassword()));
        }
        return new LettuceConnectionFactory(configuration);
    }
}
