-- ---------------------------------------------------------------------------
-- users
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id              UUID         NOT NULL REFERENCES organizations(id),
    email               VARCHAR(320) NOT NULL,
    email_verified_at   TIMESTAMPTZ,
    full_name           VARCHAR(255) NOT NULL,
    avatar_url          TEXT,
    phone               VARCHAR(50),                           -- E.164 format
    timezone            VARCHAR(100) NOT NULL DEFAULT 'UTC',
    notification_rules  JSONB        NOT NULL DEFAULT '{}',    -- per-user quiet hours etc.
    is_org_owner        BOOLEAN      NOT NULL DEFAULT FALSE,
    last_login_at       TIMESTAMPTZ,
    deactivated_at      TIMESTAMPTZ,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    UNIQUE (org_id, email)
);

-- =============================================================================
-- SECTION 2: USERS
-- =============================================================================

INSERT INTO users (id, org_id, email, email_verified_at, full_name, avatar_url, phone, timezone, notification_rules, is_org_owner, last_login_at, created_at, updated_at) VALUES

  -- ── Synthrex users ───────────────────────────────────────────────────────────
  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'priya.mehta@synthrex.io', '2023-04-12 09:05:00+00',
   'Priya Mehta', 'https://avatars.synthrex.io/priya.mehta.png',
   '+12125550101', 'America/New_York',
   '{"high_urgency": {"channels": ["SLACK","SMS","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": null}'::jsonb,
   TRUE, '2025-06-04 08:12:00+00', '2023-04-12 09:02:00+00', '2025-06-04 08:12:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'daniel.osei@synthrex.io', '2023-05-02 10:00:00+00',
   'Daniel Osei', 'https://avatars.synthrex.io/daniel.osei.png',
   '+12125550102', 'America/New_York',
   '{"high_urgency": {"channels": ["SLACK","SMS"]}, "low_urgency": {"channels": ["SLACK"]}, "quiet_hours": {"start": "23:00", "end": "07:00", "override_sev1": true}}'::jsonb,
   FALSE, '2025-06-04 09:45:00+00', '2023-05-02 10:00:00+00', '2025-06-04 09:45:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'sofia.reyes@synthrex.io', '2023-06-15 08:30:00+00',
   'Sofia Reyes', 'https://avatars.synthrex.io/sofia.reyes.png',
   '+12125550103', 'America/Chicago',
   '{"high_urgency": {"channels": ["SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": null}'::jsonb,
   FALSE, '2025-06-03 22:11:00+00', '2023-06-15 08:30:00+00', '2025-06-03 22:11:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'marcus.klein@synthrex.io', '2023-08-01 07:00:00+00',
   'Marcus Klein', 'https://avatars.synthrex.io/marcus.klein.png',
   '+12125550104', 'America/New_York',
   '{"high_urgency": {"channels": ["SMS","SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": {"start": "22:00", "end": "06:00", "override_sev1": true}}'::jsonb,
   FALSE, '2025-06-04 10:02:00+00', '2023-08-01 07:00:00+00', '2025-06-04 10:02:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'amara.johnson@synthrex.io', '2023-09-10 14:00:00+00',
   'Amara Johnson', 'https://avatars.synthrex.io/amara.johnson.png',
   '+12125550105', 'America/New_York',
   '{"high_urgency": {"channels": ["SLACK","SMS"]}, "low_urgency": {"channels": ["SLACK"]}, "quiet_hours": null}'::jsonb,
   FALSE, '2025-06-04 07:30:00+00', '2023-09-10 14:00:00+00', '2025-06-04 07:30:00+00'),

  ('00000006-0001-0001-0001-000000000006',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'tomasz.wisnewski@synthrex.io', '2024-01-15 09:00:00+00',
   'Tomasz Wisnewski', 'https://avatars.synthrex.io/tomasz.wisnewski.png',
   '+12125550106', 'Europe/Warsaw',
   '{"high_urgency": {"channels": ["SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": {"start": "23:00", "end": "08:00", "override_sev1": true}}'::jsonb,
   FALSE, '2025-06-04 11:00:00+00', '2024-01-15 09:00:00+00', '2025-06-04 11:00:00+00'),

  ('00000007-0001-0001-0001-000000000007',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'neha.patel@synthrex.io', '2024-03-01 08:30:00+00',
   'Neha Patel', 'https://avatars.synthrex.io/neha.patel.png',
   '+12125550107', 'America/Los_Angeles',
   '{"high_urgency": {"channels": ["SMS","SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": null}'::jsonb,
   FALSE, '2025-06-03 20:05:00+00', '2024-03-01 08:30:00+00', '2025-06-03 20:05:00+00'),

  ('00000008-0001-0001-0001-000000000008',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'james.okonkwo@synthrex.io', '2024-04-10 10:15:00+00',
   'James Okonkwo', 'https://avatars.synthrex.io/james.okonkwo.png',
   '+12125550108', 'America/New_York',
   '{"high_urgency": {"channels": ["SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": {"start": "22:30", "end": "07:30", "override_sev1": true}}'::jsonb,
   FALSE, '2025-06-04 06:48:00+00', '2024-04-10 10:15:00+00', '2025-06-04 06:48:00+00'),

  ('00000009-0001-0001-0001-000000000009',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'linda.baxter@synthrex.io', '2024-05-20 13:00:00+00',
   'Linda Baxter', NULL,
   '+12125550109', 'America/New_York',
   '{"high_urgency": {"channels": ["EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}, "quiet_hours": null}'::jsonb,
   FALSE, '2025-05-30 14:22:00+00', '2024-05-20 13:00:00+00', '2025-05-30 14:22:00+00'),

  ('00000010-0001-0001-0001-000000000010',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'ryan.nguyen@synthrex.io', '2024-07-08 09:45:00+00',
   'Ryan Nguyen', 'https://avatars.synthrex.io/ryan.nguyen.png',
   '+12125550110', 'America/Los_Angeles',
   '{"high_urgency": {"channels": ["SLACK","SMS"]}, "low_urgency": {"channels": ["SLACK"]}, "quiet_hours": null}'::jsonb,
   FALSE, '2025-06-04 05:15:00+00', '2024-07-08 09:45:00+00', '2025-06-04 05:15:00+00'),

  -- ── Cloudnova users ──────────────────────────────────────────────────────────
  ('00000011-0002-0002-0002-000000000011',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'carlos.vega@cloudnova.dev', '2024-01-10 14:00:00+00',
   'Carlos Vega', 'https://avatars.cloudnova.dev/carlos.vega.png',
   '+14155550201', 'America/Los_Angeles',
   '{"high_urgency": {"channels": ["SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   TRUE, '2025-06-04 09:00:00+00', '2024-01-10 14:00:00+00', '2025-06-04 09:00:00+00'),

  ('00000012-0002-0002-0002-000000000012',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'fatima.al-rashid@cloudnova.dev', '2024-02-14 10:00:00+00',
   'Fatima Al-Rashid', 'https://avatars.cloudnova.dev/fatima.al-rashid.png',
   '+14155550202', 'America/Los_Angeles',
   '{"high_urgency": {"channels": ["SMS","SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-03 18:30:00+00', '2024-02-14 10:00:00+00', '2025-06-03 18:30:00+00'),

  ('00000013-0002-0002-0002-000000000013',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'ben.hartley@cloudnova.dev', '2024-03-20 09:30:00+00',
   'Ben Hartley', NULL,
   '+14155550203', 'America/Denver',
   '{"high_urgency": {"channels": ["SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-04 11:20:00+00', '2024-03-20 09:30:00+00', '2025-06-04 11:20:00+00'),

  ('00000014-0002-0002-0002-000000000014',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'yuki.tanaka@cloudnova.dev', '2024-05-05 08:00:00+00',
   'Yuki Tanaka', 'https://avatars.cloudnova.dev/yuki.tanaka.png',
   '+14155550204', 'America/Los_Angeles',
   '{"high_urgency": {"channels": ["SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-03 22:45:00+00', '2024-05-05 08:00:00+00', '2025-06-03 22:45:00+00'),

  ('00000015-0002-0002-0002-000000000015',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'grace.oduya@cloudnova.dev', '2024-08-12 11:00:00+00',
   'Grace Oduya', 'https://avatars.cloudnova.dev/grace.oduya.png',
   '+14155550205', 'America/Chicago',
   '{"high_urgency": {"channels": ["EMAIL","SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-04 07:10:00+00', '2024-08-12 11:00:00+00', '2025-06-04 07:10:00+00'),

  -- ── Nimbly users ─────────────────────────────────────────────────────────────
  ('00000016-0003-0003-0003-000000000016',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'alex.drummond@nimbly.io', '2025-03-01 12:00:00+00',
   'Alex Drummond', NULL,
   '+442071234567', 'Europe/London',
   '{"high_urgency": {"channels": ["EMAIL","SLACK"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   TRUE, '2025-06-04 08:00:00+00', '2025-03-01 12:00:00+00', '2025-06-04 08:00:00+00'),

  ('00000017-0003-0003-0003-000000000017',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'sara.lundqvist@nimbly.io', '2025-03-05 09:00:00+00',
   'Sara Lundqvist', NULL,
   '+442071234568', 'Europe/Stockholm',
   '{"high_urgency": {"channels": ["SLACK","EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-04 09:30:00+00', '2025-03-05 09:00:00+00', '2025-06-04 09:30:00+00'),

  ('00000018-0003-0003-0003-000000000018',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'oliver.mbeki@nimbly.io', '2025-03-10 10:00:00+00',
   'Oliver Mbeki', NULL,
   '+442071234569', 'Europe/London',
   '{"high_urgency": {"channels": ["EMAIL"]}, "low_urgency": {"channels": ["EMAIL"]}}'::jsonb,
   FALSE, '2025-06-03 16:00:00+00', '2025-03-10 10:00:00+00', '2025-06-03 16:00:00+00');
