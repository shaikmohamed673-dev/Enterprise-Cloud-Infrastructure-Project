"""
Unit Tests for Enterprise Cloud Microservice.
"""

from fastapi.testclient import TestClient
import sys
import os

# Add src to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))

from app import app

client = TestClient(app)


def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "Enterprise Cloud DevOps Service"
    assert data["status"] == "online"
    assert "version" in data
    assert "uptime_seconds" in data


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "checks" in data
    assert data["checks"]["database_connection"] == "connected"


def test_liveness_readiness():
    resp_live = client.get("/health/liveness")
    assert resp_live.status_code == 200
    assert resp_live.json() == {"status": "alive"}

    resp_ready = client.get("/health/readiness")
    assert resp_ready.status_code == 200
    assert resp_ready.json() == {"status": "ready"}


def test_prometheus_metrics():
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert "enterprise_http_requests_total" in response.text


def test_system_info():
    response = client.get("/api/v1/system/info")
    assert response.status_code == 200
    data = response.json()
    assert "hostname" in data
    assert "memory" in data
    assert "cpu_count" in data


def test_items_crud():
    # GET items
    get_res = client.get("/api/v1/items")
    assert get_res.status_code == 200
    initial_count = len(get_res.json()["items"])

    # POST new item
    post_res = client.post(
        "/api/v1/items",
        json={"name": "Kubernetes Backup Controller", "status": "active"},
    )
    assert post_res.status_code == 201
    created_item = post_res.json()
    assert created_item["name"] == "Kubernetes Backup Controller"

    # Verify count incremented
    get_res_after = client.get("/api/v1/items")
    assert len(get_res_after.json()["items"]) == initial_count + 1
