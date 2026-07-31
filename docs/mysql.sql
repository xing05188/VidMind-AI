-- =============================================================
-- VidMind-AI  MySQL 建表脚本 (media_db)
-- 数据库: media_db  |  字符集: utf8mb4  |  引擎: InnoDB
-- 应用启动时会通过 spring.sql.init.mode=always 自动执行 schema.sql
-- =============================================================

-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id       BIGINT       NOT NULL AUTO_INCREMENT,
    username VARCHAR(32)  NOT NULL,
    password VARCHAR(255) NOT NULL,                   -- 加密存储，接口返回时 @JsonIgnore 屏蔽
    nickname VARCHAR(50)  NOT NULL,
    avatar   VARCHAR(512) NULL,                       -- 头像 URL
    role     VARCHAR(32)  NOT NULL DEFAULT 'USER',    -- USER / ADMIN
    PRIMARY KEY (id),
    UNIQUE KEY uk_users_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 媒体文件表（上传的视频及其分析结果）
CREATE TABLE IF NOT EXISTS media_files (
    id            BIGINT        NOT NULL AUTO_INCREMENT,
    user_id       BIGINT        NOT NULL,             -- 关联 users.id
    filename      VARCHAR(255)  NOT NULL,             -- 规范化后的视频文件名
    status        VARCHAR(32)   NOT NULL,             -- COMPLETED / 分析中状态
    file_path     VARCHAR(1024) NOT NULL,             -- MinIO 对象 URL
    ai_summary    LONGTEXT      NULL,                 -- AI 生成的整体摘要
    transcript_text LONGTEXT    NULL,                 -- 转写后的全部字幕文本
    cover_url     VARCHAR(1024) NULL,                 -- 封面图 URL
    upload_time   TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY idx_media_user_time  (user_id, upload_time),
    KEY idx_media_status_time (status, upload_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Agent 断点检查点表（长视频分析的可恢复状态）
-- media_id + checkpoint_key 为主键，payload 为 JSON 序列化的中间状态
CREATE TABLE IF NOT EXISTS agent_checkpoints (
    media_id      BIGINT       NOT NULL,              -- 关联 media_files.id
    checkpoint_key VARCHAR(160) NOT NULL,             -- 检查点名称（支持前缀删除）
    stage         VARCHAR(64)  NOT NULL,             -- 当前阶段（TaskStage 枚举）
    payload       LONGTEXT     NULL,                 -- JSON 序列化的中间数据
    updated_at    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                              ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (media_id, checkpoint_key),
    KEY idx_agent_checkpoint_updated (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 失败分析任务表（重试 / 死信队列回放用）
CREATE TABLE IF NOT EXISTS failed_analysis_tasks (
    id            BIGINT        NOT NULL AUTO_INCREMENT,
    media_id      BIGINT        NOT NULL,             -- 关联 media_files.id
    action        VARCHAR(32)   NOT NULL,             -- 失败的动作类型
    content_hash  VARCHAR(128)  NOT NULL,             -- 内容 MD5，用于去重
    user_goal     VARCHAR(500)  NOT NULL,             -- 用户分析目标
    attempt_count INT           NOT NULL,             -- 已尝试次数
    error_type    VARCHAR(128)  NOT NULL,             -- 错误类型标识
    error_message VARCHAR(1000) NULL,                -- 错误详情
    status        VARCHAR(32)   NOT NULL DEFAULT 'FAILED',
    created_at    TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at    TIMESTAMP(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                              ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    KEY idx_failed_analysis_status_time (status, created_at),
    KEY idx_failed_analysis_media (media_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
