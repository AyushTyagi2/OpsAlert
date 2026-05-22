-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";      -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pg_trgm";       -- fuzzy search on titles
CREATE EXTENSION IF NOT EXISTS "btree_gist";    -- GiST indexes for exclusion


-- ---------------------------------------------------------------------------
-- Custom types / enums
-- ---------------------------------------------------------------------------

CREATE TYPE severity_level AS ENUM (
    'SEV1',   -- Critical / service down
    'SEV2',   -- High / major degradation
    'SEV3',   -- Medium / partial impact
    'SEV4',   -- Low / minor issue
    'SEV5'    -- Informational
);

CREATE TYPE incident_status AS ENUM (
    'TRIGGERED',
    'ACKNOWLEDGED',
    'INVESTIGATING',
    'IDENTIFIED',
    'MONITORING',
    'RESOLVED',
    'CLOSED'
);

CREATE TYPE alert_state AS ENUM (
    'FIRING',
    'RESOLVED',
    'SILENCED',
    'SUPPRESSED',
    'DEDUPLICATED'
);

CREATE TYPE notification_channel AS ENUM (
    'EMAIL',
    'SLACK',
    'WEBHOOK',
    'SMS',
    'PAGERDUTY',
    'MICROSOFT_TEAMS',
    'OPSGENIE'
);

CREATE TYPE notification_status AS ENUM (
    'PENDING',
    'SENT',
    'DELIVERED',
    'FAILED',
    'RETRYING',
    'SUPPRESSED'
);

CREATE TYPE escalation_target_type AS ENUM (
    'USER',
    'TEAM',
    'SCHEDULE',
    'WEBHOOK'
);

CREATE TYPE timeline_event_type AS ENUM (
    'INCIDENT_CREATED',
    'STATUS_CHANGED',
    'SEVERITY_CHANGED',
    'ACKNOWLEDGED',
    'UNACKNOWLEDGED',
    'ASSIGNED',
    'UNASSIGNED',
    'NOTE_ADDED',
    'ALERT_LINKED',
    'ALERT_UNLINKED',
    'ESCALATED',
    'ESCALATION_POLICY_CHANGED',
    'RESOLVED',
    'REOPENED',
    'CLOSED',
    'CUSTOM'
);

CREATE TYPE rotation_type AS ENUM (
    'DAILY',
    'WEEKLY',
    'CUSTOM'
);

CREATE TYPE audit_action AS ENUM (
    'CREATE',
    'UPDATE',
    'DELETE',
    'LOGIN',
    'LOGOUT',
    'API_ACCESS',
    'PERMISSION_CHANGE',
    'CONFIG_CHANGE'
);