-- ---------------------------------------------------------------------------
-- incident_notes  (soft-deleted, versioned via timeline events)
-- ---------------------------------------------------------------------------
CREATE TABLE incident_notes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id     UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id),
    body            TEXT NOT NULL,
    is_internal     BOOLEAN NOT NULL DEFAULT FALSE,  -- internal = not in postmortem export
    pinned          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);


-- =============================================================================
-- SECTION 22: INCIDENT NOTES
-- =============================================================================

INSERT INTO incident_notes (id, incident_id, user_id, body, is_internal, pinned, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', '00000003-0001-0001-0001-000000000003',
   'Confirmed: payment-processor pods are OOMKilling. Memory usage climbed to 512Mi limit before crash. Checking heap dump from last pod restart. Initial hypothesis: idempotency key cache is unbounded.',
   TRUE, TRUE, '2025-05-14 02:35:00+00', '2025-05-14 02:35:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   '00000001-0001-0001-0001-000000000001', '00000007-0001-0001-0001-000000000007',
   'Heap dump analysis confirms it: HashMap<String, IdempotencyEntry> is holding 2.1M entries. No eviction policy. TTL was removed in PR #4821. Rolling back to v2.7.9 now.',
   TRUE, FALSE, '2025-05-14 03:10:00+00', '2025-05-14 03:10:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   '00000001-0001-0001-0001-000000000001', '00000003-0001-0001-0001-000000000003',
   'v2.7.9 rollback complete. All 6 pods are Running and Ready. Payment error rate dropped from 34% to 0.1% (within SLO). Keeping close watch for 30 minutes before resolving.',
   FALSE, FALSE, '2025-05-14 03:48:00+00', '2025-05-14 03:48:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   '00000002-0001-0001-0001-000000000002', '00000006-0001-0001-0001-000000000006',
   'Consumer group lag at 1,247,832 messages. Increased partition count from 12 to 48 and deployed 4 additional consumer instances. Consumption rate now at 38k msg/s (up from 180 msg/s).',
   TRUE, TRUE, '2025-05-20 19:15:00+00', '2025-05-20 19:15:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   '00000003-0001-0001-0001-000000000003', '00000003-0001-0001-0001-000000000003',
   'EXPLAIN ANALYZE on slow query: Seq Scan on transactions (cost=0.00..2847291.00 rows=890M). Missing index on idempotency_key. Migration V47 created the column but the index migration script was split into a separate PR that was never merged. Running CREATE INDEX CONCURRENTLY now — estimated 18 minutes.',
   TRUE, TRUE, '2025-06-01 10:35:00+00', '2025-06-01 10:35:00+00'),

  ('00000006-0001-0001-0001-000000000006',
   '00000004-0001-0001-0001-000000000004', '00000002-0001-0001-0001-000000000002',
   'pgbouncer showing 87 clients waiting. payment-api logs show "remaining connection slots are reserved for non-replication superuser connections". Checking pg_stat_activity for long-running transactions or unclosed connections.',
   TRUE, FALSE, '2025-06-03 22:18:00+00', '2025-06-03 22:18:00+00'),

  ('00000007-0001-0001-0001-000000000007',
   '00000004-0001-0001-0001-000000000004', '00000004-0001-0001-0001-000000000004',
   'Found it: payment-api v4.2.1 deployed 40 minutes ago has a bug in the database connection factory — Spring DataSource is not returning connections to the pool on validation exception. 211 idle connections from payment-api pods. Initiating rollback to v4.2.0.',
   TRUE, TRUE, '2025-06-03 22:42:00+00', '2025-06-03 22:42:00+00'),

  ('00000008-0002-0002-0002-000000000008',
   '00000006-0002-0002-0002-000000000006', '00000012-0002-0002-0002-000000000012',
   'Cache eviction rate: 8,240 keys/min. Hit rate dropped to 61% from 92%. Inspecting key distribution — user:prefs:* namespace is consuming 6.1GB, 38% of total. The new preference caching feature (FF-2024-0892) is storing full preference objects without TTL.',
   TRUE, TRUE, '2025-05-28 15:05:00+00', '2025-05-28 15:05:00+00'),

  ('00000009-0001-0001-0001-000000000009',
   '00000009-0001-0001-0001-000000000009', '00000003-0001-0001-0001-000000000003',
   'payment-gateway-svc v3.14.2 pod logs: "FATAL: Environment variable STRIPE_WEBHOOK_SECRET_V2 not found". This variable was added to the deployment manifest in PR #5102 but the Kubernetes secret was not created in production. Rollback to v3.14.1 in progress.',
   TRUE, TRUE, '2025-06-04 09:02:00+00', '2025-06-04 09:02:00+00'),

  ('00000010-0001-0001-0001-000000000010',
   '00000010-0001-0001-0001-000000000010', '00000003-0001-0001-0001-000000000003',
   'Stripe status page: https://status.stripe.com — "We are investigating increased error rates for charge and PaymentIntent APIs in the us-east-1 region." Error codes: card_error:402 (insufficient funds proxy), rate_limit:429. Evaluating Braintree fallback. Contacting Stripe support (ticket #SR-2025-06041022).',
   FALSE, TRUE, '2025-06-04 10:32:00+00', '2025-06-04 10:32:00+00');


