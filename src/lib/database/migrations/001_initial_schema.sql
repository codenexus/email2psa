-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create custom types
CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'cancelled', 'expired');
CREATE TYPE template_category AS ENUM ('security', 'monitoring', 'backup', 'network', 'custom');
CREATE TYPE processing_status AS ENUM ('pending', 'processed', 'failed', 'skipped');

-- Organizations (Tenants)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    subscription_status subscription_status DEFAULT 'trial',
    subscription_expires_at TIMESTAMPTZ,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User profiles (extends Supabase auth.users)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'member',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Templates (Pre-built configurations)
CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category template_category NOT NULL,
    vendor TEXT, -- 'todyl', 'sentinelone', etc.
    is_public BOOLEAN DEFAULT false,
    created_by UUID REFERENCES user_profiles(id),
    configuration JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- PSA Configurations (per tenant)
CREATE TABLE psa_configurations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    psa_type TEXT NOT NULL, -- 'autotask', 'connectwise', etc.
    name TEXT NOT NULL,
    api_credentials JSONB NOT NULL, -- encrypted
    field_mappings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email Accounts (Nylas configurations)
CREATE TABLE email_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email_address TEXT NOT NULL,
    nylas_grant_id TEXT,
    nylas_account_id TEXT,
    provider TEXT, -- 'gmail', 'outlook', 'imap'
    is_active BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email Processing Rules (per tenant)
CREATE TABLE email_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    template_id UUID REFERENCES templates(id),
    name TEXT NOT NULL,
    email_account_id UUID REFERENCES email_accounts(id),
    psa_configuration_id UUID REFERENCES psa_configurations(id),
    conditions JSONB NOT NULL, -- parsing conditions
    actions JSONB NOT NULL, -- what to do when matched
    priority INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Processing Logs (audit trail)
CREATE TABLE processing_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    email_rule_id UUID REFERENCES email_rules(id),
    email_account_id UUID REFERENCES email_accounts(id),
    email_subject TEXT,
    email_from TEXT,
    email_message_id TEXT,
    status processing_status DEFAULT 'pending',
    psa_ticket_id TEXT,
    error_message TEXT,
    processing_data JSONB DEFAULT '{}',
    processed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_user_profiles_org ON user_profiles(organization_id);
CREATE INDEX idx_templates_category ON templates(category);
CREATE INDEX idx_templates_vendor ON templates(vendor);
CREATE INDEX idx_email_rules_org ON email_rules(organization_id);
CREATE INDEX idx_email_rules_active ON email_rules(is_active);
CREATE INDEX idx_processing_logs_org ON processing_logs(organization_id);
CREATE INDEX