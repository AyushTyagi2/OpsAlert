-- =============================================================================
-- DOMAIN 4: ESCALATION ENGINE
-- =============================================================================

-- ---------------------------------------------------------------------------
-- escalation_policies
-- ---------------------------------------------------------------------------
CREATE TABLE escalation_policies (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID NOT NULL REFERENCES organizations(id),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    repeat_count        INTEGER NOT NULL DEFAULT 0,   -- 0 = no repeat after all steps
    repeat_delay_minutes INTEGER NOT NULL DEFAULT 0,
    is_default          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE (org_id, name)
);
INSERT INTO escalation_policies (id, org_id, name, description, repeat_count, repeat_delay_minutes, is_default, created_at, updated_at) VALUES
 
  -- Synthrex policies
  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Platform SRE — Default',
   'Default escalation for all platform-level incidents. Pages on-call SRE, then team lead, then VP Engineering.',
   2, 30, TRUE,
   '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),
 
  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Payments — Critical Path',
   'Strict escalation for payment pipeline incidents. Immediate page, 5-minute escalation window.',
   3, 15, FALSE,
   '2023-06-01 10:00:00+00', '2025-02-15 11:00:00+00'),
 
  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Data Infrastructure — Kafka',
   'Escalation policy for Kafka and streaming infrastructure incidents.',
   1, 20, FALSE,
   '2023-07-01 10:00:00+00', '2024-11-01 08:00:00+00'),
 
  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Security Operations',
   'Security incident escalation: SecOps lead, CISO, then external incident response team.',
   1, 10, FALSE,
   '2024-01-10 09:00:00+00', '2024-06-01 10:00:00+00'),
 
  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Backend API — Low Urgency',
   'Low-urgency escalation for API degradation. 30-minute windows before escalating.',
   1, 60, FALSE,
   '2023-09-15 08:00:00+00', '2024-08-01 09:00:00+00'),
 
  -- Cloudnova policies
  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Infrastructure — Default',
   'Default infrastructure escalation policy for Cloudnova.',
   2, 30, TRUE,
   '2024-01-15 09:00:00+00', '2025-01-20 10:00:00+00'),
 
  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Product Engineering — Default',
   'Default escalation for product and API incidents.',
   1, 30, FALSE,
   '2024-01-15 09:00:00+00', '2024-09-10 10:00:00+00'),
 
  -- Nimbly policies
  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Engineering — Default',
   'Single-team escalation for all Nimbly engineering incidents.',
   1, 30, TRUE,
   '2025-03-01 13:00:00+00', '2025-03-01 13:00:00+00');
 