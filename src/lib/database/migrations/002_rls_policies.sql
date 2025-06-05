-- Row Level Security Policies for Multi-tenant Architecture

-- Helper function to get current user's organization
CREATE OR REPLACE FUNCTION auth.get_user_organization_id()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT organization_id 
  FROM user_profiles 
  WHERE id = auth.uid();
$$;

-- Organizations: Users can only see their own organization
CREATE POLICY "Users can view own organization" ON organizations
  FOR SELECT USING (
    id = auth.get_user_organization_id()
  );

CREATE POLICY "Users can update own organization" ON organizations
  FOR UPDATE USING (
    id = auth.get_user_organization_id()
  );

-- User Profiles: Users can see profiles in their organization
CREATE POLICY "Users can view organization members" ON user_profiles
  FOR SELECT USING (
    organization_id = auth.get_user_organization_id()
  );

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (
    id = auth.uid()
  );

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (
    id = auth.uid()
  );

-- Templates: Users can see public templates and their organization's templates
CREATE POLICY "Users can view accessible templates" ON templates
  FOR SELECT USING (
    is_public = true 
    OR created_by IN (
      SELECT id FROM user_profiles 
      WHERE organization_id = auth.get_user_organization_id()
    )
  );

CREATE POLICY "Users can manage organization templates" ON templates
  FOR ALL USING (
    created_by IN (
      SELECT id FROM user_profiles 
      WHERE organization_id = auth.get_user_organization_id()
    )
  );

-- PSA Configurations: Organization-scoped
CREATE POLICY "Users can manage organization PSA configs" ON psa_configurations
  FOR ALL USING (
    organization_id = auth.get_user_organization_id()
  );

-- Email Accounts: Organization-scoped
CREATE POLICY "Users can manage organization email accounts" ON email_accounts
  FOR ALL USING (
    organization_id = auth.get_user_organization_id()
  );

-- Email Rules: Organization-scoped
CREATE POLICY "Users can manage organization email rules" ON email_rules
  FOR ALL USING (
    organization_id = auth.get_user_organization_id()
  );

-- Processing Logs: Organization-scoped (read-only for most users)
CREATE POLICY "Users can view organization processing logs" ON processing_logs
  FOR SELECT USING (
    organization_id = auth.get_user_organization_id()
  );

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to all tables
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_templates_updated_at BEFORE UPDATE ON templates 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_psa_configurations_updated_at BEFORE UPDATE ON psa_configurations 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_email_accounts_updated_at BEFORE UPDATE ON email_accounts 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_email_rules_updated_at BEFORE UPDATE ON email_rules 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();