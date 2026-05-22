-- ---------------------------------------------------------------------------
-- permissions  (global capability catalog)
-- ---------------------------------------------------------------------------
CREATE TABLE permissions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource            VARCHAR(100) NOT NULL,  -- incidents, alerts, escalations…
    action              VARCHAR(50)  NOT NULL,  -- read, write, delete, admin
    description         TEXT,
    UNIQUE (resource, action)
);