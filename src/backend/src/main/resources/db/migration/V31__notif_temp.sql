
-- =============================================================================
-- DOMAIN 5: NOTIFICATION SYSTEM
-- =============================================================================

-- ---------------------------------------------------------------------------
-- notification_templates
-- ---------------------------------------------------------------------------
CREATE TABLE notification_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id          UUID NOT NULL REFERENCES organizations(id),
    name            VARCHAR(255) NOT NULL,
    channel         notification_channel NOT NULL,
    event_type      VARCHAR(100) NOT NULL,  -- incident.triggered, incident.resolved…
    subject_template TEXT,                  -- for EMAIL
    body_template   TEXT NOT NULL,          -- Mustache / Handlebars
    is_default      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ,
    UNIQUE (org_id, name, channel)
);



-- =============================================================================
-- SECTION 25: NOTIFICATION TEMPLATES
-- =============================================================================

INSERT INTO notification_templates (id, org_id, name, channel, event_type, subject_template, body_template, is_default, created_at, updated_at) VALUES

  ('00000001-0001-0001-0001-000000000001',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'SEV1 Incident Triggered — Slack',
   'SLACK', 'incident.triggered',
   NULL,
   ':rotating_light: *[{{severity}}] {{title}}*\n\n*Incident:* <{{incident_url}}|INC-{{sequence_number}}>\n*Team:* {{team_name}}\n*Triggered:* {{triggered_at}}\n\n{{description}}\n\n*Runbook:* {{runbook_url | default: "Not specified"}}\n\n<{{incident_url}}|Acknowledge> | <{{slack_channel_url}}|Join Channel>',
   TRUE, '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000002-0001-0001-0001-000000000002',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'SEV1 Incident Triggered — SMS',
   'SMS', 'incident.triggered',
   NULL,
   '[Synthrex {{severity}}] {{title}} — INC-{{sequence_number}} ack: {{ack_url}}',
   TRUE, '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000003-0001-0001-0001-000000000003',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Incident Triggered — Email',
   'EMAIL', 'incident.triggered',
   '[{{severity}}] INCIDENT: {{title}} — Synthrex Ops',
   '<h2>{{severity}} Incident — INC-{{sequence_number}}</h2><p><strong>{{title}}</strong></p><p>{{description}}</p><p><strong>Team:</strong> {{team_name}}<br><strong>Triggered:</strong> {{triggered_at}}</p><p><a href="{{incident_url}}">View & Acknowledge Incident</a></p>',
   TRUE, '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000004-0001-0001-0001-000000000004',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Incident Resolved — Slack',
   'SLACK', 'incident.resolved',
   NULL,
   ':white_check_mark: *Resolved: [{{severity}}] {{title}}*\n\n*INC-{{sequence_number}}* resolved by {{resolved_by}}\n*MTTR:* {{mttr_minutes}} minutes\n*Postmortem:* {{postmortem_url | default: "Pending"}}\n\n{{resolution_summary}}',
   TRUE, '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000005-0001-0001-0001-000000000005',
   'a1b2c3d4-0001-0001-0001-000000000001',
   'Escalation Notification — Slack',
   'SLACK', 'incident.escalated',
   NULL,
   ':escalation: *Escalation — INC-{{sequence_number}} (Step {{step_number}})*\n\n{{title}}\n\nNo acknowledgement received after {{delay_minutes}} minutes. Paging: {{notified_names}}\n\n<{{incident_url}}|Acknowledge Now>',
   TRUE, '2023-04-12 10:00:00+00', '2025-01-10 09:00:00+00'),

  ('00000006-0002-0002-0002-000000000006',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Incident Triggered — Slack',
   'SLACK', 'incident.triggered',
   NULL,
   ':alert: *[{{severity}}] {{title}}*\n\nINC-{{sequence_number}} | Team: {{team_name}} | <{{incident_url}}|Respond>',
   TRUE, '2024-01-20 10:00:00+00', '2024-09-01 10:00:00+00'),

  ('00000007-0002-0002-0002-000000000007',
   'b2c3d4e5-0002-0002-0002-000000000002',
   'Incident Triggered — Email',
   'EMAIL', 'incident.triggered',
   '[ALERT] {{severity}}: {{title}}',
   '<p>{{severity}} incident triggered for team {{team_name}}.</p><p>{{description}}</p><p><a href="{{incident_url}}">View Incident INC-{{sequence_number}}</a></p>',
   TRUE, '2024-01-20 10:00:00+00', '2024-09-01 10:00:00+00'),

  ('00000008-0003-0003-0003-000000000008',
   'c3d4e5f6-0003-0003-0003-000000000003',
   'Incident Triggered — Email',
   'EMAIL', 'incident.triggered',
   '[{{severity}}] {{title}} — Nimbly Alert',
   '<p>An incident has been triggered. Please respond immediately.</p><p>{{title}}</p><p>{{description}}</p><p><a href="{{incident_url}}">View Incident</a></p>',
   TRUE, '2025-03-02 09:00:00+00', '2025-03-02 09:00:00+00');

