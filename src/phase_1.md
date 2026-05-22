Here are the Phase 1 (MVP) features extracted from this project:

🔐 1. Authentication & RBAC

User registration & login with JWT
Role-based access control (admin, engineer, viewer, etc.)
Team management
Spring Security integration


🚨 2. Alert Engine

REST endpoint to receive external alerts (POST /alerts/webhook)
Alert ingestion & validation pipeline
Ability to receive alerts from monitoring tools (Datadog, custom systems, etc.)


🔥 3. Incident Management (Core)

Auto-create incident from incoming alert
Assign severity level to incidents
Incident state machine with transitions:

Triggered → Acknowledged → Investigating → Resolved → Closed


Acknowledge incident (by on-call engineer)
Resolve & close incident
Full incident details view


⏫ 4. Escalation Engine

Auto-escalate if no one acknowledges within a time window (e.g. 5 minutes)
Scheduled/async background jobs
Retry logic for failed notifications


📬 5. Notification Service

Email notifications to on-call engineer on incident creation
Notify on escalation
Basic Slack/Discord webhook notifications (stretch for Phase 1)


📊 6. Dashboard & Analytics

Login page
Incident dashboard — list of all active/recent incidents
Incident details page — timeline, status, assigned engineer
Alerts table — raw incoming alerts
Analytics cards — open incidents, MTTR, escalation count, resolution rate


📋 7. Audit Logging

Log every action (created, acknowledged, escalated, resolved)
Append-only audit trail per incident
Timestamps & actor tracking for traceability

