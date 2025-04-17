# Monitoring Stack

A complete monitoring setup for web applications with Grafana, Prometheus, Loki, and Alertmanager.

## Components

- **NGINX Web Application** (Port 9100): Demo application to monitor
- **Prometheus** (Port 9090): Metrics collection and alerting
- **Grafana** (Port 3000): Visualization and dashboards
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

## Testing the Monitoring

The dashboard has three panels:

- CPU Usage
- Memory Usage
- Error Count from logs

To generate test data:

- Visit http://{{STACK_IP}}:9100 and use the "Generate CPU Load" button
- Run the test script: `./test.sh`
- The log-generator service will automatically create error logs

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
│   │   └── nginx-dashboard.json      # NGINX monitoring dashboard
│   └── provisioning/                 # Grafana auto-configuration
│       ├── dashboards/               # Dashboard provisioning
│       │   └── dashboards.yml        # Dashboard config
│       └── datasources/              # Data source provisioning
│           └── datasources.yml       # Data source config
└── promtail/
    └── promtail-config.yml           # Promtail configuration
```

## Customization

- Edit the `.env` file to change ports or credentials
- Modify Prometheus alerts in `prometheus/alert.rules`
- Add more dashboards to `grafana/dashboards/`
