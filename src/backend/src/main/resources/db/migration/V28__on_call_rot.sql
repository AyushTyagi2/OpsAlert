-- ---------------------------------------------------------------------------
-- on_call_rotations
-- ---------------------------------------------------------------------------
CREATE TABLE on_call_rotations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id         UUID NOT NULL REFERENCES on_call_schedules(id) ON DELETE CASCADE,
    name                VARCHAR(255) NOT NULL,
    rotation_type       rotation_type NOT NULL DEFAULT 'WEEKLY',
    hand_off_time       TIME NOT NULL DEFAULT '09:00',   -- local time in schedule tz
    hand_off_day        SMALLINT,                         -- 0=Mon…6=Sun for WEEKLY
    shift_duration_hours INTEGER,                         -- for CUSTOM
    starts_at           TIMESTAMPTZ NOT NULL,
    ends_at             TIMESTAMPTZ,                      -- NULL = indefinite
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


INSERT INTO on_call_rotations (id, schedule_id, name, rotation_type, hand_off_time, hand_off_day, starts_at, ends_at, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001',
   'Weekly SRE Rotation',
   'WEEKLY', '09:00', 1,
   '2025-01-06 14:00:00+00', NULL,
   '2023-04-15 10:00:00+00', '2025-01-01 09:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   '00000002-0001-0001-0001-000000000002',
   'Weekly Payments Rotation',
   'WEEKLY', '09:00', 1,
   '2025-01-06 14:00:00+00', NULL,
   '2023-06-01 10:00:00+00', '2025-01-01 09:00:00+00'),

  ('00000003-0002-0002-0002-000000000003',
   '00000003-0002-0002-0002-000000000003',
   'Weekly Infra Rotation',
   'WEEKLY', '09:00', 1,
   '2025-01-06 17:00:00+00', NULL,
   '2024-02-01 10:00:00+00', '2025-01-10 08:00:00+00'),

  ('00000004-0003-0003-0003-000000000004',
   '00000004-0003-0003-0003-000000000004',
   'Weekly Nimbly Rotation',
   'WEEKLY', '09:00', 1,
   '2025-03-03 09:00:00+00', NULL,
   '2025-03-01 13:00:00+00', '2025-03-01 13:00:00+00');

