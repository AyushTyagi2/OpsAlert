-- ---------------------------------------------------------------------------
-- on_call_overrides  (vacation covers, ad-hoc swaps)
-- ---------------------------------------------------------------------------
CREATE TABLE on_call_overrides (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id     UUID NOT NULL REFERENCES on_call_schedules(id) ON DELETE CASCADE,
    original_user_id UUID REFERENCES users(id),
    override_user_id UUID NOT NULL REFERENCES users(id),
    starts_at       TIMESTAMPTZ NOT NULL,
    ends_at         TIMESTAMPTZ NOT NULL,
    reason          TEXT,
    created_by_user_id UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT override_period_valid CHECK (ends_at > starts_at)
);

-- Prevent overlapping overrides for the same schedule:
CREATE INDEX idx_on_call_overrides_schedule_period
    ON on_call_overrides USING GIST (schedule_id, TSTZRANGE(starts_at, ends_at));