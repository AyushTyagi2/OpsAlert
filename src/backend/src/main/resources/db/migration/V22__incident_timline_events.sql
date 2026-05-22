-- ---------------------------------------------------------------------------
-- incident_timeline_events  (immutable append-only audit trail)
-- Partitioned monthly because high-volume incidents can generate many events
-- ---------------------------------------------------------------------------
CREATE TABLE incident_timeline_events (
    id              UUID NOT NULL DEFAULT gen_random_uuid(),
    incident_id     UUID NOT NULL,   -- no FK: cross-partition safe
    org_id          UUID NOT NULL,
    event_type      timeline_event_type NOT NULL,
    actor_user_id   UUID,            -- NULL = system-generated
    actor_service   VARCHAR(100),    -- kafka consumer name, etc.
    payload         JSONB NOT NULL DEFAULT '{}',  -- old_value / new_value etc.
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE incident_timeline_events_2025_01 PARTITION OF incident_timeline_events
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE incident_timeline_events_2025_02 PARTITION OF incident_timeline_events
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');


-- =============================================================================
-- SECTION 24: INCIDENT TIMELINE EVENTS
-- (into partitioned table)
-- =============================================================================

CREATE TABLE IF NOT EXISTS incident_timeline_events_2025_04 PARTITION OF incident_timeline_events
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE IF NOT EXISTS incident_timeline_events_2025_05 PARTITION OF incident_timeline_events
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE IF NOT EXISTS incident_timeline_events_2025_06 PARTITION OF incident_timeline_events
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

INSERT INTO incident_timeline_events (id, incident_id, org_id, event_type, actor_user_id, actor_service, payload, occurred_at, created_at) VALUES

  -- INC-0001 (OOM Payments)
  ('00000001-0001-0001-0001-000000000001', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'INCIDENT_CREATED', NULL, 'alert-routing-engine',
   '{"severity": "SEV1", "title": "Payment Processor Pods OOMKilling — Production Kubernetes", "triggered_by_alert_id": "al000001-0001-0001-0001-000000000001"}'::jsonb,
   '2025-05-14 02:18:00+00', '2025-05-14 02:18:00+00'),

  ('00000002-0001-0001-0001-000000000002', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ALERT_LINKED', NULL, 'alert-routing-engine',
   '{"alert_id": "al000002-0001-0001-0001-000000000002", "alert_title": "KubernetesPodCrashLooping — payments/payment-processor-6d8f9b7c4-jks2m", "dedup_key": "KubernetesPodCrashLooping/payments/payment-processor-6d8f9b7c4-jks2m"}'::jsonb,
   '2025-05-14 02:22:00+00', '2025-05-14 02:22:00+00'),

  ('00000003-0001-0001-0001-000000000003', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ACKNOWLEDGED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"source": "SLACK", "message": "On it — pulling pod logs now"}'::jsonb,
   '2025-05-14 02:24:00+00', '2025-05-14 02:24:00+00'),

  ('00000004-0001-0001-0001-000000000004', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ASSIGNED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"assignee_user_id": "u0000007-0001-0001-0001-000000000007", "assignee_name": "Neha Patel", "reason": "Heap dump expert"}'::jsonb,
   '2025-05-14 02:30:00+00', '2025-05-14 02:30:00+00'),

  ('00000005-0001-0001-0001-000000000005', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'STATUS_CHANGED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"old_status": "ACKNOWLEDGED", "new_status": "INVESTIGATING"}'::jsonb,
   '2025-05-14 02:35:00+00', '2025-05-14 02:35:00+00'),

  ('00000006-0001-0001-0001-000000000006', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'STATUS_CHANGED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"old_status": "INVESTIGATING", "new_status": "IDENTIFIED", "cause": "Memory leak in idempotency HashMap — no TTL"}'::jsonb,
   '2025-05-14 02:52:00+00', '2025-05-14 02:52:00+00'),

  ('00000007-0001-0001-0001-000000000007', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'STATUS_CHANGED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"old_status": "IDENTIFIED", "new_status": "MONITORING", "action": "Rolled back to v2.7.9"}'::jsonb,
   '2025-05-14 03:48:00+00', '2025-05-14 03:48:00+00'),

  ('00000008-0001-0001-0001-000000000008', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'RESOLVED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"resolution_summary": "Rolled back to v2.7.9. Memory stable at 180Mi/512Mi limit. No further OOMKill events.", "mttr_minutes": 107}'::jsonb,
   '2025-05-14 04:05:00+00', '2025-05-14 04:05:00+00'),

  ('00000009-0001-0001-0001-000000000009', '00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   'CLOSED', '00000001-0001-0001-0001-000000000001', NULL,
   '{"postmortem_url": "https://www.notion.so/synthrex/INC-0001-Postmortem-Payment-OOM-a1b2c3d4", "closed_by": "Priya Mehta"}'::jsonb,
   '2025-05-14 05:30:00+00', '2025-05-14 05:30:00+00'),

  -- INC-0004 (DB Pool — active, escalated)
  ('00000010-0001-0001-0001-000000000010', '00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   'INCIDENT_CREATED', NULL, 'alert-routing-engine',
   '{"severity": "SEV1", "title": "PostgreSQL Connection Pool Exhausted — pg-primary-us-east-1"}'::jsonb,
   '2025-06-03 22:07:00+00', '2025-06-03 22:07:00+00'),

  ('00000011-0001-0001-0001-000000000011', '00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ALERT_LINKED', NULL, 'alert-routing-engine',
   '{"alert_id": "al000006-0001-0001-0001-000000000006", "alert_title": "PostgreSQLHighConnectionRate — pg-primary-us-east-1", "linked_by": "Daniel Osei"}'::jsonb,
   '2025-06-03 22:10:00+00', '2025-06-03 22:10:00+00'),

  ('00000012-0001-0001-0001-000000000012', '00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ACKNOWLEDGED', '00000002-0001-0001-0001-000000000002', NULL,
   '{"source": "SMS"}'::jsonb,
   '2025-06-03 22:11:00+00', '2025-06-03 22:11:00+00'),

  ('00000013-0001-0001-0001-000000000013', '00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ESCALATED', NULL, 'escalation-engine',
   '{"step": 2, "escalation_policy": "Platform SRE — Default", "notified_users": ["Daniel Osei", "Marcus Klein"], "reason": "No ack timeout after 15 minutes"}'::jsonb,
   '2025-06-03 22:26:00+00', '2025-06-03 22:26:00+00'),

  ('00000014-0001-0001-0001-000000000014', '00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   'STATUS_CHANGED', '00000002-0001-0001-0001-000000000002', NULL,
   '{"old_status": "ACKNOWLEDGED", "new_status": "INVESTIGATING"}'::jsonb,
   '2025-06-03 22:30:00+00', '2025-06-03 22:30:00+00'),

  -- INC-0010 (Stripe — escalated, active)
  ('00000015-0001-0001-0001-000000000015', '00000010-0001-0001-0001-000000000010', 'a1b2c3d4-0001-0001-0001-000000000001',
   'INCIDENT_CREATED', NULL, 'alert-routing-engine',
   '{"severity": "SEV1", "title": "Stripe Integration Error Rate 31% — Payment Processing Severely Degraded"}'::jsonb,
   '2025-06-04 10:23:00+00', '2025-06-04 10:23:00+00'),

  ('00000016-0001-0001-0001-000000000016', '00000010-0001-0001-0001-000000000010', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ACKNOWLEDGED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"source": "SLACK"}'::jsonb,
   '2025-06-04 10:27:00+00', '2025-06-04 10:27:00+00'),

  ('00000017-0001-0001-0001-000000000017', '00000010-0001-0001-0001-000000000010', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ESCALATED', NULL, 'escalation-engine',
   '{"step": 2, "notified_users": ["Sofia Reyes"], "reason": "SEV1 — auto-escalated to team lead"}'::jsonb,
   '2025-06-04 10:28:00+00', '2025-06-04 10:28:00+00'),

  ('00000018-0001-0001-0001-000000000018', '00000010-0001-0001-0001-000000000010', 'a1b2c3d4-0001-0001-0001-000000000001',
   'ESCALATED', NULL, 'escalation-engine',
   '{"step": 3, "notified_users": ["Sofia Reyes", "Neha Patel", "Ryan Nguyen"], "reason": "Unresolved after 10 minutes — team-wide escalation"}'::jsonb,
   '2025-06-04 10:38:00+00', '2025-06-04 10:38:00+00'),

  ('00000019-0001-0001-0001-000000000019', '00000010-0001-0001-0001-000000000010', 'a1b2c3d4-0001-0001-0001-000000000001',
   'NOTE_ADDED', '00000003-0001-0001-0001-000000000003', NULL,
   '{"note_id": "in000010-0001-0001-0001-000000000010", "snippet": "Stripe status page confirms degradation. Evaluating Braintree fallback..."}'::jsonb,
   '2025-06-04 10:32:00+00', '2025-06-04 10:32:00+00'),

  -- INC-0008 (Nimbly API down)
  ('00000020-0003-0003-0003-000000000020', '00000008-0003-0003-0003-000000000008', 'c3d4e5f6-0003-0003-0003-000000000003',
   'INCIDENT_CREATED', NULL, 'alert-routing-engine',
   '{"severity": "SEV1", "title": "API Service Down — api.nimbly.io returning HTTP 502"}'::jsonb,
   '2025-05-30 03:46:00+00', '2025-05-30 03:46:00+00'),

  ('00000021-0003-0003-0003-000000000021', '00000008-0003-0003-0003-000000000008', 'c3d4e5f6-0003-0003-0003-000000000003',
   'ACKNOWLEDGED', '00000017-0003-0003-0003-000000000017', NULL,
   '{"source": "SMS"}'::jsonb,
   '2025-05-30 03:55:00+00', '2025-05-30 03:55:00+00'),

  ('00000022-0003-0003-0003-000000000022', '00000008-0003-0003-0003-000000000008', 'c3d4e5f6-0003-0003-0003-000000000003',
   'STATUS_CHANGED', '00000017-0003-0003-0003-000000000017', NULL,
   '{"old_status": "ACKNOWLEDGED", "new_status": "IDENTIFIED", "cause": "ECS nightly-reindex-job OOMKilled API tasks"}'::jsonb,
   '2025-05-30 04:08:00+00', '2025-05-30 04:08:00+00'),

  ('00000023-0003-0003-0003-000000000023', '00000008-0003-0003-0003-000000000008', 'c3d4e5f6-0003-0003-0003-000000000003',
   'RESOLVED', '00000017-0003-0003-0003-000000000017', NULL,
   '{"resolution_summary": "Forced new ECS task deployment. All 3 tasks running and healthy.", "mttr_minutes": 54}'::jsonb,
   '2025-05-30 04:40:00+00', '2025-05-30 04:40:00+00'),

  ('00000024-0003-0003-0003-000000000024', '00000008-0003-0003-0003-000000000008', 'c3d4e5f6-0003-0003-0003-000000000003',
   'CLOSED', '00000016-0003-0003-0003-000000000016', NULL,
   '{"closed_by": "Alex Drummond"}'::jsonb,
   '2025-05-30 05:00:00+00', '2025-05-30 05:00:00+00');


