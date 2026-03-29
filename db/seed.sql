-- ============================================================================
-- AI Model Registry — Database Schema & Seed Data
-- ============================================================================

-- Users (mock authentication — pre-seeded)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Providers (pre-seeded: the big three)
CREATE TABLE providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) UNIQUE NOT NULL,
  website VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Models — tracks every AI model the team evaluates or deploys
CREATE TABLE models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  model_id VARCHAR(255) NOT NULL,
  provider_id UUID NOT NULL,
  context_window INTEGER,
  status VARCHAR(20) NOT NULL DEFAULT 'evaluating'
    CHECK (status IN ('evaluating', 'approved', 'deprecated')),
  notes TEXT,
  added_by UUID NOT NULL,
  CONSTRAINT fk_models_provider_id FOREIGN KEY (provider_id)
    REFERENCES providers(id) ON DELETE CASCADE,
  CONSTRAINT fk_models_added_by FOREIGN KEY (added_by)
    REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_models_provider_id ON models(provider_id);
CREATE INDEX idx_models_added_by ON models(added_by);
CREATE INDEX idx_models_status ON models(status);


-- ============================================================================
-- CHALLENGE TASK 1: Create the deployments table
-- ============================================================================
--
-- The team needs to track which models are deployed to which environments.
--
-- Requirements:
--   1. Each deployment has: id (UUID, PK), model_id, environment, deployed_by,
--      deployed_at, status, notes, created_at
--   2. environment must be one of: 'development', 'staging', 'production'
--   3. status must be one of: 'active', 'inactive', 'failed'
--   4. A model can only be deployed ONCE per environment
--      (hint: unique constraint on the right columns)
--   5. Deployments reference the models table — if a model is deleted,
--      its deployments should also be deleted
--   6. Deployments reference the users table (deployed_by) — if a user is
--      deleted, their deployments should also be deleted
--   7. Add indexes on columns used for lookups
--
-- ALSO: Populate the models table with at least 3 current AI models from any
-- of the providers below. Use real, current model identifiers as they appear
-- in each provider's API documentation (e.g. 'claude-sonnet-4-6', not
-- made-up strings).
--
-- Study the existing tables above for naming conventions and patterns.
--
-- DO NOT use AI tools. Your screen recording will be reviewed.
-- ============================================================================

-- YOUR SQL GOES BELOW THIS LINE

CREATE TABLE deployments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL,
  environment VARCHAR(20) NOT NULL
    CHECK (environment IN ('development', 'staging', 'production')),
    deployed_by UUID NOT NULL,
  deployed_at TIMESTAMPTZ DEFAULT NOW(),
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'failed')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_deployments_model_id FOREIGN KEY (model_id)
    REFERENCES models(id) ON DELETE CASCADE,
    CONSTRAINT fk_deployments_deployed_by FOREIGN KEY (deployed_by)
    REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_model_environment UNIQUE (model_id, environment)
);

CREATE INDEX idx_deployments_model_id ON deployments(model_id);
CREATE INDEX idx_deployments_deployed_by ON deployments(deployed_by);



-- ============================================================================
-- Seed Data
-- ============================================================================

INSERT INTO users (id, email, name) VALUES
  ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'alice@owntheclimb.com', 'Alice Chen'),
  ('b2c3d4e5-f6a7-8901-bcde-f12345678901', 'bob@owntheclimb.com', 'Bob Martinez');

INSERT INTO providers (id, name, website) VALUES
  ('c3d4e5f6-a7b8-9012-cdef-123456789012', 'Anthropic', 'https://anthropic.com'),
  ('d4e5f6a7-b8c9-0123-defa-234567890123', 'OpenAI', 'https://openai.com'),
  ('e5f6a7b8-c9d0-1234-efab-345678901234', 'Google', 'https://ai.google');

  INSERT INTO models (id, name, model_id, provider_id, context_window, status, added_by) VALUES
  (gen_random_uuid(), 'Claude Sonnet 4', 'claude-sonnet-4-6', 'c3d4e5f6-a7b8-9012-cdef-123456789012', 100000, 'approved', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'),
  (gen_random_uuid(), 'GPT-4 Turbo', 'gpt-4-turbo', 'd4e5f6a7-b8c9-0123-defa-234567890123', 128000, 'approved', 'b2c3d4e5-f6a7-8901-bcde-f12345678901'),
  (gen_random_uuid(), 'Gemini Pro', 'gemini-pro', 'e5f6a7b8-c9d0-1234-efab-345678901234', 128000, 'approved', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');