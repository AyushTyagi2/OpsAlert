
-- ---------------------------------------------------------------------------
-- alert_sources  (registered integrations: Prometheus, Datadog, CloudWatch…)
-- ---------------------------------------------------------------------------
CREATE TABLE alert_sources (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    name                VARCHAR(255) NOT NULL,
    source_type         VARCHAR(100) NOT NULL,    -- prometheus, datadog, cloudwatch, etc.
    integration_key     VARCHAR(128) NOT NULL UNIQUE,  -- inbound webhook key
    config              JSONB        NOT NULL DEFAULT '{}',
    dedup_key_template  TEXT,                     -- Go template for dedup key generation
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE (org_id, name)
);


-- =============================================================================
-- SECTION 15: ALERT SOURCES
-- =============================================================================

INSERT INTO alert_sources (id, org_id, name, source_type, integration_key, config, dedup_key_template, is_active, created_at, updated_at) VALUES

  -- Synthrex sources
  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Prometheus — Production Cluster',
   'prometheus',
   'sxp-prom-prod-k8s-a1b2c3d4',
   '{
     "url": "https://prometheus.prod.synthrex.internal",
     "alertmanager_url": "https://alertmanager.prod.synthrex.internal",
     "cluster": "synthrex-prod-us-east-1",
     "send_resolved": true,
     "group_wait": "30s",
     "group_interval": "5m",
     "repeat_interval": "4h"
   }'::jsonb,
   '{{.Labels.alertname}}/{{.Labels.namespace}}/{{.Labels.pod}}',
   TRUE,
   '2023-04-20 10:00:00+00', '2025-05-01 08:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Datadog — Production APM',
   'datadog',
   'sxp-dd-prod-apm-b2c3d4e5',
   '{
     "api_key_ref": "vault:secret/datadog/api-key",
     "site": "datadoghq.com",
     "monitor_tags": ["env:production", "team:platform"],
     "include_tags": true
   }'::jsonb,
   '{{.MonitorID}}/{{.Scope}}',
   TRUE,
   '2023-07-01 10:00:00+00', '2025-04-01 10:00:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Grafana Alertmanager — Kafka Cluster',
   'grafana',
   'sxp-grafana-kafka-c3d4e5f6',
   '{
     "grafana_url": "https://grafana.prod.synthrex.internal",
     "org_id": 1,
     "folder": "Kafka",
     "datasource": "Thanos"
   }'::jsonb,
   '{{.Labels.alertname}}/{{.Labels.kafka_topic}}/{{.Labels.consumer_group}}',
   TRUE,
   '2023-07-15 09:00:00+00', '2025-03-01 09:00:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'AWS CloudWatch — Payment Services',
   'cloudwatch',
   'sxp-cw-payments-d4e5f6a7',
   '{
     "region": "us-east-1",
     "account_id": "123456789012",
     "sns_topic_arn": "arn:aws:sns:us-east-1:123456789012:synthrex-alerts",
     "namespace_filter": ["AWS/ApplicationELB", "Custom/PaymentGateway"]
   }'::jsonb,
   '{{.AlarmName}}/{{.Region}}',
   TRUE,
   '2023-08-01 08:00:00+00', '2025-02-01 10:00:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Uptime Robot — External Endpoints',
   'uptimerobot',
   'sxp-utr-external-e5f6a7b8',
   '{
     "monitor_ids": ["m798765432", "m798765433", "m798765434"],
     "alert_contacts": ["synthrex-ops-webhook"],
     "response_time_threshold_ms": 2000
   }'::jsonb,
   '{{.MonitorID}}/{{.MonitorURL}}',
   TRUE,
   '2024-01-10 10:00:00+00', '2025-01-10 10:00:00+00'),

  -- Cloudnova sources
  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Prometheus — Cloudnova Production',
   'prometheus',
   'cnv-prom-prod-f6a7b8c9',
   '{
     "url": "https://prometheus.cloudnova.internal",
     "cluster": "cloudnova-prod-us-west-2",
     "send_resolved": true,
     "group_wait": "1m",
     "group_interval": "10m",
     "repeat_interval": "6h"
   }'::jsonb,
   '{{.Labels.alertname}}/{{.Labels.service}}/{{.Labels.env}}',
   TRUE,
   '2024-01-20 10:00:00+00', '2025-03-01 09:00:00+00'),

  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'AWS CloudWatch — Cloudnova',
   'cloudwatch',
   'cnv-cw-prod-a7b8c9d0',
   '{
     "region": "us-west-2",
     "account_id": "987654321098",
     "sns_topic_arn": "arn:aws:sns:us-west-2:987654321098:cloudnova-alerts"
   }'::jsonb,
   '{{.AlarmName}}/{{.Region}}',
   TRUE,
   '2024-03-01 09:00:00+00', '2025-02-01 08:00:00+00'),

  -- Nimbly sources
  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Uptime Robot — Nimbly API',
   'uptimerobot',
   'nmb-utr-api-b8c9d0e1',
   '{
     "monitor_ids": ["m312345678"],
     "alert_contacts": ["nimbly-ops-webhook"],
     "response_time_threshold_ms": 3000
   }'::jsonb,
   '{{.MonitorID}}/{{.MonitorURL}}',
   TRUE,
   '2025-03-02 09:00:00+00', '2025-03-02 09:00:00+00'),

  ('00000009-0003-0003-0003-000000000009',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Prometheus — Nimbly Platform',
   'prometheus',
   'nmb-prom-prod-c9d0e1f2',
   '{
     "url": "https://prometheus.nimbly.internal",
     "cluster": "nimbly-prod-eu-west-1",
     "send_resolved": true
   }'::jsonb,
   '{{.Labels.alertname}}/{{.Labels.job}}',
   TRUE,
   '2025-03-10 11:00:00+00', '2025-03-10 11:00:00+00');
