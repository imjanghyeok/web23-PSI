#!/bin/bash

REPORT_FILE="benchmark_local_build.md"
echo "# Local Build Benchmark" > $REPORT_FILE

# Cleanup
docker-compose -f packages/backend/docker-compose.yml down -v 2>/dev/null
docker rmi web23-backend 2>/dev/null

echo "🚀 Starting Local Build Test..."
START_TIME=$(date +%s)

# Build locally
docker-compose -f packages/backend/docker-compose.yml build --no-cache
docker-compose -f packages/backend/docker-compose.yml up -d

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ Local Build & Run Complete"
echo "⏱️  Time: ${DURATION} seconds" >> $REPORT_FILE
echo "--------------------------------"
echo "Stats:"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | grep "web23-backend" >> $REPORT_FILE

cat $REPORT_FILE
