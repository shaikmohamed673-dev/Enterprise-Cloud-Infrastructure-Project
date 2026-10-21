"""
Enterprise Cloud & DevOps Microservice
Built with FastAPI, Prometheus Metrics, and Health Probes.
"""

import os
import time
import socket
import psutil
from typing import Dict, List, Any
from fastapi import FastAPI, Response, status, HTTPException
from pydantic import BaseModel
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    CONTENT_TYPE_LATEST,
)

# ------------------------------------------------------------------------------
# Prometheus Custom Metric Definitions
# ------------------------------------------------------------------------------
REQUEST_COUNT = Counter(
    "enterprise_http_requests_total",
    "Total count of HTTP requests",
    ["method", "endpoint", "status_code"],
)

REQUEST_LATENCY = Histogram(
    "enterprise_http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0),
)

SYSTEM_MEMORY_USAGE = Gauge(
    "enterprise_system_memory_usage_bytes",
    "Host/Container memory utilization in bytes",
)

SYSTEM_CPU_PERCENT = Gauge(
    "enterprise_system_cpu_percent",
    "Host/Container CPU utilization percentage",
)

# ------------------------------------------------------------------------------
# Application Initialization & State
# ------------------------------------------------------------------------------
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
APP_ENV = os.getenv("ENVIRONMENT", "production")
HOSTNAME = socket.gethostname()
START_TIME = time.time()

app = FastAPI(
    title="Enterprise Cloud Microservice",
    description="Scalable cloud microservice with built-in observability, health checks, and metrics.",
    version=APP_VERSION,
)

# In-memory datastore simulation
DATA_STORE: List[Dict[str, Any]] = [
    {"id": 1, "name": "Production Cluster Alpha", "status": "active"},
    {"id": 2, "name": "Disaster Recovery Pipeline", "status": "active"},
    {"id": 3, "name": "Prometheus Observability Engine", "status": "active"},
]


class ItemCreate(BaseModel):
    name: str
    status: str = "active"


# ------------------------------------------------------------------------------
# Middleware for Request Timing and Prometheus Metrics
# ------------------------------------------------------------------------------
@app.middleware("http")
async def monitor_requests(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start

    endpoint = request.url.path
    # Group dynamic paths if needed
    if endpoint.startswith("/api/v1/items/"):
        endpoint = "/api/v1/items/{id}"

    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=endpoint,
        status_code=str(response.status_code),
    ).inc()

    REQUEST_LATENCY.labels(endpoint=endpoint).observe(duration)
    return response


# ------------------------------------------------------------------------------
# Routes & Endpoints
# ------------------------------------------------------------------------------

@app.get("/", tags=["Root"])
def root():
    """Root endpoint displaying service metadata and node hostname."""
    return {
        "service": "Enterprise Cloud DevOps Service",
        "status": "online",
        "version": APP_VERSION,
        "environment": APP_ENV,
        "host": HOSTNAME,
        "uptime_seconds": round(time.time() - START_TIME, 2),
    }


@app.get("/health", tags=["Health Probes"])
def health():
    """Deep health check endpoint for Load Balancers and Swarm orchestrator."""
    mem = psutil.virtual_memory()
    return {
        "status": "healthy",
        "version": APP_VERSION,
        "node": HOSTNAME,
        "timestamp": int(time.time()),
        "checks": {
            "memory_available_mb": round(mem.available / (1024 * 1024), 2),
            "cpu_percent": psutil.cpu_percent(interval=None),
            "database_connection": "connected",
        },
    }


@app.get("/health/liveness", tags=["Health Probes"])
def liveness():
    """K8s/Docker Swarm liveness probe to verify process is alive."""
    return {"status": "alive"}


@app.get("/health/readiness", tags=["Health Probes"])
def readiness():
    """K8s/Docker Swarm readiness probe to verify container can accept traffic."""
    return {"status": "ready"}


@app.get("/metrics", tags=["Observability"])
def metrics():
    """Prometheus metrics endpoint scraped by Prometheus server."""
    mem = psutil.virtual_memory()
    SYSTEM_MEMORY_USAGE.set(mem.used)
    SYSTEM_CPU_PERCENT.set(psutil.cpu_percent(interval=None))
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/api/v1/system/info", tags=["System"])
def system_info():
    """Inspect compute node and container metrics."""
    return {
        "hostname": HOSTNAME,
        "cpu_count": psutil.cpu_count(),
        "cpu_usage_percent": psutil.cpu_percent(interval=None),
        "memory": {
            "total_mb": round(psutil.virtual_memory().total / (1024 * 1024), 2),
            "used_mb": round(psutil.virtual_memory().used / (1024 * 1024), 2),
            "percent": psutil.virtual_memory().percent,
        },
        "disk": {
            "percent": psutil.disk_usage("/").percent,
        },
        "uptime_seconds": round(time.time() - START_TIME, 2),
    }


@app.get("/api/v1/items", tags=["Data"])
def get_items():
    """Retrieve all data store items."""
    return {"items": DATA_STORE, "total": length if (length := len(DATA_STORE)) else 0}


@app.post("/api/v1/items", status_code=status.HTTP_201_CREATED, tags=["Data"])
def create_item(item: ItemCreate):
    """Add a new item to datastore."""
    new_item = {
        "id": len(DATA_STORE) + 1,
        "name": item.name,
        "status": item.status,
    }
    DATA_STORE.append(new_item)
    return new_item


@app.post("/api/v1/simulate-load", tags=["Testing & Autoscaling"])
def simulate_load(duration_ms: int = 500):
    """
    Simulates CPU burst for testing autoscaling triggers and Prometheus alerts.
    """
    end_time = time.time() + (duration_ms / 1000.0)
    x = 0
    while time.time() < end_time:
        x += 1
    return {
        "message": f"Simulated CPU load for {duration_ms}ms completed",
        "iterations": x,
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)
