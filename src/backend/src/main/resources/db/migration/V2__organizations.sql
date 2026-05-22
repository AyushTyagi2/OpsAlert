-- ---------------------------------------------------------------------------
-- organizations  (root tenant)
-- ---------------------------------------------------------------------------
-- Each org is an isolated tenant. All operational data has org_id.
-- Billing, feature flags, and settings live here.
CREATE TABLE organizations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug                VARCHAR(100) NOT NULL UNIQUE,          -- URL-safe identifier
    name                VARCHAR(255) NOT NULL,
    plan                VARCHAR(50)  NOT NULL DEFAULT 'free',  -- free / pro / enterprise
    timezone            VARCHAR(100) NOT NULL DEFAULT 'UTC',
    settings            JSONB        NOT NULL DEFAULT '{}',    -- feature flags, integrations
    trial_ends_at       TIMESTAMPTZ,
    suspended_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- =============================================================================
-- SECTION 1: ORGANIZATIONS
-- =============================================================================

INSERT INTO organizations (id, slug, name, plan, timezone, settings, trial_ends_at, created_at, updated_at) VALUES

  ('a1b2c3d4-0001-0001-0001-000000000001',
   'synthrex',
   'Synthrex Financial Technologies',
   'enterprise',
   'America/New_York',
   '{
     "features": {
       "ai_grouping": true,
       "multi_responder": true,
       "postmortem_templates": true,
       "slo_tracking": true,
       "runbooks": true,
       "analytics_v2": true
     },
     "integrations": {
       "slack_workspace_id": "T04XK8ZQPAB",
       "pagerduty_sync": false,
       "jira_project_key": "OPS",
       "datadog_org_id": "synthrex-prod"
     },
     "notification_defaults": {
       "high_urgency_channels": ["SLACK", "SMS", "EMAIL"],
       "low_urgency_channels": ["EMAIL"],
       "quiet_hours_enabled": false
     },
     "slo": {
       "sev1_ack_target_minutes": 5,
       "sev2_ack_target_minutes": 15,
       "sev1_resolve_target_minutes": 60,
       "sev2_resolve_target_minutes": 240
     }
   }'::jsonb,
   NULL,
   '2023-04-12 09:00:00+00',
   '2025-06-01 10:00:00+00'),

  ('b2c3d4e5-0002-0002-0002-000000000002',
   'cloudnova',
   'Cloudnova Systems',
   'pro',
   'America/Los_Angeles',
   '{
     "features": {
       "ai_grouping": true,
       "multi_responder": false,
       "postmortem_templates": true,
       "slo_tracking": false,
       "runbooks": true,
       "analytics_v2": false
     },
     "integrations": {
       "slack_workspace_id": "T07RRPLQ8NB",
       "jira_project_key": "INFRA",
       "datadog_org_id": "cloudnova-us"
     },
     "notification_defaults": {
       "high_urgency_channels": ["SLACK", "EMAIL"],
       "low_urgency_channels": ["EMAIL"],
       "quiet_hours_enabled": true,
       "quiet_hours_start": "22:00",
       "quiet_hours_end": "07:00"
     }
   }'::jsonb,
   NULL,
   '2024-01-08 14:30:00+00',
   '2025-05-15 08:22:00+00'),

  ('c3d4e5f6-0003-0003-0003-000000000003',
   'nimbly',
   'Nimbly Technologies',
   'pro',
   'Europe/London',
   '{
     "features": {
       "ai_grouping": false,
       "multi_responder": false,
       "postmortem_templates": false,
       "slo_tracking": false,
       "runbooks": false,
       "analytics_v2": false
     },
     "integrations": {
       "slack_workspace_id": "T09QQML7ZKC"
     },
     "notification_defaults": {
       "high_urgency_channels": ["EMAIL", "SLACK"],
       "low_urgency_channels": ["EMAIL"],
       "quiet_hours_enabled": false
     }
   }'::jsonb,
   '2025-09-01 00:00:00+00',
   '2025-03-01 11:00:00+00',
   '2025-06-01 11:00:00+00');
