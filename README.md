# Container Monitoring Stack

A focused monitoring solution for Docker containers using cAdvisor, Prometheus, Grafana, and Loki. This stack provides real-time container metrics and log monitoring with a custom 3-panel dashboard.

## Components

- **NGINX Web Application** (Port 9100): Demo application to monitor
- **Prometheus** (Port 9090): Metrics collection and alerting
- **Grafana** (Port 3000): Visualization and dashboards
- **cAdvisor** (Port 8080): Container metrics collection
- **Loki** (Port 3100): Log aggregation
- **Alertmanager** (Port 9093): Alert management
- **Promtail**: Log collection agent

## Quick Start

1. Run the setup script to configure IP addresses:

   ```bash
   ./setup.sh
   ```

2. Start the web application:

   ```bash
   docker-compose --env-file .env -f webapp.yml up -d
   ```

3. Start the monitoring stack:

   ```bash
   docker-compose --env-file .env -f monitoring-stack.yml up -d
   ```

4. Access the web application at http://{{STACK_IP}}:9100
5. Access Grafana at http://{{STACK_IP}}:3000 (login: admin / password)
6. Access cAdvisor at http://{{STACK_IP}}:8080 to see raw container metrics

## Dashboard Overview

The dashboard has three focused panels designed to monitor the container on port 9100:

1. **CPU Usage Panel**
   - Shows real-time CPU usage percentage that matches `docker stats`
   - Alerts when CPU > 90% for 10 minutes

2. **Memory Usage Panel**
   - Shows real-time memory usage in MB that matches `docker stats`
   - Helps identify memory issues or leaks

3. **Error Logs Panel**
   - Counts error logs from the container
   - Shows trends in error frequency over time

## Testing the Monitoring

### CPU Usage Test

To test CPU monitoring and alerts:

```bash
# Connect to your webapp container
docker exec -it webapp /bin/bash

# Install stress-ng if not already available
apt-get update && apt-get install -y stress-ng

# Run a stress test for ~12 minutes (to trigger the 10-minute alert)
stress-ng --cpu 1 --cpu-load 95 --timeout 12m
```

### Error Logs Test

To generate test error logs:

```bash
# Use the included test script
./test.sh

# Or generate errors manually
for i in {1..10}; do
  curl -s "http://{{STACK_IP}}:9100/nonexistent-page-$i" > /dev/null
  echo "Generated 404 error $i"
  sleep 1
done
```

## Directory Structure

```
monitoring-stack/
├── .env                              # Environment configuration
├── webapp.yml                        # Web application Docker Compose
├── monitoring-stack.yml              # Monitoring stack Docker Compose
├── setup.sh                          # Setup script
├── test.sh                           # Test data generator
├── README.md                         # Documentation
├── webapp/
│   ├── html/                         # Web content
│   │   └── index.html                # Demo page
│   ├── nginx.conf                    # NGINX configuration
│   └── logs/                         # Log directory
├── prometheus/
│   ├── prometheus.yml                # Prometheus configuration
│   └── alert.rules                   # Alert definitions
├── alertmanager/
│   └── alertmanager.yml              # Alertmanager configuration
├── grafana/
│   ├── dashboards/                   # Grafana dashboards
│   │   └── container-dashboard.json  # Container monitoring dashboard
│   └── provisioning/                 # Grafana auto-configuration
│       ├── dashboards/               # Dashboard provisioning
│       │   └── dashboards.yml        # Dashboard config
│       └── datasources/              # Data source provisioning
│           └── datasources.yml       # Data source config
└── promtail/
    └── promtail-config.yml           # Promtail configuration
```

## Key Features

- **Container-Level Metrics**: CPU and memory usage metrics that match `docker stats`
- **Accurate CPU Alerts**: Alerts trigger when container CPU usage exceeds 90% for 10 minutes
- **Error Log Tracking**: Visualize error frequency from container logs
- **Lightweight**: Focused components for efficient monitoring

## Customization

- Edit the `.env` file to change ports or credentials
- Modify Prometheus alerts in `prometheus/alert.rules`
- Adjust the dashboard in Grafana or import a new version
- Customize Promtail log collection in `promtail/promtail-config.yml`

## Troubleshooting

If panels show "No data":

1. **CPU/Memory Panels**:
   - Verify cAdvisor is running: `docker ps | grep cadvisor`
   - Check Prometheus targets: http://{{STACK_IP}}:9090/targets
   - Adjust container labels in dashboard queries if needed

2. **Error Logs Panel**:
   - Verify Loki is running: `docker ps | grep loki`
   - Check Promtail is collecting logs: `docker logs promtail`
   - Ensure log paths in `promtail-config.yml` are correct
