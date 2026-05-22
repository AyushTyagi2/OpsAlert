-- ---------------------------------------------------------------------------
-- on_call_schedules
-- ---------------------------------------------------------------------------
CREATE TABLE on_call_schedules (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID NOT NULL REFERENCES organizations(id),
    name                VARCHAR(255) NOT NULL,
    description         TEXT,
    timezone            VARCHAR(100) NOT NULL DEFAULT 'UTC',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE (org_id, name)
);


-- =============================================================================
-- SECTION 12: ON-CALL SCHEDULES
-- =============================================================================

INSERT INTO on_call_schedules (id, org_id, name, description, timezone, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Platform SRE — Primary Rotation',
   'Weekly rotation covering primary on-call for all platform infrastructure incidents.',
   'America/New_York', '2023-04-15 10:00:00+00', '2025-01-01 09:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Payments Engineering — Primary',
   'Weekly rotation for payment system on-call coverage.',
   'America/New_York', '2023-06-01 10:00:00+00', '2025-01-01 09:00:00+00'),

  ('00000003-0002-0002-0002-000000000003',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Infrastructure — Primary Rotation',
   'Cloudnova primary infrastructure on-call rotation.',
   'America/Los_Angeles', '2024-02-01 10:00:00+00', '2025-01-10 08:00:00+00'),

  ('00000004-0003-0003-0003-000000000004',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Engineering — All Hands',
   'Nimbly single-rotation covering all engineering on-call.',
   'Europe/London', '2025-03-01 13:00:00+00', '2025-03-01 13:00:00+00');


-- =============================================================================
-- SECTION 13: ON-CALL ROTATIONS
-- =============================================================================
