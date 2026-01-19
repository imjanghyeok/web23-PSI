#!/bin/bash

# Output file
REPORT_FILE="benchmark_report.md"
echo "# Docker Benchmark Report" > $REPORT_FILE
echo "Running benchmark... This may take a few minutes."

# cleanup function
cleanup() {
    echo "Cleaning up..."
    docker-compose -f packages/backend/docker-compose.yml down -v 2>/dev/null
    docker-compose -f packages/backend/docker-compose.dev.yml down -v 2>/dev/null
    
    # Remove specific images to ensure clean build
    docker rmi web23-backend web23-backend-dev 2>/dev/null
    
    # Prune dangling images/builders if any related to this (optional, safer to just remove known images)
    # docker builder prune -f
}

measure_local() {
    echo "## 1. Local Environment (Dockerfile.local)" >> $REPORT_FILE
    cleanup
    
    echo "Building Local..."
    BUILD_START=$(date +%s)
    docker-compose -f packages/backend/docker-compose.yml build --no-cache
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo "- **Build Time**: ${BUILD_TIME} seconds" >> $REPORT_FILE
    
    echo "Starting Local..."
    docker-compose -f packages/backend/docker-compose.yml up -d
    
    echo "Waiting 15s for startup..."
    sleep 15
    
    echo "Measuring stats..."
    STATS=$(docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | grep "web23-backend")
    MEM_USAGE=$(echo $STATS | awk '{print $2 $3}')
    
    echo "- **Memory Usage**: $MEM_USAGE" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
    echo "$STATS" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
    
    # Get Image Size
    IMG_SIZE=$(docker images --format "{{.Size}}" web23-backend)
    echo "- **Image Size**: $IMG_SIZE" >> $REPORT_FILE
}

measure_dev() {
    echo "" >> $REPORT_FILE
    echo "## 2. Dev/Prod Environment (Dockerfile.dev)" >> $REPORT_FILE
    cleanup
    
    echo "Building Dev..."
    BUILD_START=$(date +%s)
    docker-compose -f packages/backend/docker-compose.dev.yml build --no-cache
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo "- **Build Time**: ${BUILD_TIME} seconds" >> $REPORT_FILE
    
    echo "Starting Dev..."
    docker-compose -f packages/backend/docker-compose.dev.yml up -d
    
    echo "Waiting 15s for startup..."
    sleep 15
    
    echo "Measuring stats..."
    STATS=$(docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.CPUPerc}}" | grep "web23-backend-dev")
    MEM_USAGE=$(echo $STATS | awk '{print $2 $3}')
    
    echo "- **Memory Usage**: $MEM_USAGE" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
    echo "$STATS" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE

     # Get Image Size
    IMG_SIZE=$(docker images --format "{{.Size}}" web23-backend-dev)
    echo "- **Image Size**: $IMG_SIZE" >> $REPORT_FILE
}

# Run
measure_local
measure_dev
cleanup

echo "Benchmark Complete. Results in $REPORT_FILE"
cat $REPORT_FILE
