-- ---------------------------------------------------------------------------
-- notification_logs  (high-volume: partitioned monthly)
-- One row per attempted notification delivery
-- ---------------------------------------------------------------------------
CREATE TABLE notification_logs (
    id                      UUID NOT NULL DEFAULT gen_random_uuid(),
    org_id                  UUID NOT NULL,
    incident_id             UUID,               -- nullable: alert-level notifs
    alert_id                UUID,
    user_id                 UUID,               -- recipient
    team_id                 UUID,
    template_id             UUID,
    channel                 notification_channel NOT NULL,
    status                  notification_status NOT NULL DEFAULT 'PENDING',
    subject                 TEXT,
    body                    TEXT,
    recipient_address       TEXT NOT NULL,      -- email / phone / webhook url / slack channel
    external_message_id     TEXT,               -- provider-returned ID (SES MessageId, etc.)
    failure_reason          TEXT,
    retry_count             SMALLINT NOT NULL DEFAULT 0,
    max_retries             SMALLINT NOT NULL DEFAULT 3,
    next_retry_at           TIMESTAMPTZ,
    sent_at                 TIMESTAMPTZ,
    delivered_at            TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE notification_logs_2025_01 PARTITION OF notification_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE notification_logs_2025_02 PARTITION OF notification_logs
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');


-- =============================================================================
-- SECTION 26: NOTIFICATION LOGS
-- (into partitioned table)
-- =============================================================================

CREATE TABLE IF NOT EXISTS notification_logs_2025_04 PARTITION OF notification_logs
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE IF NOT EXISTS notification_logs_2025_05 PARTITION OF notification_logs
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE IF NOT EXISTS notification_logs_2025_06 PARTITION OF notification_logs
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

INSERT INTO notification_logs (id, org_id, incident_id, user_id, template_id, channel, status, subject, body, recipient_address, external_message_id, failure_reason, retry_count, max_retries, next_retry_at, sent_at, delivered_at, created_at, updated_at) VALUES

  -- INC-0001 notifications (OOM, SEV1)
  ('00000001-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', '00000003-0001-0001-0001-000000000003',
   '00000001-0001-0001-0001-000000000001',
   'SLACK', 'DELIVERED', NULL,
   ':rotating_light: *[SEV1] Payment Processor Pods OOMKilling — Production Kubernetes*',
   'U03SREYES', 'slack_msg_C06PAY_001', NULL, 0, 3, NULL,
   '2025-05-14 02:18:30+00', '2025-05-14 02:18:31+00',
   '2025-05-14 02:18:00+00', '2025-05-14 02:18:31+00'),

  ('00000002-0001-0001-0001-000000000002', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', '00000003-0001-0001-0001-000000000003',
   '00000002-0001-0001-0001-000000000002',
   'SMS', 'DELIVERED', NULL,
   '[Synthrex SEV1] Payment Processor Pods OOMKilling — INC-0001 ack: https://app.synthrex.io/ack/ic000001',
   '+12125550103', 'SM_twilio_ic0001_002', NULL, 0, 3, NULL,
   '2025-05-14 02:18:45+00', '2025-05-14 02:18:52+00',
   '2025-05-14 02:18:00+00', '2025-05-14 02:18:52+00'),

  -- INC-0001 escalation notification for Sofia (team lead)
  ('00000003-0001-0001-0001-000000000003', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', '00000007-0001-0001-0001-000000000007',
   '00000003-0001-0001-0001-000000000003',
   'EMAIL', 'DELIVERED',
   '[SEV1] INCIDENT: Payment Processor Pods OOMKilling — Synthrex Ops',
   '<h2>SEV1 Incident — INC-0001</h2><p>Payment Processor Pods OOMKilling — Production Kubernetes</p>',
   'neha.patel@synthrex.io', 'ses_msg_ic0001_003', NULL, 0, 3, NULL,
   '2025-05-14 02:31:00+00', '2025-05-14 02:32:10+00',
   '2025-05-14 02:30:00+00', '2025-05-14 02:32:10+00'),

  -- INC-0004 notifications (DB Pool, SEV1)
  ('00000004-0001-0001-0001-000000000004', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004', '00000002-0001-0001-0001-000000000002',
   '00000001-0001-0001-0001-000000000001',
   'SLACK', 'DELIVERED', NULL,
   ':rotating_light: *[SEV1] PostgreSQL Connection Pool Exhausted — pg-primary-us-east-1*',
   'U02DOSEI', 'slack_msg_C06SRE_004', NULL, 0, 3, NULL,
   '2025-06-03 22:07:30+00', '2025-06-03 22:07:31+00',
   '2025-06-03 22:07:00+00', '2025-06-03 22:07:31+00'),

  ('00000005-0001-0001-0001-000000000005', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004', '00000002-0001-0001-0001-000000000002',
   '00000002-0001-0001-0001-000000000002',
   'SMS', 'DELIVERED', NULL,
   '[Synthrex SEV1] PostgreSQL Connection Pool Exhausted — INC-0004 ack: https://app.synthrex.io/ack/ic000004',
   '+12125550102', 'SM_twilio_ic0004_005', NULL, 0, 3, NULL,
   '2025-06-03 22:07:45+00', '2025-06-03 22:07:53+00',
   '2025-06-03 22:07:00+00', '2025-06-03 22:07:53+00'),

  -- INC-0004 escalation step 2 (failed then retried)
  ('00000006-0001-0001-0001-000000000006', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000004-0001-0001-0001-000000000004', '00000004-0001-0001-0001-000000000004',
   '00000002-0001-0001-0001-000000000002',
   'SMS', 'DELIVERED', NULL,
   '[Synthrex SEV1] PostgreSQL Connection Pool Exhausted — INC-0004 ESCALATED ack: https://app.synthrex.io/ack/ic000004',
   '+12125550104', 'SM_twilio_ic0004_006', NULL, 1, 3, NULL,
   '2025-06-03 22:27:30+00', '2025-06-03 22:28:05+00',
   '2025-06-03 22:26:00+00', '2025-06-03 22:28:05+00'),

  -- INC-0010 (Stripe SEV1) — SMS delivery failed, retrying
  ('00000007-0001-0001-0001-000000000007', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000010-0001-0001-0001-000000000010', '00000003-0001-0001-0001-000000000003',
   '00000001-0001-0001-0001-000000000001',
   'SLACK', 'DELIVERED', NULL,
   ':rotating_light: *[SEV1] Stripe Integration Error Rate 31% — Payment Processing Severely Degraded*',
   'U03SREYES', 'slack_msg_C06PAY_MAJOR_007', NULL, 0, 3, NULL,
   '2025-06-04 10:23:30+00', '2025-06-04 10:23:31+00',
   '2025-06-04 10:23:00+00', '2025-06-04 10:23:31+00'),

  ('00000008-0001-0001-0001-000000000008', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000010-0001-0001-0001-000000000010', '00000003-0001-0001-0001-000000000003',
   '00000002-0001-0001-0001-000000000002',
   'SMS', 'RETRYING', NULL,
   '[Synthrex SEV1] Stripe Integration Error Rate 31% — INC-0007 ack: https://app.synthrex.io/ack/ic000010',
   '+12125550103', NULL,
   'Twilio error 21408: Permission to send an SMS has not been enabled for the region indicated by the To number. Carrier: Verizon CDMA block.',
   2, 3, '2025-06-04 10:28:00+00',
   '2025-06-04 10:23:45+00', NULL,
   '2025-06-04 10:23:00+00', '2025-06-04 10:25:00+00'),

  -- INC-0010 escalation step 3 — webhook FAILED (wrong URL)
  ('00000009-0001-0001-0001-000000000009', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000010-0001-0001-0001-000000000010', NULL,
   NULL,
   'WEBHOOK', 'FAILED', NULL,
   '{"incident_id":"ic000010","severity":"SEV1","title":"Stripe Integration Error Rate 31%","status":"ACKNOWLEDGED","ack_time":"2025-06-04T10:27:00Z"}',
   'https://hooks.zapier.com/hooks/catch/1234567/abcdef1/',
   NULL,
   'HTTP 410 Gone — webhook endpoint has been deactivated in Zapier. Zap ID: 1234567.',
   3, 3, NULL,
   '2025-06-04 10:38:30+00', NULL,
   '2025-06-04 10:38:00+00', '2025-06-04 10:42:00+00'),

  -- INC-0006 Cloudnova (Redis) notifications
  ('00000010-0002-0002-0002-000000000010', 'b2c3d4e5-0002-0002-0002-000000000002',
   '00000006-0002-0002-0002-000000000006', '00000012-0002-0002-0002-000000000012',
   '00000006-0002-0002-0002-000000000006',
   'SLACK', 'DELIVERED', NULL,
   ':alert: *[SEV2] Redis Cache Memory Pressure — redis-cache-001 (94% used, high eviction rate)*',
   'U04FATIMA', 'slack_msg_C05INFRA_001', NULL, 0, 3, NULL,
   '2025-05-28 14:25:30+00', '2025-05-28 14:25:31+00',
   '2025-05-28 14:25:00+00', '2025-05-28 14:25:31+00'),

  ('00000011-0002-0002-0002-000000000011', 'b2c3d4e5-0002-0002-0002-000000000002',
   '00000006-0002-0002-0002-000000000006', '00000012-0002-0002-0002-000000000012',
   '00000007-0002-0002-0002-000000000007',
   'EMAIL', 'DELIVERED',
   '[ALERT] SEV2: Redis Cache Memory Pressure — redis-cache-001',
   '<p>SEV2 incident triggered for team Infrastructure.</p>',
   'fatima.al-rashid@cloudnova.dev', 'ses_msg_ic0006_011', NULL, 0, 3, NULL,
   '2025-05-28 14:25:45+00', '2025-05-28 14:26:15+00',
   '2025-05-28 14:25:00+00', '2025-05-28 14:26:15+00'),

  -- INC-0008 Nimbly (API Down) notifications
  ('00000012-0003-0003-0003-000000000012', 'c3d4e5f6-0003-0003-0003-000000000003',
   '00000008-0003-0003-0003-000000000008', '00000017-0003-0003-0003-000000000017',
   '00000008-0003-0003-0003-000000000008',
   'EMAIL', 'DELIVERED',
   '[SEV1] API Service Down — api.nimbly.io returning HTTP 502 from all regions — Nimbly Alert',
   '<p>An incident has been triggered. Please respond immediately.</p>',
   'sara.lundqvist@nimbly.io', 'ses_msg_ic0008_012', NULL, 0, 3, NULL,
   '2025-05-30 03:46:30+00', '2025-05-30 03:47:02+00',
   '2025-05-30 03:46:00+00', '2025-05-30 03:47:02+00'),

  ('00000013-0003-0003-0003-000000000013', 'c3d4e5f6-0003-0003-0003-000000000003',
   '00000008-0003-0003-0003-000000000008', '00000017-0003-0003-0003-000000000017',
   NULL,
   'SMS', 'DELIVERED', NULL,
   '[Nimbly SEV1] API down — api.nimbly.io HTTP 502. Respond: https://app.nimbly.io/inc/ic000008',
   '+442071234568', 'SM_twilio_ic0008_013', NULL, 0, 3, NULL,
   '2025-05-30 03:46:35+00', '2025-05-30 03:46:42+00',
   '2025-05-30 03:46:00+00', '2025-05-30 03:46:42+00'),

  -- INC-0005 (SSL cert) — low urgency, EMAIL only
  ('00000014-0001-0001-0001-000000000014', 'a1b2c3d4-0001-0001-0001-000000000001',
   '00000005-0001-0001-0001-000000000005', '00000009-0001-0001-0001-000000000009',
   '00000003-0001-0001-0001-000000000003',
   'EMAIL', 'DELIVERED',
   '[SEV3] INCIDENT: SSL Certificate Expiring in 14 Days — api.synthrex.io — Synthrex Ops',
   '<h2>SEV3 Incident — INC-0005</h2><p>SSL Certificate Expiring in 14 Days — api.synthrex.io (cert-manager DNS-01 failure)</p>',
   'linda.baxter@synthrex.io', 'ses_msg_ic0005_014', NULL, 0, 3, NULL,
   '2025-04-15 06:05:30+00', '2025-04-15 06:06:02+00',
   '2025-04-15 06:05:00+00', '2025-04-15 06:06:02+00');

