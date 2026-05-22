-- ---------------------------------------------------------------------------
-- notification_delivery_attempts  (per-retry granularity)
-- ---------------------------------------------------------------------------
CREATE TABLE notification_delivery_attempts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_log_id UUID NOT NULL,       -- no FK to partitioned parent
    attempt_number      SMALLINT NOT NULL,
    status              notification_status NOT NULL,
    response_code       INTEGER,             -- HTTP status or SMTP code
    response_body       TEXT,
    provider_request_id TEXT,
    attempted_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);



-- =============================================================================
-- SECTION 27: NOTIFICATION DELIVERY ATTEMPTS
-- =============================================================================

INSERT INTO notification_delivery_attempts (id, notification_log_id, attempt_number, status, response_code, response_body, provider_request_id, attempted_at) VALUES

  -- nl000001 (SLACK, delivered first attempt)
  ('00000001-0001-0001-0001-000000000001', '00000001-0001-0001-0001-000000000001',
   1, 'DELIVERED', 200, '{"ok":true,"ts":"1715648311.123456","channel":"C06PAYMENTS-INC-001"}',
   'req_slack_da001', '2025-05-14 02:18:30+00'),

  -- nl000002 (SMS, delivered first attempt)
  ('00000002-0001-0001-0001-000000000002', '00000002-0001-0001-0001-000000000002',
   1, 'DELIVERED', 201, '{"sid":"SM_twilio_ic0001_002","status":"delivered","error_code":null}',
   'req_twilio_da002', '2025-05-14 02:18:45+00'),

  -- nl000006 (SMS escalation, 1 retry needed)
  ('00000003-0001-0001-0001-000000000003', '00000006-0001-0001-0001-000000000006',
   1, 'FAILED', 503, '{"code":503,"message":"Twilio API temporarily unavailable"}',
   'req_twilio_da003_fail', '2025-06-03 22:26:30+00'),

  ('00000004-0001-0001-0001-000000000004', '00000006-0001-0001-0001-000000000006',
   2, 'DELIVERED', 201, '{"sid":"SM_twilio_ic0004_006","status":"delivered","error_code":null}',
   'req_twilio_da004', '2025-06-03 22:27:30+00'),

  -- nl000008 (SMS for Stripe SEV1, RETRYING — 2 failed attempts so far)
  ('00000005-0001-0001-0001-000000000005', '00000008-0001-0001-0001-000000000008',
   1, 'FAILED', 400, '{"code":21408,"message":"Permission to send an SMS has not been enabled for the region indicated by the To number"}',
   'req_twilio_da005_fail1', '2025-06-04 10:23:45+00'),

  ('00000006-0001-0001-0001-000000000006', '00000008-0001-0001-0001-000000000008',
   2, 'FAILED', 400, '{"code":21408,"message":"Permission to send an SMS has not been enabled for the region indicated by the To number"}',
   'req_twilio_da006_fail2', '2025-06-04 10:25:45+00'),

  -- nl000009 (WEBHOOK FAILED — 3 attempts exhausted)
  ('00000007-0001-0001-0001-000000000007', '00000009-0001-0001-0001-000000000009',
   1, 'FAILED', 410, '{"error":"Gone","message":"Hook has been deactivated"}',
   'req_webhook_da007_fail1', '2025-06-04 10:38:30+00'),

  ('00000008-0001-0001-0001-000000000008', '00000009-0001-0001-0001-000000000009',
   2, 'FAILED', 410, '{"error":"Gone","message":"Hook has been deactivated"}',
   'req_webhook_da008_fail2', '2025-06-04 10:40:30+00'),

  ('00000009-0001-0001-0001-000000000009', '00000009-0001-0001-0001-000000000009',
   3, 'FAILED', 410, '{"error":"Gone","message":"Hook has been deactivated"}',
   'req_webhook_da009_fail3', '2025-06-04 10:42:30+00'),

  -- nl000010 (Cloudnova Slack, delivered)
  ('00000010-0002-0002-0002-000000000010', '00000010-0002-0002-0002-000000000010',
   1, 'DELIVERED', 200, '{"ok":true,"ts":"1748439931.567890","channel":"C05INFRA-INC-001"}',
   'req_slack_da010', '2025-05-28 14:25:30+00'),

  -- nl000013 (Nimbly SMS, delivered)
  ('00000011-0003-0003-0003-000000000011', '00000013-0003-0003-0003-000000000013',
   1, 'DELIVERED', 201, '{"sid":"SM_twilio_ic0008_013","status":"delivered","error_code":null}',
   'req_twilio_da011', '2025-05-30 03:46:35+00'),

  -- nl000014 (SSL cert, email, delivered)
  ('00000012-0001-0001-0001-000000000012', '00000014-0001-0001-0001-000000000014',
   1, 'DELIVERED', 200, '{"MessageId":"ses_msg_ic0005_014","ResponseMetadata":{"HTTPStatusCode":200}}',
   'req_ses_da012', '2025-04-15 06:05:30+00');

