# Observability, Monitoring & Alerting Guide

## 1. Observability Architecture Overview

The monitoring framework is designed on the **RED Method** (Rate, Errors, Duration) for services and the **USE Method** (Utilization, Saturation, Errors) for host nodes.

```text
[ Docker Containers ] ----> [ cAdvisor (Global Port 8080) ] ----\
[ Host Instances    ] ----> [ Node Exporter (Global Port 9100) ] ---> [ Prometheus Server (Port 9090) ] ---> [ Grafana (Port 3000) ]
[ FastAPI App       ] ----> [ /metrics Endpoint (Port 8000) ] --/             |
                                                                              v
[ Container Logs    ] ----> [ Promtail Shipper ] ---------------> [ Loki Log Store (Port 3100) ]
```

---

## 2. Key Metrics & PromQL Query Reference

### Application Layer (RED Metrics)
- **Request Rate (Throughput)**:
  ```promql
  sum(rate(enterprise_http_requests_total[1m])) by (endpoint)
  ```
- **Error Rate (HTTP 5xx)**:
  ```promql
  sum(rate(enterprise_http_requests_total{status_code=~"5.."}[1m])) / sum(rate(enterprise_http_requests_total[1m])) * 100
  ```
- **p95 Request Duration (Latency)**:
  ```promql
  histogram_quantile(0.95, sum(rate(enterprise_http_request_duration_seconds_bucket[5m])) by (le, endpoint))
  ```

### Container Infrastructure Layer (cAdvisor)
- **Container CPU Utilization**:
  ```promql
  sum by (container_label_com_docker_swarm_service_name) (rate(container_cpu_user_seconds_total[1m])) * 100
  ```
- **Container Memory Consumption**:
  ```promql
  sum by (container_label_com_docker_swarm_service_name) (container_memory_usage_bytes)
  ```

### Host Node Layer (Node Exporter)
- **Node CPU Utilization (%)**:
  ```promql
  100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
  ```
- **Node Memory Utilization (%)**:
  ```promql
  (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
  ```
- **Node Disk Space Utilization (%)**:
  ```promql
  (1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
  ```

---

## 3. Configured Alert Rules Matrix

The alerts defined in `monitoring/prometheus/alert.rules.yml` include:

| Alert Name | Condition | Duration | Severity | Action Triggered |
|:---|:---|:---|:---|:---|
| `ServiceDown` | `up == 0` | 1m | **Critical** | Triggers container restart probe & PagerDuty notification |
| `HostHighCpuLoad` | Host CPU > 85% | 2m | **Warning** | Auto Scaling Group launches additional worker instance |
| `HostOutOfMemory` | Available RAM < 10% | 2m | **Critical** | Alert operations; investigate memory leak |
| `HostDiskSpaceFillingUp`| Root disk free < 15% | 5m | **Warning** | Automated Docker container/image prune script invoked |
| `ContainerHighMemoryUsage`| Container memory > 90% of limit | 2m | **Warning** | Review service memory allocation |
| `HighRequestLatency` | p95 latency > 1.0s | 2m | **Warning** | Check database connection pool and query performance |

---

## 4. Grafana Dashboards

The repository ships with pre-provisioned dashboards in `monitoring/grafana/dashboards/`:
1. **Docker Swarm Cluster & Services Overview** (`uid: enterprise-swarm-overview`):
   - Real-time container count.
   - Aggregate request throughput (req/s).
   - p95 and p99 response latency.
   - Per-service CPU and Memory time-series graphs.
2. **Host Node Infrastructure Metrics** (`uid: enterprise-host-metrics`):
   - Host CPU percentage per instance.
   - Host RAM consumption and swap usage.
   - Disk read/write I/O operations per second.
   - Network interface ingress and egress throughput.

---

## 5. Centralized Log Aggregation with Loki & Promtail

- **Log Collection**: Promtail runs as a global Docker service on every Swarm node, capturing stdout/stderr logs from `/var/lib/docker/containers/*/*.log`.
- **Log Querying in Grafana**:
  Open Grafana -> Explore -> Select Data Source: `Loki`
  - View all logs from the API service:
    ```logql
    {job="docker"} |= "enterprise_api"
    ```
  - Filter for error logs only:
    ```logql
    {job="docker"} |= "error" or "ERROR"
    ```
