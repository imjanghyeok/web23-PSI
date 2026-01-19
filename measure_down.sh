#!/bin/bash

# 종료 시작 시간 측정
echo "🔴 Stopping and removing containers (Dev Environment)..."
START_TIME=$(date +%s)

# 명령어 실행 (에러/로그는 화면에 출력)
docker-compose -f packages/backend/docker-compose.dev.yml down -v

# 종료 완료 시간 측정
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "------------------------------------------------"
echo "✅ Shutdown Complete"
echo "⏱️  Time taken: ${DURATION} seconds"
echo "------------------------------------------------"
