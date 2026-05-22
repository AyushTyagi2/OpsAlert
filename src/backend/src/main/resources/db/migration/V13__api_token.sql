-- ---------------------------------------------------------------------------
-- api_tokens
-- ---------------------------------------------------------------------------
CREATE TABLE api_tokens (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    user_id             UUID         REFERENCES users(id),     -- NULL = org-level token
    name                VARCHAR(255) NOT NULL,
    token_hash          VARCHAR(128) NOT NULL UNIQUE,          -- SHA-256 of raw token
    token_prefix        VARCHAR(12)  NOT NULL,                 -- first 8 chars for display
    scopes              TEXT[]       NOT NULL DEFAULT '{}',    -- ['incidents:read','alerts:write']
    last_used_at        TIMESTAMPTZ,
    expires_at          TIMESTAMPTZ,
    revoked_at          TIMESTAMPTZ,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);


-- =============================================================================
-- SECTION 7: API TOKENS
-- =============================================================================

INSERT INTO api_tokens (id, org_id, user_id, name, token_hash, token_prefix, scopes, last_used_at, expires_at, created_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001', NULL,
   'Prometheus Alert Webhook — Production',
   'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
   'sxp_prod_1a',
   ARRAY['alerts:write', 'incidents:read'],
   '2025-06-04 09:58:00+00', NULL,
   '2023-06-01 10:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001', NULL,
   'Datadog Integration — Production',
   'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
   'sxp_dd_2b',
   ARRAY['alerts:write'],
   '2025-06-04 10:01:00+00', NULL,
   '2023-07-15 08:00:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002',
   'Terraform Automation — SRE',
   'b3a8e0e1f98bfb4a4e8a63da61d7c4c7d2a9d6f5e8c3b2a1d4e5f6a7b8c9d0e1',
   'sxp_tf_3c',
   ARRAY['incidents:read', 'incidents:write', 'alerts:read'],
   '2025-06-03 14:22:00+00', '2026-01-01 00:00:00+00',
   '2024-02-01 09:00:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001', NULL,
   'Grafana Alertmanager — Staging',
   'c4b9f1f20a8c9e5b5f9b74eb62e8d5d8e3b0a7f6e9d4c3b2a5d6e7f8a9b0c1d2',
   'sxp_grf_4d',
   ARRAY['alerts:write'],
   '2025-05-28 11:30:00+00', NULL,
   '2024-04-10 07:00:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'Admin CLI — Priya',
   'd5c0a2031b9d0f6c6a0c85fc73f9e6e9f4c1b8a7f0e5d4c3b6d7e8f9a0b1c2d3',
   'sxp_cli_5e',
   ARRAY['incidents:admin', 'alerts:admin', 'escalations:admin', 'users:admin'],
   '2025-06-04 08:12:00+00', NULL,
   '2023-04-12 09:10:00+00'),

  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002', NULL,
   'CloudWatch Alerts — Production',
   'e6d1b3142c0e1a7d7b1d96ad84a0f7f0a5d2c9b8a1f6e5d4c7d8e9f0a1b2c3d4',
   'cnp_cw_6f',
   ARRAY['alerts:write'],
   '2025-06-04 06:00:00+00', NULL,
   '2024-02-01 10:00:00+00'),

  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000011-0002-0002-0002-000000000011',
   'Admin API — Carlos',
   'f7e2c4253d1f2b8e8c2e07be95b1a8a1b6e3d0c9b2a7f6e5d8e9f0a1b2c3d4e5',
   'cnp_adm_7a',
   ARRAY['incidents:admin', 'alerts:admin', 'users:admin'],
   '2025-06-04 09:01:00+00', NULL,
   '2024-01-15 11:00:00+00'),

  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   '00000016-0003-0003-0003-000000000016',
   'Uptime Robot Webhook',
   'a8f3d5364e2a3c9f9d3f18cf84b2b9b2c7f4e1d0c3b8a7f6e9f0a1b2c3d4e5f6',
   'nmb_utr_8b',
   ARRAY['alerts:write'],
   '2025-06-04 07:45:00+00', NULL,
   '2025-03-02 09:00:00+00'),

  -- Revoked token example
  ('00000009-0001-0001-0001-000000000009',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004',
   'Deprecated Runbook Script — Marcus',
   'b9a4e6475f3b4d0a0e4a29df95c3c0c3d8a5f2e1d4c9b8a7f0a1b2c3d4e5f6a7',
   'sxp_old_9z',
   ARRAY['incidents:read'],
   '2025-03-10 14:00:00+00', NULL,
   '2024-06-01 08:00:00+00');

-- Mark the revoked token
UPDATE api_tokens SET revoked_at = '2025-03-15 09:00:00+00' WHERE id = '00000009-0001-0001-0001-000000000009';


