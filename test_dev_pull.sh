#!/bin/bash

REPORT_FILE="benchmark_dev_pull.md"
echo "# Dev Pull & Run Benchmark" > $REPORT_FILE

# Cleanup
docker-compose -f packages/backend/docker-compose.dev.yml down -v 2>/dev/null
# Remove local image to force pull/build-simulation
docker rmi ${DOCKER_USERNAME}/web23-backend:latest 2>/dev/null

echo "🚀 Starting Dev Pull Test..."
echo "ℹ️  Simulating GitHub Actions Build (Skipping local build time in measurement logic if image exists, but forced here)"

# 실제로는 'docker pull' 시간이겠지만, 로컬 테스트를 위해선 이미지가 있어야 하므로
# 1. 이미지가 없으면 빌드 (GitHub Actions 역할)
if [[ "$(docker images -q ${DOCKER_USERNAME}/web23-backend:latest 2> /dev/null)" == "" ]]; then
  echo "⚠️  Image not found locally. Building first (Simulation of GitHub Actions)..."
  docker build -t ${DOCKER_USERNAME}/web23-backend:latest -f packages/backend/Dockerfile.dev .
fi

START_TIME=$(date +%s)

# Server Action: Pull & Up
# (로컬 이미지를 사용하므로 Pull 시간은 0에 수렴하겠지만, 기동 시간을 측정)
docker-compose -f packages/backend/docker-compose.dev.yml up -d

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ Dev Run Complete"
echo "⏱️  Time (Startup only): ${DURATION} seconds" >> $REPORT_FILE
echo "--------------------------------"
echo "Stats:"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | grep "web23-backend-dev" >> $REPORT_FILE

cat $REPORT_FILE
