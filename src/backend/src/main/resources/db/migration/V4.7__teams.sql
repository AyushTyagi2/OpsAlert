-- ---------------------------------------------------------------------------
-- teams
-- ---------------------------------------------------------------------------
CREATE TABLE teams (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    metadata            JSONB        NOT NULL DEFAULT '{}',
    created_by_user_id  UUID         REFERENCES users(id),
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE (org_id, name)
);

-- =============================================================================
-- SECTION 3: TEAMS
-- =============================================================================

INSERT INTO teams (id, org_id, name, description, metadata, created_by_user_id, created_at, updated_at) VALUES

  -- ── Synthrex teams ───────────────────────────────────────────────────────────
  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Platform SRE',
   'Core infrastructure reliability, Kubernetes, networking, and database SRE.',
   '{"slack_channel": "#sre-platform", "pagerduty_escalation_id": "PD-SRE-001", "on_call_rotation": "weekly"}'::jsonb,
   '00000001-0001-0001-0001-000000000001',
   '2023-04-12 10:00:00+00', '2025-06-01 09:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Payments Engineering',
   'Payment gateway integrations, transaction processing, and fraud detection systems.',
   '{"slack_channel": "#payments-oncall", "pagerduty_escalation_id": "PD-PAY-002", "on_call_rotation": "weekly"}'::jsonb,
   '00000001-0001-0001-0001-000000000001',
   '2023-04-12 10:00:00+00', '2025-05-20 14:00:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Data Infrastructure',
   'Kafka, Flink, data pipelines, streaming infrastructure, and analytics platform.',
   '{"slack_channel": "#data-infra-oncall", "pagerduty_escalation_id": "PD-DATA-003", "on_call_rotation": "weekly"}'::jsonb,
   '00000002-0001-0001-0001-000000000002',
   '2023-07-01 10:00:00+00', '2025-04-10 09:30:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Backend API',
   'REST/gRPC API services, authentication, rate limiting, and service mesh.',
   '{"slack_channel": "#backend-api-oncall", "on_call_rotation": "weekly"}'::jsonb,
   '00000003-0001-0001-0001-000000000003',
   '2023-09-15 08:00:00+00', '2025-06-01 08:00:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Security Operations',
   'SecOps, vulnerability management, compliance, and certificate management.',
   '{"slack_channel": "#secops-alerts", "on_call_rotation": "weekly"}'::jsonb,
   '00000001-0001-0001-0001-000000000001',
   '2024-01-10 09:00:00+00', '2025-05-01 10:00:00+00'),

  -- ── Cloudnova teams ──────────────────────────────────────────────────────────
  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Infrastructure',
   'Cloud infrastructure, networking, and on-call response.',
   '{"slack_channel": "#infra-oncall"}'::jsonb,
   '00000011-0002-0002-0002-000000000011',
   '2024-01-15 09:00:00+00', '2025-04-01 12:00:00+00'),

  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Product Engineering',
   'Core application, APIs, and feature development on-call.',
   '{"slack_channel": "#product-eng-oncall"}'::jsonb,
   '00000011-0002-0002-0002-000000000011',
   '2024-01-15 09:00:00+00', '2025-03-15 10:00:00+00'),

  -- ── Nimbly teams ─────────────────────────────────────────────────────────────
  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Engineering',
   'Full-stack engineering and infrastructure.',
   '{"slack_channel": "#eng-oncall"}'::jsonb,
   '00000016-0003-0003-0003-000000000016',
   '2025-03-01 13:00:00+00', '2025-06-01 09:00:00+00');