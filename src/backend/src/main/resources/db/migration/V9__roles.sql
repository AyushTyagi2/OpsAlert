-- ---------------------------------------------------------------------------
-- roles  (scoped to org)
-- ---------------------------------------------------------------------------
CREATE TABLE roles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    name                VARCHAR(100) NOT NULL,
    description         TEXT,
    is_system_role      BOOLEAN      NOT NULL DEFAULT FALSE,   -- cannot be deleted
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (org_id, name)
);

-- =============================================================================
-- SECTION 5: ROLES
-- =============================================================================

INSERT INTO roles (id, org_id, name, description, is_system_role, created_at, updated_at) VALUES

  -- Synthrex roles
  ('00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001', 'Owner',           'Full administrative access to the organization.',         TRUE,  '2023-04-12 09:00:00+00', '2023-04-12 09:00:00+00'),
  ('00000002-0001-0001-0001-000000000002', 'a1b2c3d4-0001-0001-0001-000000000001', 'Admin',           'Administrative access, can manage users and policies.',   TRUE,  '2023-04-12 09:00:00+00', '2023-04-12 09:00:00+00'),
  ('00000003-0001-0001-0001-000000000003', 'a1b2c3d4-0001-0001-0001-000000000001', 'Responder',       'Can acknowledge, update, and resolve incidents.',          TRUE,  '2023-04-12 09:00:00+00', '2023-04-12 09:00:00+00'),
  ('00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001', 'Observer',        'Read-only access to incidents and alerts.',               TRUE,  '2023-04-12 09:00:00+00', '2023-04-12 09:00:00+00'),
  ('00000005-0001-0001-0001-000000000005', 'a1b2c3d4-0001-0001-0001-000000000001', 'SecOps Auditor',  'Read access to all events and audit logs.',               FALSE, '2024-01-10 09:00:00+00', '2024-01-10 09:00:00+00'),

  -- Cloudnova roles
  ('00000006-0002-0002-0002-000000000006', 'b2c3d4e5-0002-0002-0002-000000000002', 'Owner',     'Full administrative access.', TRUE,  '2024-01-10 14:00:00+00', '2024-01-10 14:00:00+00'),
  ('00000007-0002-0002-0002-000000000007', 'b2c3d4e5-0002-0002-0002-000000000002', 'Responder', 'Can acknowledge and resolve incidents.', TRUE, '2024-01-10 14:00:00+00', '2024-01-10 14:00:00+00'),
  ('00000008-0002-0002-0002-000000000008', 'b2c3d4e5-0002-0002-0002-000000000002', 'Observer',  'Read-only access.', TRUE, '2024-01-10 14:00:00+00', '2024-01-10 14:00:00+00'),

  -- Nimbly roles
  ('00000009-0003-0003-0003-000000000009', 'c3d4e5f6-0003-0003-0003-000000000003', 'Owner',     'Full access.', TRUE, '2025-03-01 12:00:00+00', '2025-03-01 12:00:00+00'),
  ('00000010-0003-0003-0003-000000000010', 'c3d4e5f6-0003-0003-0003-000000000003', 'Responder', 'Can respond to incidents.', TRUE, '2025-03-01 12:00:00+00', '2025-03-01 12:00:00+00');

