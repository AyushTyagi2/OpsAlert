import type { Service, Alert, HealthMetric, LatencyPoint, ErrorRatePoint, IncidentSeverity, MonitoringEvent } from "../../types/monitoring";

export const mockServices: Service[] = [
  { id: "1", name: "payment-service", status: "HEALTHY", uptime: 99.98, latency: 42, lastChecked: "12:04:01", region: "us-east-1" },
  { id: "2", name: "auth-gateway", status: "HEALTHY", uptime: 99.99, latency: 18, lastChecked: "12:04:01", region: "us-east-1" },
  { id: "3", name: "postgres-primary", status: "DEGRADED", uptime: 99.71, latency: 312, lastChecked: "12:03:58", region: "us-east-1" },
  { id: "4", name: "redis-cache", status: "HEALTHY", uptime: 100.0, latency: 3, lastChecked: "12:04:01", region: "us-west-2" },
  { id: "5", name: "notification-svc", status: "DOWN", uptime: 97.12, latency: 0, lastChecked: "12:01:44", region: "eu-west-1" },
  { id: "6", name: "analytics-pipeline", status: "DEGRADED", uptime: 98.43, latency: 891, lastChecked: "12:03:52", region: "us-east-1" },
  { id: "7", name: "cdn-edge", status: "HEALTHY", uptime: 100.0, latency: 7, lastChecked: "12:04:01", region: "global" },
  { id: "8", name: "search-indexer", status: "HEALTHY", uptime: 99.85, latency: 67, lastChecked: "12:04:00", region: "us-west-2" },
];

export const mockAlerts: Alert[] = [
  { id: "a1", timestamp: "12:04:12", message: "payment-service p99 latency exceeded 500ms threshold", severity: "warning", service: "payment-service" },
  { id: "a2", timestamp: "12:04:01", message: "INC-204 triggered: notification-svc health check failed (3x)", severity: "critical", service: "notification-svc" },
  { id: "a3", timestamp: "12:03:58", message: "postgres-primary replication lag at 8.2s — threshold 5s", severity: "warning", service: "postgres-primary" },
  { id: "a4", timestamp: "12:03:22", message: "analytics-pipeline memory usage at 91% — autoscaling queued", severity: "warning", service: "analytics-pipeline" },
  { id: "a5", timestamp: "12:02:55", message: "INC-203 resolved: auth-gateway token cache restored", severity: "resolved", service: "auth-gateway" },
  { id: "a6", timestamp: "12:02:11", message: "redis-cache eviction rate spike: 12k keys/min", severity: "info", service: "redis-cache" },
  { id: "a7", timestamp: "12:01:44", message: "INC-204 escalated to on-call: kartik.m@corp.io", severity: "critical", service: "notification-svc" },
  { id: "a8", timestamp: "12:00:30", message: "cdn-edge origin failover activated — us-east-1 → us-west-2", severity: "info", service: "cdn-edge" },
  { id: "a9", timestamp: "11:59:48", message: "search-indexer job completed: 2.1M docs indexed in 4m12s", severity: "info", service: "search-indexer" },
];

export const mockHealthMetrics: HealthMetric[] = [
  { id: "m1", label: "Services Up", value: "6/8", subvalue: "2 degraded", trend: "down", status: "warn", icon: "Activity" },
  { id: "m2", label: "Active Alerts", value: "4", subvalue: "2 critical", trend: "up", status: "critical", icon: "AlertTriangle" },
  { id: "m3", label: "Avg Response", value: "167ms", subvalue: "+23ms vs 1h", trend: "up", status: "warn", icon: "Timer" },
  { id: "m4", label: "Error Rate", value: "0.42%", subvalue: "↑ from 0.18%", trend: "up", status: "warn", icon: "XCircle" },
  { id: "m5", label: "CPU Usage", value: "61%", subvalue: "8 nodes avg", trend: "stable", status: "ok", icon: "Cpu" },
  { id: "m6", label: "Memory Usage", value: "78%", subvalue: "14.8 / 19 GB", trend: "up", status: "warn", icon: "MemoryStick" },
];

export const mockLatency: LatencyPoint[] = [
  { time: "11:45", p50: 38, p95: 120, p99: 210 },
  { time: "11:50", p50: 41, p95: 134, p99: 245 },
  { time: "11:55", p50: 44, p95: 168, p99: 312 },
  { time: "12:00", p50: 52, p95: 201, p99: 398 },
  { time: "12:05", p50: 49, p95: 188, p99: 371 },
  { time: "12:10", p50: 55, p95: 224, p99: 487 },
  { time: "12:15", p50: 61, p95: 259, p99: 531 },
];

export const mockErrorRate: ErrorRatePoint[] = [
  { time: "11:45", rate: 0.18, count: 12 },
  { time: "11:50", rate: 0.21, count: 18 },
  { time: "11:55", rate: 0.19, count: 15 },
  { time: "12:00", rate: 0.34, count: 31 },
  { time: "12:05", rate: 0.28, count: 24 },
  { time: "12:10", rate: 0.42, count: 38 },
  { time: "12:15", rate: 0.39, count: 35 },
];

export const mockIncidentDist: IncidentSeverity[] = [
  { name: "P1 Critical", value: 2, color: "#ef4444" },
  { name: "P2 High", value: 5, color: "#f97316" },
  { name: "P3 Medium", value: 11, color: "#eab308" },
  { name: "P4 Low", value: 8, color: "#3b82f6" },
];

export const mockEvents: MonitoringEvent[] = [
  { id: "e1", timestamp: "12:03:51", type: "restart", title: "Pod Restarted", description: "notification-svc-7d9f pod OOMKilled — restarted (attempt 3)", service: "notification-svc" },
  { id: "e2", timestamp: "12:02:30", type: "deploy", title: "Deployment Complete", description: "auth-gateway v2.14.1 rolled out — 4/4 replicas healthy", service: "auth-gateway" },
  { id: "e3", timestamp: "12:01:12", type: "warning", title: "Memory Warning", description: "analytics-pipeline heap at 91% — GC pressure increasing", service: "analytics-pipeline" },
  { id: "e4", timestamp: "12:00:05", type: "scale", title: "Autoscaling Triggered", description: "payment-service scaled 3→5 replicas (CPU 78% threshold)", service: "payment-service" },
  { id: "e5", timestamp: "11:58:44", type: "recovery", title: "Service Recovered", description: "auth-gateway token validation restored — INC-203 closed", service: "auth-gateway" },
  { id: "e6", timestamp: "11:57:20", type: "deploy", title: "Config Map Updated", description: "redis-cache maxmemory-policy updated to allkeys-lru", service: "redis-cache" },
];