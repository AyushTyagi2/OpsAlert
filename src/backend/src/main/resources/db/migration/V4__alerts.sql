
-- =============================================================================
-- SaaS Ops Alerting & Incident Management Platform
-- Production PostgreSQL Schema — V1__initial_schema.sql (Flyway)
-- =============================================================================
-- Architecture: Kotlin + Spring Boot + PostgreSQL 15+ + Kafka + Flyway
-- Design principles:
--   • UUID PKs everywhere (gen_random_uuid())
--   • Row-level org isolation via org_id on every tenant-scoped table
--   • Soft deletes via deleted_at (NOT hard DELETEs on operational tables)
--   • Immutable audit_logs — append-only, no UPDATE/DELETE
--   • Partitioned tables on high-volume append-only data (alerts, audit_logs,
--     notification_logs) by created_at (monthly RANGE partitions)
--   • Enums for stable categorical state; status columns use VARCHAR + CHECK
--     when states may be extended at runtime
-- =============================================================================



-- ---------------------------------------------------------------------------
-- alerts  (high-volume: partitioned by created_at monthly)
-- ---------------------------------------------------------------------------
-- We use declarative partitioning. Flyway will create monthly child partitions
-- via a scheduled job or additional migration scripts.
-- =============================================================================
-- DOMAIN 2: ALERTING SYSTEM
-- =============================================================================


CREATE TABLE alerts (
    id                  UUID         NOT NULL DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    alert_source_id     UUID         NOT NULL REFERENCES alert_sources(id),
    alert_group_id      UUID         REFERENCES alert_groups(id),
    dedup_key           VARCHAR(512) NOT NULL,    -- deterministic dedup fingerprint
    fingerprint         VARCHAR(128) NOT NULL,    -- SHA-256 of normalised labels
    title               VARCHAR(512) NOT NULL,
    description         TEXT,
    severity            severity_level NOT NULL DEFAULT 'SEV3',
    state               alert_state  NOT NULL DEFAULT 'FIRING',
    labels              JSONB        NOT NULL DEFAULT '{}',
    annotations         JSONB        NOT NULL DEFAULT '{}',
    generator_url       TEXT,
    starts_at           TIMESTAMPTZ  NOT NULL,
    ends_at             TIMESTAMPTZ,
    resolved_at         TIMESTAMPTZ,
    suppressed_until    TIMESTAMPTZ,
    payload             JSONB        NOT NULL DEFAULT '{}',   -- raw inbound payload
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, created_at)    -- partition key must be in PK
) PARTITION BY RANGE (created_at);

-- Dedup constraint at the source level:
-- A UNIQUE index on (org_id, dedup_key) WITHIN each partition enforces
-- per-partition uniqueness. Cross-partition dedup is handled in application
-- logic via a Redis/DB lookup before INSERT.

-- Create initial partitions (add more via migrations each month)
CREATE TABLE alerts_2025_01 PARTITION OF alerts
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE alerts_2025_02 PARTITION OF alerts
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
-- ... continue monthly; automate with pg_partman in production


-- =============================================================================
-- SECTION 17: ALERTS  (into partitioned table; all in 2025-05 or 2025-06)
-- =============================================================================
-- Note: Partitions 2025_05 and 2025_06 must exist. Adjust months as needed.

CREATE TABLE IF NOT EXISTS alerts_2025_05 PARTITION OF alerts
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE IF NOT EXISTS alerts_2025_06 PARTITION OF alerts
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');
CREATE TABLE IF NOT EXISTS alerts_2025_04 PARTITION OF alerts
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

