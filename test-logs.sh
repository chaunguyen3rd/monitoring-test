#!/bin/bash

# Create necessary directories
mkdir -p webapp/logs
touch webapp/logs/access.log
touch webapp/logs/error.log
chmod -R 777 webapp/logs

# Restart the containers
echo "Restarting containers..."
docker-compose -f webapp.yml down
docker-compose -f monitoring-stack.yml down
docker-compose -f webapp.yml up -d
docker-compose -f monitoring-stack.yml up -d

# Wait for services to start
echo "Waiting for services to start..."
sleep 10

# Generate some test error logs
echo "Generating test error logs..."
for i in {1..10}; do
  curl -s "http://localhost:9100/nonexistent-page" > /dev/null
  echo "Generated error log $i"
  sleep 2
done

# Show log status
echo "Checking NGINX error logs:"
tail -n 5 webapp/logs/error.log

echo "Checking Promtail logs:"
docker logs promtail | tail -n 20

echo "Setup complete! You should now see errors in your Grafana dashboard."
echo "Visit http://localhost:3000 and check the 'Error Count from Logs' panel."