#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}===============================================${NC}"
echo -e "${CYAN}     Monitoring Stack Configuration Tool${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Detect default IP
DEFAULT_IP=$(hostname -I | awk '{print $1}')
DEFAULT_HOSTNAME=$(hostname)

# Ask for IP address
echo -e "${YELLOW}What IP address would you like to use for the monitoring stack?${NC}"
echo -e "${YELLOW}This IP will be used to access Grafana, Prometheus, etc.${NC}"
echo -e "${YELLOW}Press enter to use default: ${DEFAULT_IP}${NC}"
read -p "IP Address: " STACK_IP
STACK_IP=${STACK_IP:-$DEFAULT_IP}

# Ask for hostname
echo -e "${YELLOW}What hostname would you like to use?${NC}"
echo -e "${YELLOW}Press enter to use default: ${DEFAULT_HOSTNAME}${NC}"
read -p "Hostname: " STACK_HOSTNAME
STACK_HOSTNAME=${STACK_HOSTNAME:-$DEFAULT_HOSTNAME}

# Ask for Grafana admin password
echo -e "${YELLOW}Set Grafana admin password (press enter for default: admin)${NC}"
read -s -p "Password: " GRAFANA_PASSWORD
echo ""
GRAFANA_PASSWORD=${GRAFANA_PASSWORD:-admin}

echo -e "${GREEN}Using IP: ${STACK_IP}${NC}"
echo -e "${GREEN}Using hostname: ${STACK_HOSTNAME}${NC}"
echo ""

# Create necessary directories if they don't exist
echo -e "${GREEN}Checking directory structure...${NC}"
mkdir -p {webapp/{html,logs},prometheus,alertmanager,loki,promtail,grafana/{provisioning/{datasources,dashboards},dashboards}}

# Set proper permissions for log directory
chmod -R 777 webapp/logs

# Update .env file with provided values
echo -e "${GREEN}Updating environment configuration...${NC}"
cat > .env <<EOF
# Host configuration
STACK_IP=${STACK_IP}
STACK_HOSTNAME=${STACK_HOSTNAME}

# Ports
NGINX_PORT=9100
GRAFANA_PORT=3000
PROMETHEUS_PORT=9090
ALERTMANAGER_PORT=9093
LOKI_PORT=3100

# Credentials
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
EOF

echo -e "${GREEN}Updating configuration files with your IP (${STACK_IP}) and hostname (${STACK_HOSTNAME})...${NC}"

# Update webapp NGINX config with hostname
sed -i "s/{{STACK_HOSTNAME}}/${STACK_HOSTNAME}/g" webapp/nginx.conf

# Update webapp HTML file with IP and hostname
sed -i "s/{{STACK_IP}}/${STACK_IP}/g" webapp/html/index.html
sed -i "s/{{STACK_HOSTNAME}}/${STACK_HOSTNAME}/g" webapp/html/index.html

# Update Prometheus config with hostname
sed -i "s/{{STACK_HOSTNAME}}/${STACK_HOSTNAME}/g" prometheus/prometheus.yml

# Update Promtail config with hostname
sed -i "s/{{STACK_HOSTNAME}}/${STACK_HOSTNAME}/g" promtail/promtail-config.yml

# Update monitoring-stack.yml with IP and hostname
sed -i "s/{{STACK_IP}}/\${STACK_IP}/g" monitoring-stack.yml
sed -i "s/{{STACK_HOSTNAME}}/\${STACK_HOSTNAME}/g" monitoring-stack.yml

# Update webapp.yml with hostname
sed -i "s/{{STACK_HOSTNAME}}/\${STACK_HOSTNAME}/g" webapp.yml

# Update README.md with IP
sed -i "s/{{STACK_IP}}/${STACK_IP}/g" README.md

# Update test script with IP
sed -i "s/{{STACK_IP}}/${STACK_IP}/g" test.sh

# Create a test error log to ensure the directory is writable
echo "[$(date)] [error] Setup test message" >> webapp/logs/error.log

echo -e "${GREEN}Configuration files updated successfully!${NC}"
echo -e "${CYAN}===== NEXT STEPS =====${NC}"
echo -e "${YELLOW}1. Start the web application:${NC}"
echo -e "   docker-compose --env-file .env -f webapp.yml up -d"
echo -e "${YELLOW}2. Start the monitoring stack:${NC}"
echo -e "   docker-compose --env-file .env -f monitoring-stack.yml up -d"
echo -e "${YELLOW}3. Access the web application at:${NC}"
echo -e "   http://${STACK_IP}:9100"
echo -e "${YELLOW}4. Access Grafana at:${NC}"
echo -e "   http://${STACK_IP}:3000"
echo -e "   Username: admin"
echo -e "   Password: ${GRAFANA_PASSWORD}"
echo -e "${YELLOW}5. Run the test script to generate some test data:${NC}"
echo -e "   ./test.sh"