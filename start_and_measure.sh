#!/bin/bash

echo "🚀 Starting Dev Environment (Build & Up)..."

# 시작 시간 기록
START_TIME=$(date +%s)

# 빌드 및 실행
docker-compose -f packages/backend/docker-compose.dev.yml up -d --build

# 종료 시간 기록
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "------------------------------------------------"
echo "✅ Startup Complete"
echo "⏱️  Total Time (Build + Boot): ${DURATION} seconds"
echo "------------------------------------------------"

echo "⏳ Waiting 10s for application to stabilize..."
sleep 10

echo "📊 Memory & CPU Usage:"
# 헤더 출력 및 특정 컨테이너 필터링
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | head -n 1
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | grep "web23-backend-dev"

echo "------------------------------------------------"
