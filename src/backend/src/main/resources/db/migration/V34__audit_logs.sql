-- =============================================================================
-- DOMAIN 6: AUDIT & COMPLIANCE
-- =============================================================================

CREATE TABLE audit_logs (
    id                  UUID NOT NULL DEFAULT gen_random_uuid(),
    org_id              UUID NOT NULL,
    actor_user_id       UUID,
    actor_api_token_id  UUID,
    actor_ip            INET,
    action              audit_action NOT NULL,
    resource_type       VARCHAR(100) NOT NULL,
    resource_id         UUID,
    old_value           JSONB,
    new_value           JSONB,
    diff                JSONB,
    request_id          VARCHAR(100),
    occurred_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE audit_logs_2024_05 PARTITION OF audit_logs
    FOR VALUES FROM ('2024-05-01') TO ('2024-06-01');
CREATE TABLE audit_logs_2025_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE audit_logs_2025_02 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE audit_logs_2025_03 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');
CREATE TABLE audit_logs_2025_04 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');
CREATE TABLE audit_logs_2025_05 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-05-01') TO ('2025-06-01');
CREATE TABLE audit_logs_2025_06 PARTITION OF audit_logs
    FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

-- =============================================================================
-- DEFERRED FOREIGN KEYS
-- =============================================================================

ALTER TABLE alert_routing_rules
    ADD CONSTRAINT fk_routing_escalation_policy
    FOREIGN KEY (escalation_policy_id) REFERENCES escalation_policies(id);

ALTER TABLE incidents
    ADD CONSTRAINT fk_incident_escalation_policy
    FOREIGN KEY (escalation_policy_id) REFERENCES escalation_policies(id);

ALTER TABLE incident_escalations
    ADD CONSTRAINT fk_inc_esc_policy
    FOREIGN KEY (escalation_policy_id) REFERENCES escalation_policies(id);

ALTER TABLE incident_escalations
    ADD CONSTRAINT fk_inc_esc_step
    FOREIGN KEY (escalation_step_id) REFERENCES escalation_steps(id);

-- =============================================================================
-- INDEXES
-- =============================================================================

CREATE INDEX idx_users_org_id               ON users(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_email                ON users(email);
CREATE INDEX idx_teams_org_id               ON teams(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_team_memberships_user_id   ON team_memberships(user_id);
CREATE INDEX idx_team_memberships_team_id   ON team_memberships(team_id);
CREATE INDEX idx_api_tokens_org_id          ON api_tokens(org_id) WHERE revoked_at IS NULL;
CREATE INDEX idx_user_sessions_user_id      ON user_sessions(user_id) WHERE revoked_at IS NULL;

CREATE INDEX idx_alert_sources_org_id       ON alert_sources(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_alert_sources_int_key      ON alert_sources(integration_key);

CREATE INDEX idx_alerts_org_id              ON alerts(org_id, created_at DESC);
CREATE INDEX idx_alerts_dedup_key           ON alerts(org_id, dedup_key);
CREATE INDEX idx_alerts_state               ON alerts(org_id, state, created_at DESC);
CREATE INDEX idx_alerts_alert_source        ON alerts(alert_source_id, created_at DESC);
CREATE INDEX idx_alerts_alert_group         ON alerts(alert_group_id, created_at DESC);
CREATE INDEX idx_alerts_fingerprint         ON alerts(fingerprint);
CREATE INDEX idx_alerts_labels_gin          ON alerts USING GIN (labels);

CREATE INDEX idx_alert_groups_org_id        ON alert_groups(org_id);
CREATE INDEX idx_alert_groups_group_key     ON alert_groups(org_id, group_key);

CREATE INDEX idx_incidents_org_id           ON incidents(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_incidents_status           ON incidents(org_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_incidents_severity         ON incidents(org_id, severity) WHERE deleted_at IS NULL;
CREATE INDEX idx_incidents_team             ON incidents(team_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_incidents_triggered_at     ON incidents(org_id, triggered_at DESC);
CREATE INDEX idx_incidents_resolved_at      ON incidents(org_id, resolved_at DESC) WHERE resolved_at IS NOT NULL;
CREATE INDEX idx_incidents_title_trgm       ON incidents USING GIN (title gin_trgm_ops);

CREATE INDEX idx_inc_alert_links_incident   ON incident_alert_links(incident_id);
CREATE INDEX idx_inc_alert_links_alert      ON incident_alert_links(alert_id);
CREATE INDEX idx_inc_assignees_incident     ON incident_assignees(incident_id) WHERE unassigned_at IS NULL;
CREATE INDEX idx_inc_assignees_user         ON incident_assignees(user_id) WHERE unassigned_at IS NULL;
CREATE INDEX idx_inc_acks_incident          ON incident_acknowledgements(incident_id);
CREATE INDEX idx_inc_notes_incident         ON incident_notes(incident_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_inc_timeline_incident      ON incident_timeline_events(incident_id, occurred_at DESC);
CREATE INDEX idx_inc_escalations_incident   ON incident_escalations(incident_id);

CREATE INDEX idx_esc_policies_org           ON escalation_policies(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_esc_steps_policy           ON escalation_steps(escalation_policy_id);
CREATE INDEX idx_esc_step_targets_step      ON escalation_step_targets(escalation_step_id);
CREATE INDEX idx_on_call_schedules_org      ON on_call_schedules(org_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_on_call_rotations_sched    ON on_call_rotations(schedule_id);
CREATE INDEX idx_on_call_members_rotation   ON on_call_rotation_members(rotation_id);
CREATE INDEX idx_on_call_members_user       ON on_call_rotation_members(user_id);

CREATE INDEX idx_notif_logs_org             ON notification_logs(org_id, created_at DESC);
CREATE INDEX idx_notif_logs_incident        ON notification_logs(incident_id, created_at DESC);
CREATE INDEX idx_notif_logs_user            ON notification_logs(user_id, created_at DESC);
CREATE INDEX idx_notif_logs_status          ON notification_logs(status, next_retry_at) WHERE status = 'RETRYING';
CREATE INDEX idx_notif_delivery_log         ON notification_delivery_attempts(notification_log_id);

CREATE INDEX idx_audit_logs_org             ON audit_logs(org_id, occurred_at DESC);
CREATE INDEX idx_audit_logs_actor           ON audit_logs(actor_user_id, occurred_at DESC) WHERE actor_user_id IS NOT NULL;
CREATE INDEX idx_audit_logs_resource        ON audit_logs(resource_type, resource_id, occurred_at DESC);

-- =============================================================================
-- ANALYTICS VIEWS
-- =============================================================================

CREATE VIEW v_mttr_by_team AS
SELECT
    i.org_id,
    i.team_id,
    DATE_TRUNC('week', i.triggered_at)                                                          AS week,
    COUNT(*)                                                                                    AS incident_count,
    AVG(EXTRACT(EPOCH FROM (i.resolved_at - i.triggered_at)) / 60)::NUMERIC(10,2)              AS avg_mttr_minutes,
    PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (i.resolved_at - i.triggered_at)) / 60) AS p50_mttr_minutes,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (i.resolved_at - i.triggered_at)) / 60) AS p95_mttr_minutes
FROM incidents i
WHERE i.resolved_at IS NOT NULL AND i.deleted_at IS NULL
GROUP BY i.org_id, i.team_id, DATE_TRUNC('week', i.triggered_at);

CREATE VIEW v_mtta_by_team AS
SELECT
    i.org_id,
    i.team_id,
    DATE_TRUNC('week', i.triggered_at)                                                          AS week,
    COUNT(*)                                                                                    AS incident_count,
    AVG(EXTRACT(EPOCH FROM (i.acknowledged_at - i.triggered_at)) / 60)::NUMERIC(10,2)          AS avg_mtta_minutes
FROM incidents i
WHERE i.acknowledged_at IS NOT NULL AND i.deleted_at IS NULL
GROUP BY i.org_id, i.team_id, DATE_TRUNC('week', i.triggered_at);

CREATE VIEW v_notification_failure_rate AS
SELECT
    org_id,
    channel,
    DATE_TRUNC('day', created_at)                                                               AS day,
    COUNT(*)                                                                                    AS total_sent,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END)                                         AS failed,
    ROUND(SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(*), 0) * 100, 2) AS failure_rate_pct
FROM notification_logs
GROUP BY org_id, channel, DATE_TRUNC('day', created_at);

-- =============================================================================
-- HELPER FUNCTIONS & TRIGGERS
-- =============================================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_organizations_updated_at      BEFORE UPDATE ON organizations      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_users_updated_at              BEFORE UPDATE ON users              FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_teams_updated_at              BEFORE UPDATE ON teams              FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_incidents_updated_at          BEFORE UPDATE ON incidents          FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_alerts_updated_at             BEFORE UPDATE ON alerts             FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_alert_sources_updated_at      BEFORE UPDATE ON alert_sources      FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_escalation_policies_updated_at BEFORE UPDATE ON escalation_policies FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_notification_logs_updated_at  BEFORE UPDATE ON notification_logs  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION generate_incident_sequence_number(p_org_id UUID)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE
    v_seq BIGINT;
BEGIN
    SELECT COALESCE(MAX(sequence_number), 0) + 1 INTO v_seq FROM incidents WHERE org_id = p_org_id;
    RETURN v_seq;
END;
$$;

-- =============================================================================
-- SEED: DEFAULT PERMISSIONS
-- =============================================================================

INSERT INTO permissions (resource, action, description) VALUES
  ('incidents',  'read',   'View incidents'),
  ('incidents',  'write',  'Create and update incidents'),
  ('incidents',  'delete', 'Delete incidents'),
  ('incidents',  'admin',  'Manage incident settings'),
  ('alerts',     'read',   'View alerts'),
  ('alerts',     'write',  'Create and update alerts'),
  ('alerts',     'admin',  'Manage alert sources and routing'),
  ('escalations','read',   'View escalation policies'),
  ('escalations','write',  'Create and update escalation policies'),
  ('escalations','admin',  'Manage on-call schedules'),
  ('users',      'read',   'View users'),
  ('users',      'write',  'Invite and update users'),
  ('users',      'admin',  'Manage org-level user settings'),
  ('audit',      'read',   'View audit logs'),
  ('api_tokens', 'read',   'View API tokens'),
  ('api_tokens', 'write',  'Create and revoke API tokens')
ON CONFLICT (resource, action) DO NOTHING;

-- =============================================================================
-- SEED: AUDIT LOGS
-- =============================================================================

INSERT INTO audit_logs (id, org_id, actor_user_id, actor_api_token_id, actor_ip, action, resource_type, resource_id, old_value, new_value, diff, request_id, occurred_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL, '00000001-0001-0001-0001-000000000001', '10.0.0.50'::inet,
   'CREATE', 'incidents', '00000001-0001-0001-0001-000000000001',
   NULL,
   '{"id":"ic000001","severity":"SEV1","status":"TRIGGERED","title":"Payment Processor Pods OOMKilling — Production Kubernetes"}'::jsonb,
   NULL, 'req-a1b2c3d4-001', '2025-05-14 02:18:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003', NULL, '10.0.1.88'::inet,
   'UPDATE', 'incidents', '00000001-0001-0001-0001-000000000001',
   '{"status":"TRIGGERED"}'::jsonb,
   '{"status":"ACKNOWLEDGED","acknowledged_at":"2025-05-14T02:24:00Z"}'::jsonb,
   '{"status":{"old":"TRIGGERED","new":"ACKNOWLEDGED"},"acknowledged_at":{"old":null,"new":"2025-05-14T02:24:00Z"}}'::jsonb,
   'req-a1b2c3d4-002', '2025-05-14 02:24:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003', NULL, '10.0.1.88'::inet,
   'UPDATE', 'incidents', '00000001-0001-0001-0001-000000000001',
   '{"status":"ACKNOWLEDGED"}'::jsonb,
   '{"status":"INVESTIGATING"}'::jsonb,
   '{"status":{"old":"ACKNOWLEDGED","new":"INVESTIGATING"}}'::jsonb,
   'req-a1b2c3d4-003', '2025-05-14 02:35:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000003-0001-0001-0001-000000000003', NULL, '10.0.1.88'::inet,
   'UPDATE', 'incidents', '00000001-0001-0001-0001-000000000001',
   '{"status":"MONITORING"}'::jsonb,
   '{"status":"RESOLVED","resolved_at":"2025-05-14T04:05:00Z","resolution_summary":"Rolled back to v2.7.9. Memory stable."}'::jsonb,
   '{"status":{"old":"MONITORING","new":"RESOLVED"},"resolved_at":{"old":null,"new":"2025-05-14T04:05:00Z"}}'::jsonb,
   'req-a1b2c3d4-004', '2025-05-14 04:05:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', NULL, '10.0.1.22'::inet,
   'UPDATE', 'incidents', '00000001-0001-0001-0001-000000000001',
   '{"status":"RESOLVED"}'::jsonb,
   '{"status":"CLOSED","closed_at":"2025-05-14T05:30:00Z","postmortem_url":"https://www.notion.so/synthrex/INC-0001-Postmortem-Payment-OOM-a1b2c3d4"}'::jsonb,
   '{"status":{"old":"RESOLVED","new":"CLOSED"},"postmortem_url":{"old":null,"new":"https://www.notion.so/synthrex/INC-0001-Postmortem-Payment-OOM-a1b2c3d4"}}'::jsonb,
   'req-a1b2c3d4-005', '2025-05-14 05:30:00+00'),

  ('00000006-0001-0001-0001-000000000006',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL, '00000001-0001-0001-0001-000000000001', '35.180.88.245'::inet,
   'API_ACCESS', 'alerts', NULL,
   NULL, NULL, NULL,
   'req-a1b2c3d4-006', '2025-05-14 02:17:00+00'),

  ('00000007-0001-0001-0001-000000000007',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL, '00000001-0001-0001-0001-000000000001', '10.0.0.50'::inet,
   'CREATE', 'incidents', '00000004-0001-0001-0001-000000000004',
   NULL,
   '{"id":"ic000004","severity":"SEV1","status":"TRIGGERED","title":"PostgreSQL Connection Pool Exhausted"}'::jsonb,
   NULL, 'req-a1b2c3d4-007', '2025-06-03 22:07:00+00'),

  ('00000008-0001-0001-0001-000000000008',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002', NULL, '10.0.2.55'::inet,
   'UPDATE', 'incidents', '00000004-0001-0001-0001-000000000004',
   '{"status":"TRIGGERED"}'::jsonb,
   '{"status":"ACKNOWLEDGED","acknowledged_at":"2025-06-03T22:11:00Z"}'::jsonb,
   '{"status":{"old":"TRIGGERED","new":"ACKNOWLEDGED"}}'::jsonb,
   'req-a1b2c3d4-008', '2025-06-03 22:11:00+00'),

  ('00000009-0001-0001-0001-000000000009',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL, NULL, '10.0.0.60'::inet,
   'CREATE', 'incident_escalations', '00000003-0001-0001-0001-000000000003',
   NULL,
   '{"incident_id":"ic000004","step":2,"policy":"Platform SRE — Default","notified_user_ids":["u0000002","u0000004"]}'::jsonb,
   NULL, 'req-a1b2c3d4-009', '2025-06-03 22:26:00+00'),

  ('00000010-0001-0001-0001-000000000010',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', NULL, '10.0.1.22'::inet,
   'UPDATE', 'api_tokens', '00000009-0001-0001-0001-000000000009',
   '{"revoked_at":null}'::jsonb,
   '{"revoked_at":"2025-03-15T09:00:00Z","name":"Deprecated Runbook Script — Marcus"}'::jsonb,
   '{"revoked_at":{"old":null,"new":"2025-03-15T09:00:00Z"}}'::jsonb,
   'req-a1b2c3d4-010', '2025-03-15 09:00:00+00'),

  ('00000011-0001-0001-0001-000000000011',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002', NULL, '10.0.1.45'::inet,
   'LOGIN', 'users', '00000002-0001-0001-0001-000000000002',
   NULL,
   '{"last_login_at":"2025-06-04T09:45:00Z","ip":"10.0.1.45","user_agent":"Mozilla/5.0 Chrome/124.0"}'::jsonb,
   NULL, 'req-a1b2c3d4-011', '2025-06-04 09:45:00+00'),

  ('00000012-0001-0001-0001-000000000012',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', NULL, '10.0.1.22'::inet,
   'CONFIG_CHANGE', 'escalation_policies', '00000002-0001-0001-0001-000000000002',
   '{"repeat_count":1,"repeat_delay_minutes":30}'::jsonb,
   '{"repeat_count":3,"repeat_delay_minutes":15}'::jsonb,
   '{"repeat_count":{"old":1,"new":3},"repeat_delay_minutes":{"old":30,"new":15}}'::jsonb,
   'req-a1b2c3d4-012', '2025-02-15 11:00:00+00'),

  ('00000013-0002-0002-0002-000000000013',
   'b2c3d4e5-0002-0002-0002-000000000002',
   NULL, '00000006-0002-0002-0002-000000000006', '52.94.76.100'::inet,
   'CREATE', 'incidents', '00000006-0002-0002-0002-000000000006',
   NULL,
   '{"id":"ic000006","severity":"SEV2","status":"TRIGGERED","title":"Redis Cache Memory Pressure — redis-cache-001"}'::jsonb,
   NULL, 'req-b2c3d4e5-013', '2025-05-28 14:25:00+00'),

  ('00000014-0002-0002-0002-000000000014',
   'b2c3d4e5-0002-0002-0002-000000000002',
   '00000012-0002-0002-0002-000000000012', NULL, '192.168.1.9'::inet,
   'UPDATE', 'incidents', '00000006-0002-0002-0002-000000000006',
   '{"status":"MONITORING"}'::jsonb,
   '{"status":"RESOLVED","resolved_at":"2025-05-28T17:10:00Z"}'::jsonb,
   '{"status":{"old":"MONITORING","new":"RESOLVED"}}'::jsonb,
   'req-b2c3d4e5-014', '2025-05-28 17:10:00+00'),

  ('00000015-0003-0003-0003-000000000015',
   'c3d4e5f6-0003-0003-0003-000000000003',
   NULL, '00000008-0003-0003-0003-000000000008', '185.207.49.3'::inet,
   'CREATE', 'incidents', '00000008-0003-0003-0003-000000000008',
   NULL,
   '{"id":"ic000008","severity":"SEV1","status":"TRIGGERED","title":"API Service Down — api.nimbly.io returning HTTP 502"}'::jsonb,
   NULL, 'req-c3d4e5f6-015', '2025-05-30 03:46:00+00'),

  ('00000016-0003-0003-0003-000000000016',
   'c3d4e5f6-0003-0003-0003-000000000003',
   '00000017-0003-0003-0003-000000000017', NULL, '82.45.12.201'::inet,
   'UPDATE', 'incidents', '00000008-0003-0003-0003-000000000008',
   '{"status":"IDENTIFIED"}'::jsonb,
   '{"status":"RESOLVED","resolved_at":"2025-05-30T04:40:00Z"}'::jsonb,
   '{"status":{"old":"IDENTIFIED","new":"RESOLVED"}}'::jsonb,
   'req-c3d4e5f6-016', '2025-05-30 04:40:00+00'),

  ('00000017-0001-0001-0001-000000000017',
   'a1b2c3d4-0001-0001-0001-000000000001',
   NULL, '00000004-0001-0001-0001-000000000004', '10.0.0.50'::inet,
   'CREATE', 'incidents', '00000010-0001-0001-0001-000000000010',
   NULL,
   '{"id":"ic000010","severity":"SEV1","status":"TRIGGERED","title":"Stripe Integration Error Rate 31%"}'::jsonb,
   NULL, 'req-a1b2c3d4-017', '2025-06-04 10:23:00+00'),

  ('00000018-0001-0001-0001-000000000018',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', NULL, '10.0.1.22'::inet,
   'PERMISSION_CHANGE', 'users', '00000009-0001-0001-0001-000000000009',
   '{"roles":["Responder"]}'::jsonb,
   '{"roles":["SecOps Auditor"]}'::jsonb,
   '{"roles":{"old":["Responder"],"new":["SecOps Auditor"]}}'::jsonb,
   'req-a1b2c3d4-018', '2024-05-20 13:05:00+00'),

  ('00000019-0001-0001-0001-000000000019',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000002-0001-0001-0001-000000000002', NULL, '10.0.1.45'::inet,
   'CONFIG_CHANGE', 'alert_routing_rules', NULL,
   NULL,
   '{"name":"Critical Payments Route","priority":1,"conditions":{"severity":["critical"],"labels":{"team":"payments"}}}'::jsonb,
   NULL, 'req-a1b2c3d4-019', '2025-01-15 10:00:00+00'),

  ('00000020-0001-0001-0001-000000000020',
   'a1b2c3d4-0001-0001-0001-000000000001',
   '00000001-0001-0001-0001-000000000001', NULL, '10.0.1.22'::inet,
   'UPDATE', 'incidents', '00000003-0001-0001-0001-000000000003',
   '{"slo_breach":false}'::jsonb,
   '{"slo_breach":true}'::jsonb,
   '{"slo_breach":{"old":false,"new":true}}'::jsonb,
   'req-a1b2c3d4-020', '2025-06-01 13:00:00+00');