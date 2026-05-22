-- ---------------------------------------------------------------------------
-- alert_routing_rules
-- ---------------------------------------------------------------------------
CREATE TABLE alert_routing_rules (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    alert_source_id     UUID         REFERENCES alert_sources(id),  -- NULL = all sources
    name                VARCHAR(255) NOT NULL,
    priority            INTEGER      NOT NULL DEFAULT 100,   -- lower = higher priority
    conditions          JSONB        NOT NULL DEFAULT '{}',  -- CEL expression or label matchers
    escalation_policy_id UUID        REFERENCES escalation_policies(id),
    team_id             UUID         REFERENCES teams(id),
    silence_until       TIMESTAMPTZ,
    is_active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Defer FK to escalation_policies (defined below) — handled by ALTER TABLE
-- Auto-incrementing sequence number per org (not global)
CREATE SEQUENCE incidents_seq_per_org;
-- In application: use nextval scoped per org via a function or at write time

-- =============================================================================
-- SECTION 29: ALERT ROUTING RULES
-- =============================================================================

INSERT INTO alert_routing_rules (id, org_id, alert_source_id, name, priority, conditions, escalation_policy_id, team_id, is_active, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL,
   'Critical Payments Alerts — Payments Team',
   1,
   '{"match_any": [{"labels.team": "payments"}, {"labels.alertname": {"regex": "Payment.*"}}], "severity": ["critical", "SEV1"]}'::jsonb,
   '00000002-0001-0001-0001-000000000002',
   '00000002-0001-0001-0001-000000000002',
   TRUE, '2023-06-01 10:00:00+00', '2025-01-15 10:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003',
   'Kafka & Streaming — Data Infrastructure Team',
   2,
   '{"match_all": [{"labels.kafka_topic": {"exists": true}}, {"severity": ["warning", "critical"]}]}'::jsonb,
   '00000003-0001-0001-0001-000000000003',
   '00000003-0001-0001-0001-000000000003',
   TRUE, '2023-07-01 10:00:00+00', '2024-06-01 09:00:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000005-0001-0001-0001-000000000005',
   'SSL & Security Alerts — SecOps',
   3,
   '{"match_any": [{"labels.alertname": {"regex": "SSL.*"}}, {"labels.team": "secops"}]}'::jsonb,
   '00000004-0001-0001-0001-000000000004',
   '00000005-0001-0001-0001-000000000005',
   TRUE, '2024-01-10 09:00:00+00', '2024-06-01 10:00:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL,
   'Platform Kubernetes & Database — Platform SRE',
   5,
   '{"match_any": [{"labels.namespace": {"in": ["database", "infrastructure", "kube-system"]}}, {"labels.team": "platform-sre"}]}'::jsonb,
   '00000001-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   TRUE, '2023-04-20 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL,
   'Catch-All — Backend API Team (Low Urgency)',
   100,
   '{"match_all": []}'::jsonb,
   '00000005-0001-0001-0001-000000000005',
   '00000004-0001-0001-0001-000000000004',
   TRUE, '2023-09-15 08:00:00+00', '2024-08-01 09:00:00+00'),

  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   NULL,
   'All Alerts — Infrastructure Team',
   1,
   '{"match_all": []}'::jsonb,
   '00000006-0002-0002-0002-000000000006',
   '00000006-0002-0002-0002-000000000006',
   TRUE, '2024-01-20 10:00:00+00', '2025-01-01 09:00:00+00'),

  ('00000007-0003-0003-0003-000000000007',
   'c3d4e5f6-0003-0003-0003-000000000003',
   NULL,
   'All Alerts — Engineering Team',
   1,
   '{"match_all": []}'::jsonb,
   '00000008-0003-0003-0003-000000000008',
   '00000008-0003-0003-0003-000000000008',
   TRUE, '2025-03-02 09:00:00+00', '2025-03-02 09:00:00+00');

