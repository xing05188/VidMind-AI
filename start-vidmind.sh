#!/bin/bash
# ==========================================
#  VidMind-AI 一键启动脚本
#  说明：redis 复用 TJNovel 的容器(6379, 无密码)，不单独启动
#  启动顺序：Docker 中间件 -> 后端(9090) -> 前端(5173)
# ==========================================
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$BASE_DIR/backend"
FRONTEND_DIR="$BASE_DIR/frontend"
ENV_FILE="$BASE_DIR/.env"
BACKEND_PORT=9090
FRONTEND_PORT=5173

# 优先使用安装好的 Node 20（Vite 需要 Node >= 20）
NODE20="/home/zhx/.workbuddy/binaries/node/versions/20.18.0/bin"
if [ -d "$NODE20" ]; then
  export PATH="$NODE20:$PATH"
fi

echo "=========================================="
echo "  启动 VidMind-AI  (node $(node -v))"
echo "=========================================="

# ---------- 1. Docker 中间件（不含 redis，复用 TJNovel 的）----------
echo "[1/3] 启动 Docker 中间件 (mysql/minio/qdrant/rocketmq) ..."
cd "$BASE_DIR"
docker compose start mysql minio qdrant rmqnamesrv rmqbroker rmqdashboard

echo "      等待 MySQL (3306) 就绪 ..."
for i in $(seq 1 30); do
  if (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -q ':3306'; then break; fi
  sleep 2
done

# ---------- 2. 后端 ----------
echo "[2/3] 启动后端 ($BACKEND_PORT) ..."
JAR="$BACKEND_DIR/target/server-0.0.1-SNAPSHOT.jar"
if [ ! -f "$JAR" ]; then
  echo "  ⚠️  未找到 $JAR，正在编译 ..."
  (cd "$BACKEND_DIR" && chmod +x mvnw && ./mvnw -q clean package -DskipTests)
fi

if (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -q ":$BACKEND_PORT "; then
  echo "  • 后端 ($BACKEND_PORT) 已在运行，跳过"
else
  # 加载 .env 注入 DB_PASSWORD / REDIS_HOST 等
  if [ -f "$ENV_FILE" ]; then
    set -a && source "$ENV_FILE" && set +a
  fi
  cd "$BACKEND_DIR"
  nohup java -jar "$JAR" > "$BACKEND_DIR/vidmind-backend.log" 2>&1 &
  echo "  • 后端 ($BACKEND_PORT) 启动中 [pid=$!]"
  for i in $(seq 1 40); do
    if (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -q ":$BACKEND_PORT "; then break; fi
    sleep 2
  done
fi

# ---------- 3. 前端 ----------
echo "[3/3] 启动前端 ($FRONTEND_PORT) ..."
if (ss -ltn 2>/dev/null || netstat -ltn 2>/dev/null) | grep -q ":$FRONTEND_PORT "; then
  echo "  • 前端 ($FRONTEND_PORT) 已在运行，跳过"
else
  cd "$FRONTEND_DIR"
  nohup npm run dev > "$FRONTEND_DIR/vidmind-frontend.log" 2>&1 &
  echo "  • 前端 ($FRONTEND_PORT) 启动中 [pid=$!]"
fi

echo ""
echo "=========================================="
echo "  VidMind-AI 启动完成"
echo "  前端:  http://localhost:5173/"
echo "  后端:  http://localhost:9090/"
echo "  日志:  $BACKEND_DIR/vidmind-backend.log"
echo "         $FRONTEND_DIR/vidmind-frontend.log"
echo "=========================================="