INSERT INTO alerts (id, org_id, alert_source_id, alert_group_id, dedup_key, fingerprint, title, description, severity, state, labels, annotations, generator_url, starts_at, ends_at, resolved_at, payload, created_at, updated_at) VALUES

  -- ── INC-0001 correlated alerts: Pod CrashLoop (Synthrex, resolved) ────────────
  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'KubernetesPodCrashLooping/payments/payment-processor-6d8f9b7c4-xqr7p',
   'fp:a1b2c3d4e5f6a7b8',
   'KubernetesPodCrashLooping — payments/payment-processor-6d8f9b7c4-xqr7p',
   'Pod payment-processor-6d8f9b7c4-xqr7p in namespace payments has restarted 8 times in the last 10 minutes. OOMKilled.',
   'SEV1', 'RESOLVED',
   '{"alertname": "KubernetesPodCrashLooping", "namespace": "payments", "pod": "payment-processor-6d8f9b7c4-xqr7p", "container": "payment-processor", "reason": "OOMKilled", "env": "production", "cluster": "synthrex-prod-us-east-1", "team": "payments"}'::jsonb,
   '{"summary": "Payment processor pod is OOMKilling", "runbook": "https://runbooks.synthrex.io/kubernetes/oomkilled", "dashboard": "https://grafana.synthrex.io/d/k8s-pods?var-pod=payment-processor-6d8f9b7c4-xqr7p"}'::jsonb,
   'https://prometheus.prod.synthrex.internal/graph?g0.expr=kube_pod_container_status_restarts_total',
   '2025-05-14 02:17:00+00', '2025-05-14 04:02:00+00', '2025-05-14 04:02:00+00',
   '{"source": "prometheus", "version": "4", "commonLabels": {"namespace": "payments"}, "externalURL": "https://alertmanager.prod.synthrex.internal"}'::jsonb,
   '2025-05-14 02:17:00+00', '2025-05-14 04:02:00+00'),

  -- Duplicate/correlated alert fired 4 mins later (same group, DEDUPLICATED)
  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'KubernetesPodCrashLooping/payments/payment-processor-6d8f9b7c4-jks2m',
   'fp:a1b2c3d4e5f6a7b9',
   'KubernetesPodCrashLooping — payments/payment-processor-6d8f9b7c4-jks2m',
   'Pod payment-processor-6d8f9b7c4-jks2m in namespace payments has restarted 6 times. OOMKilled. Correlated with al000001.',
   'SEV1', 'DEDUPLICATED',
   '{"alertname": "KubernetesPodCrashLooping", "namespace": "payments", "pod": "payment-processor-6d8f9b7c4-jks2m", "container": "payment-processor", "reason": "OOMKilled", "env": "production", "cluster": "synthrex-prod-us-east-1", "team": "payments"}'::jsonb,
   '{"summary": "Second payment processor pod OOMKilling", "runbook": "https://runbooks.synthrex.io/kubernetes/oomkilled"}'::jsonb,
   'https://prometheus.prod.synthrex.internal/graph?g0.expr=kube_pod_container_status_restarts_total',
   '2025-05-14 02:21:00+00', '2025-05-14 04:02:00+00', '2025-05-14 04:02:00+00',
   '{"source": "prometheus", "version": "4"}'::jsonb,
   '2025-05-14 02:21:00+00', '2025-05-14 04:02:00+00'),

  -- ── INC-0002 alert: Kafka consumer lag (Synthrex, resolved) ──────────────────
  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003',
   '00000002-0001-0001-0001-000000000002',
   'KafkaConsumerGroupLag/payment-events/payment-processor-v2',
   'fp:b2c3d4e5f6a7b8c9',
   'KafkaConsumerGroupLag Critical — payment-events / payment-processor-v2',
   'Consumer group payment-processor-v2 lag on topic payment-events has exceeded 500,000 messages. Current lag: 1,247,832. Throughput dropped from 12k msg/s to 180 msg/s.',
   'SEV2', 'RESOLVED',
   '{"alertname": "KafkaConsumerGroupLag", "kafka_topic": "payment-events", "consumer_group": "payment-processor-v2", "broker": "kafka-broker-2.prod.synthrex.internal:9092", "env": "production", "team": "data-infrastructure"}'::jsonb,
   '{"summary": "Kafka consumer lag > 500k messages", "runbook": "https://runbooks.synthrex.io/kafka/consumer-lag", "dashboard": "https://grafana.synthrex.io/d/kafka-lag?var-group=payment-processor-v2"}'::jsonb,
   'https://grafana.prod.synthrex.internal/d/kafka-lag',
   '2025-05-20 18:03:00+00', '2025-05-20 21:45:00+00', '2025-05-20 21:45:00+00',
   '{"source": "grafana", "datasource": "Thanos", "orgId": 1, "panelId": 42}'::jsonb,
   '2025-05-20 18:03:00+00', '2025-05-20 21:45:00+00'),

  -- ── INC-0003 alert: API Latency spike (Synthrex, resolved) ───────────────────
  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002',
   '00000003-0001-0001-0001-000000000003',
   'HighAPILatencyP99/payment-api//v2/transactions',
   'fp:c3d4e5f6a7b8c9d0',
   'HighAPILatencyP99 — payment-api /v2/transactions (p99=8.2s)',
   'P99 latency on POST /v2/transactions has spiked to 8.2s. SLO breach imminent. Baseline p99 is 320ms. Correlated with DB connection pool exhaustion.',
   'SEV2', 'RESOLVED',
   '{"alertname": "HighAPILatencyP99", "service": "payment-api", "endpoint": "/v2/transactions", "method": "POST", "env": "production", "team": "payments", "monitor_id": "m-8843221"}'::jsonb,
   '{"summary": "p99 API latency 8.2s on /v2/transactions", "runbook": "https://runbooks.synthrex.io/api/high-latency", "dashboard": "https://grafana.synthrex.io/d/api-latency?var-service=payment-api"}'::jsonb,
   'https://app.datadoghq.com/monitors/8843221',
   '2025-06-01 09:30:00+00', '2025-06-01 12:40:00+00', '2025-06-01 12:40:00+00',
   '{"source": "datadog", "monitor_id": "8843221", "monitor_type": "metric alert", "transition": "Triggered"}'::jsonb,
   '2025-06-01 09:30:00+00', '2025-06-01 12:40:00+00'),

  -- ── INC-0004 alert: PostgreSQL connection pool (Synthrex, active/firing) ──────
  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004',
   'PostgreSQLConnectionPoolExhausted/database/pg-primary-us-east-1',
   'fp:d4e5f6a7b8c9d0e1',
   'PostgreSQLConnectionPoolExhausted — pg-primary-us-east-1',
   'pgbouncer connection pool on pg-primary-us-east-1 is 98% utilized. Max connections: 500. Active: 491. Waiting queue: 87. New connections are being rejected.',
   'SEV1', 'FIRING',
   '{"alertname": "PostgreSQLConnectionPoolExhausted", "namespace": "database", "instance": "pg-primary-us-east-1", "pool_mode": "transaction", "max_client_conn": "500", "env": "production", "team": "platform-sre"}'::jsonb,
   '{"summary": "pgbouncer pool 98% utilized on primary", "runbook": "https://runbooks.synthrex.io/postgresql/connection-pool", "dashboard": "https://grafana.synthrex.io/d/pgbouncer?var-instance=pg-primary-us-east-1"}'::jsonb,
   'https://prometheus.prod.synthrex.internal/graph?g0.expr=pgbouncer_pools_cl_active',
   '2025-06-03 22:05:00+00', NULL, NULL,
   '{"source": "prometheus", "version": "4", "receiver": "synthrex-ops-critical"}'::jsonb,
   '2025-06-03 22:05:00+00', '2025-06-03 22:05:00+00'),

  -- Additional correlated alert (same DB incident, high connection rate)
  ('00000006-0001-0001-0001-000000000006',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004',
   'PostgreSQLHighConnectionRate/database/pg-primary-us-east-1',
   'fp:d4e5f6a7b8c9d0e2',
   'PostgreSQLHighConnectionRate — pg-primary-us-east-1 (rate=47 conn/s)',
   'New connection rate to pg-primary has spiked to 47 connections/second. Possible connection leak in payment-api service.',
   'SEV2', 'FIRING',
   '{"alertname": "PostgreSQLHighConnectionRate", "namespace": "database", "instance": "pg-primary-us-east-1", "env": "production", "team": "platform-sre"}'::jsonb,
   '{"summary": "High DB connection rate, possible leak", "runbook": "https://runbooks.synthrex.io/postgresql/connection-leak"}'::jsonb,
   'https://prometheus.prod.synthrex.internal/graph?g0.expr=rate(pg_stat_database_numbackends[5m])',
   '2025-06-03 22:08:00+00', NULL, NULL,
   '{"source": "prometheus"}'::jsonb,
   '2025-06-03 22:08:00+00', '2025-06-03 22:08:00+00'),

  -- ── INC-0005 alert: SSL Certificate expiry (Synthrex, resolved) ──────────────
  ('00000007-0001-0001-0001-000000000007',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000005-0001-0001-0001-000000000005',
   '00000005-0001-0001-0001-000000000005',
   'SSLCertificateExpiringSoon/api.synthrex.io',
   'fp:e5f6a7b8c9d0e1f2',
   'SSL Certificate Expiring in 14 Days — api.synthrex.io',
   'TLS certificate for api.synthrex.io issued by DigiCert will expire on 2025-04-29. Auto-renewal via cert-manager has failed due to DNS-01 challenge errors.',
   'SEV3', 'RESOLVED',
   '{"alertname": "SSLCertificateExpiringSoon", "domain": "api.synthrex.io", "issuer": "DigiCert Global Root CA", "expiry_date": "2025-04-29", "days_remaining": "14", "env": "production", "team": "secops"}'::jsonb,
   '{"summary": "SSL cert expiring in 14 days, auto-renewal failed", "runbook": "https://runbooks.synthrex.io/certificates/renewal"}'::jsonb,
   'https://uptimerobot.com/monitors/m798765434',
   '2025-04-15 06:00:00+00', '2025-04-16 14:30:00+00', '2025-04-16 14:30:00+00',
   '{"source": "uptimerobot", "monitor_id": "m798765434", "monitor_type": "SSL"}'::jsonb,
   '2025-04-15 06:00:00+00', '2025-04-16 14:30:00+00'),

  -- ── INC-0006 alert: Redis memory (Cloudnova, resolved) ───────────────────────
  ('00000008-0002-0002-0002-000000000008',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000006-0002-0002-0002-000000000006',
   '00000006-0002-0002-0002-000000000006',
   'RedisMemoryHighWatermark/redis-cache-001',
   'fp:f6a7b8c9d0e1f2a3',
   'RedisMemoryHighWatermark — redis-cache-001 (94% used)',
   'Redis instance redis-cache-001 memory usage has reached 94% of maxmemory (15.04 GB / 16 GB). Eviction policy: allkeys-lru. Eviction rate: 8,240 keys/min.',
   'SEV2', 'RESOLVED',
   '{"alertname": "RedisMemoryHighWatermark", "instance": "redis-cache-001", "used_memory_pct": "94", "maxmemory_gb": "16", "eviction_policy": "allkeys-lru", "env": "production", "team": "infrastructure"}'::jsonb,
   '{"summary": "Redis at 94% memory, high eviction rate", "runbook": "https://runbooks.cloudnova.dev/redis/memory-pressure", "dashboard": "https://grafana.cloudnova.internal/d/redis-memory"}'::jsonb,
   'https://prometheus.cloudnova.internal/graph?g0.expr=redis_memory_used_bytes',
   '2025-05-28 14:22:00+00', '2025-05-28 17:05:00+00', '2025-05-28 17:05:00+00',
   '{"source": "prometheus"}'::jsonb,
   '2025-05-28 14:22:00+00', '2025-05-28 17:05:00+00'),

  -- ── INC-0007 alert: EC2 CPU Saturation (Cloudnova, resolved) ─────────────────
  ('00000009-0002-0002-0002-000000000009',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000007-0002-0002-0002-000000000007',
   '00000007-0002-0002-0002-000000000007',
   'EC2CPUSaturation/i-0abc123def456789/cloudnova-api-asg-prod',
   'fp:a7b8c9d0e1f2a3b4',
   'EC2CPUSaturation — i-0abc123def456789 (CPU 98.7%)',
   'EC2 instance i-0abc123def456789 in ASG cloudnova-api-asg-prod has sustained CPU utilization above 95% for 15 minutes. Instance may be unresponsive to auto-scaling events.',
   'SEV2', 'RESOLVED',
   '{"alertname": "EC2CPUSaturation", "instance_id": "i-0abc123def456789", "asg": "cloudnova-api-asg-prod", "region": "us-west-2", "cpu_pct": "98.7", "env": "production"}'::jsonb,
   '{"summary": "EC2 CPU at 98.7% for 15min", "runbook": "https://runbooks.cloudnova.dev/ec2/cpu-saturation"}'::jsonb,
   'https://console.aws.amazon.com/cloudwatch/home?region=us-west-2',
   '2025-06-02 07:15:00+00', '2025-06-02 09:50:00+00', '2025-06-02 09:50:00+00',
   '{"source": "cloudwatch", "alarm_name": "cloudnova-api-cpu-high", "region": "us-west-2"}'::jsonb,
   '2025-06-02 07:15:00+00', '2025-06-02 09:50:00+00'),

  -- ── INC-0008 alert: Nimbly API down (Nimbly) ─────────────────────────────────
  ('00000010-0003-0003-0003-000000000010',
   'c3d4e5f6-0003-0003-0003-000000000003',
   '00000008-0003-0003-0003-000000000008',
   '00000008-0003-0003-0003-000000000008',
   'APIEndpointDown/m312345678/https://api.nimbly.io/health',
   'fp:b8c9d0e1f2a3b4c5',
   'API Endpoint Down — https://api.nimbly.io/health (HTTP 502)',
   'Health endpoint https://api.nimbly.io/health is returning HTTP 502. Uptime Robot has confirmed failure from 3 probe locations. Likely upstream ECS task failure.',
   'SEV1', 'RESOLVED',
   '{"alertname": "APIEndpointDown", "monitor_id": "m312345678", "monitor_url": "https://api.nimbly.io/health", "http_code": "502", "env": "production"}'::jsonb,
   '{"summary": "API returning 502 from all probe locations", "runbook": "https://wiki.nimbly.io/runbooks/api-down"}'::jsonb,
   'https://uptimerobot.com/monitors/m312345678',
   '2025-05-30 03:45:00+00', '2025-05-30 04:38:00+00', '2025-05-30 04:38:00+00',
   '{"source": "uptimerobot", "monitor_id": "m312345678", "monitor_type": "HTTP"}'::jsonb,
   '2025-05-30 03:45:00+00', '2025-05-30 04:38:00+00'),

  -- ── INC-0009: Deployment Rollback (Synthrex, active/investigating) ────────────
  ('00000011-0001-0001-0001-000000000011',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   NULL,
   'KubernetesDeploymentRolloutFailed/payments/payment-gateway-svc',
   'fp:c9d0e1f2a3b4c5d6',
   'KubernetesDeploymentRolloutFailed — payments/payment-gateway-svc v3.14.2',
   'Deployment rollout for payment-gateway-svc v3.14.2 has stalled. 0/3 new pods are passing readiness probes. Rollout blocked for 8 minutes. Triggering automatic rollback to v3.14.1.',
   'SEV2', 'FIRING',
   '{"alertname": "KubernetesDeploymentRolloutFailed", "namespace": "payments", "deployment": "payment-gateway-svc", "new_version": "v3.14.2", "previous_version": "v3.14.1", "env": "production", "team": "payments"}'::jsonb,
   '{"summary": "payment-gateway-svc v3.14.2 rollout failed", "runbook": "https://runbooks.synthrex.io/kubernetes/deployment-rollback", "changelog": "https://github.com/synthrex/payment-gateway/releases/tag/v3.14.2"}'::jsonb,
   'https://prometheus.prod.synthrex.internal/graph',
   '2025-06-04 08:45:00+00', NULL, NULL,
   '{"source": "prometheus"}'::jsonb,
   '2025-06-04 08:45:00+00', '2025-06-04 08:45:00+00'),

  -- ── INC-0010: Payment Gateway Failure (Synthrex, escalated/active) ────────────
  ('00000012-0001-0001-0001-000000000012',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004',
   NULL,
   'PaymentGatewayErrorRateHigh/stripe-integration/charge',
   'fp:d0e1f2a3b4c5d6e7',
   'PaymentGatewayErrorRateHigh — stripe-integration /v1/charge (error_rate=31%)',
   'Stripe API error rate on /v1/charge has reached 31% over the last 5 minutes. 4,821 failed transactions. HTTP 402 and 429 responses. Stripe status page shows degraded performance.',
   'SEV1', 'FIRING',
   '{"alertname": "PaymentGatewayErrorRateHigh", "gateway": "stripe", "endpoint": "/v1/charge", "error_rate_pct": "31", "failed_transactions": "4821", "env": "production", "team": "payments"}'::jsonb,
   '{"summary": "31% Stripe error rate, 4.8k failed transactions", "runbook": "https://runbooks.synthrex.io/payments/stripe-degraded", "status_page": "https://status.stripe.com"}'::jsonb,
   'https://console.aws.amazon.com/cloudwatch/home',
   '2025-06-04 10:22:00+00', NULL, NULL,
   '{"source": "cloudwatch", "alarm_name": "stripe-error-rate-high"}'::jsonb,
   '2025-06-04 10:22:00+00', '2025-06-04 10:22:00+00');

