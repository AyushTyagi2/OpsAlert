-- ---------------------------------------------------------------------------
-- alert_groups  (logical grouping bucket for correlated alerts)
-- ---------------------------------------------------------------------------
CREATE TABLE alert_groups (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    alert_source_id     UUID         REFERENCES alert_sources(id),
    group_key           VARCHAR(512) NOT NULL,    -- hash of grouping labels
    labels              JSONB        NOT NULL DEFAULT '{}',
    first_alert_at      TIMESTAMPTZ  NOT NULL,
    last_alert_at       TIMESTAMPTZ  NOT NULL,
    alert_count         INTEGER      NOT NULL DEFAULT 1,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (org_id, group_key)
);


-- =============================================================================
-- SECTION 16: ALERT GROUPS
-- =============================================================================

INSERT INTO alert_groups (id, org_id, alert_source_id, group_key, labels, first_alert_at, last_alert_at, alert_count, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'sha256:a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0',
   '{"alertname": "KubernetesPodCrashLooping", "namespace": "payments", "env": "production", "cluster": "synthrex-prod-us-east-1", "severity": "critical"}'::jsonb,
   '2025-05-14 02:17:00+00', '2025-05-14 02:44:00+00', 5,
   '2025-05-14 02:17:00+00', '2025-05-14 02:44:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003',
   'sha256:b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1',
   '{"alertname": "KafkaConsumerGroupLag", "kafka_topic": "payment-events", "consumer_group": "payment-processor-v2", "env": "production"}'::jsonb,
   '2025-05-20 18:03:00+00', '2025-05-20 18:45:00+00', 12,
   '2025-05-20 18:03:00+00', '2025-05-20 18:45:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002',
   'sha256:c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2',
   '{"alertname": "HighAPILatencyP99", "service": "payment-api", "endpoint": "/v2/transactions", "env": "production"}'::jsonb,
   '2025-06-01 09:30:00+00', '2025-06-01 09:55:00+00', 8,
   '2025-06-01 09:30:00+00', '2025-06-01 09:55:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'sha256:d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3',
   '{"alertname": "PostgreSQLConnectionPoolExhausted", "namespace": "database", "instance": "pg-primary-us-east-1", "env": "production"}'::jsonb,
   '2025-06-03 22:05:00+00', '2025-06-03 22:30:00+00', 7,
   '2025-06-03 22:05:00+00', '2025-06-03 22:30:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000005-0001-0001-0001-000000000005',
   'sha256:e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4',
   '{"alertname": "SSLCertificateExpiringSoon", "domain": "api.synthrex.io", "env": "production"}'::jsonb,
   '2025-04-15 06:00:00+00', '2025-04-15 06:00:00+00', 1,
   '2025-04-15 06:00:00+00', '2025-04-15 06:00:00+00'),

  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000006-0002-0002-0002-000000000006',
   'sha256:f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5',
   '{"alertname": "RedisMemoryHighWatermark", "instance": "redis-cache-001", "env": "production"}'::jsonb,
   '2025-05-28 14:22:00+00', '2025-05-28 15:10:00+00', 9,
   '2025-05-28 14:22:00+00', '2025-05-28 15:10:00+00'),

  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000007-0002-0002-0002-000000000007',
   'sha256:a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6',
   '{"alertname": "EC2CPUSaturation", "instance_id": "i-0abc123def456789", "asg": "cloudnova-api-asg-prod"}'::jsonb,
   '2025-06-02 07:15:00+00', '2025-06-02 09:30:00+00', 14,
   '2025-06-02 07:15:00+00', '2025-06-02 09:30:00+00'),

  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   '00000008-0003-0003-0003-000000000008',
   'sha256:b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7',
   '{"alertname": "APIEndpointDown", "monitor_url": "https://api.nimbly.io/health", "env": "production"}'::jsonb,
   '2025-05-30 03:45:00+00', '2025-05-30 04:12:00+00', 3,
   '2025-05-30 03:45:00+00', '2025-05-30 04:12:00+00');


