# Docker Monitoring Stack

This project sets up a complete monitoring stack using Docker Compose, including:

- NGINX Web Application (running on port 9100)
- NGINX Prometheus Exporter (for metrics collection)
- Prometheus (metrics storage and alerting)
- Grafana (visualization)
- Loki (log aggregation)
- Alertmanager (alert management)
- Promtail (for log collection)

## Directory Structure

```txt
monitoring-stack/
├── alertmanager/
│   └── alertmanager.yml
├── grafana/
│   ├── dashboards/
│   │   └── nginx-dashboard.json
│   └── provisioning/
│       ├── dashboards/
│       │   └── dashboards.yml
│       └── datasources/
│           └── datasources.yml
├── loki/
│   └── loki-config.yml
├── prometheus/
│   ├── alert.rules
│   └── prometheus.yml
├── promtail/
│   └── promtail-config.yml
├── webapp/
│   ├── html/
│   │   └── index.html
│   └── nginx.conf
├── monitoring-stack.yml
├── webapp.yml
└── README.md
```

## Setup Instructions

1. Create the directory structure as shown above.
2. Copy all configuration files to their respective locations.
3. Start the web application container first:

    ```bash
    docker-compose -f webapp.yml up -d
    ```

4. Start the monitoring stack:

    ```bash
    docker-compose -f monitoring-stack.yml up -d
    ```

5. Access Grafana at <http://localhost:3000> (username: admin, password: admin)
6. The dashboard should be automatically provisioned with three panels:
   - CPU Usage
   - Memory Usage
   - Error Count from logs
7. Access the web application at <http://localhost:9100>

## Alert Configuration

Several alert rules have been configured:

- CPU usage > 90% for more than 10 minutes
- High connection count (more than 100 active connections)
- HTTP error rate > 5% for more than 5 minutes

These alerts are visible in both Prometheus and Alertmanager, and will also appear in Grafana.

## Additional Information

- Prometheus is available at <http://localhost:9090>
- Alertmanager is available at <http://localhost:9093>
- Loki is available at <http://localhost:3100>

## Troubleshooting

If you don't see metrics or logs:

1. Check that all containers are running: `docker ps`
2. Check container logs: `docker logs [container_name]`
3. Verify network connectivity between containers

## Testing Alerts

To test the alerts:

1. **CPU Usage Alert**:
   - Use the "Generate CPU Load" button on the web application
   - For a more sustained load, you can run: `docker exec -it webapp sh -c "for i in {1..1000000}; do echo 'calculating'; done"`

2. **High Connection Count Alert**:
   - Use a load testing tool like Apache Bench: `ab -n 1000 -c 100 http://localhost:9100/`

3. **HTTP Error Rate Alert**:
   - Request non-existent pages: `curl http://localhost:9100/not-found`
   - You can script this to generate multiple errors
