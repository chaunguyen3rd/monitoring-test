#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Generating test data for monitoring stack...${NC}"

# Create sample logs
echo "[$(date)] [error] Test error message 1" >> webapp/logs/error.log
echo "[$(date)] [error] Test error message 2" >> webapp/logs/error.log
echo "[$(date)] [warn] Test warning message" >> webapp/logs/error.log

# Generate HTTP errors
for i in {1..10}; do
  curl -s "http://{{STACK_IP}}:9100/nonexistent-page-$i" > /dev/null
  echo -e "${GREEN}Generated 404 error $i${NC}"
  sleep 1
done

echo -e "${YELLOW}Test data generated successfully!${NC}"
echo -e "${YELLOW}Now check your Grafana dashboard at http://{{STACK_IP}}:3000${NC}"