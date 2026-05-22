export type ServiceStatus = "HEALTHY" | "DEGRADED" | "DOWN";
export type AlertSeverity = "critical" | "warning" | "info" | "resolved";
export type EventType = "restart" | "deploy" | "warning" | "scale" | "recovery";

export interface Service {
  id: string;
  name: string;
  status: ServiceStatus;
  uptime: number;
  latency: number;
  lastChecked: string;
  region: string;
}

export interface Alert {
  id: string;
  timestamp: string;
  message: string;
  severity: AlertSeverity;
  service: string;
}

export interface HealthMetric {
  id: string;
  label: string;
  value: string;
  subvalue: string;
  trend: "up" | "down" | "stable";
  status: "ok" | "warn" | "critical";
  icon: string;
}

export interface LatencyPoint {
  time: string;
  p50: number;
  p95: number;
  p99: number;
}

export interface ErrorRatePoint {
  time: string;
  rate: number;
  count: number;
}

export interface IncidentSeverity {
  name: string;
  value: number;
  color: string;
}

export interface MonitoringEvent {
  id: string;
  timestamp: string;
  type: EventType;
  title: string;
  description: string;
  service: string;
}