import type { SupabaseClient } from '@supabase/supabase-js';
import type {
  Organization,
  UserProfile,
  Template,
  PSAConfiguration,
  EmailAccount,
  EmailRule,
  ProcessingLog,
  DatabaseResponse,
  PaginatedResponse
} from './types.js';

export class DatabaseClient {
  constructor(private supabase: SupabaseClient) {}

  // Organizations
  async getOrganization(id: string): Promise<DatabaseResponse<Organization>> {
    const { data, error } = await this.supabase
      .from('organizations')
      .select('*')
      .eq('id', id)
      .single();

    return { data, error: error?.message || null };
  }

  async updateOrganization(id: string, updates: Partial<Organization>): Promise<DatabaseResponse<Organization>> {
    const { data, error } = await this.supabase
      .from('organizations')
      .update(updates)
      .eq('id', id)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // User Profiles
  async getUserProfile(userId: string): Promise<DatabaseResponse<UserProfile>> {
    const { data, error } = await this.supabase
      .from('user_profiles')
      .select('*')
      .eq('id', userId)
      .single();

    return { data, error: error?.message || null };
  }

  async createUserProfile(profile: Omit<UserProfile, 'created_at' | 'updated_at'>): Promise<DatabaseResponse<UserProfile>> {
    const { data, error } = await this.supabase
      .from('user_profiles')
      .insert(profile)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // Templates
  async getTemplates(page = 1, limit = 20): Promise<PaginatedResponse<Template>> {
    const offset = (page - 1) * limit;
    
    const { data, error, count } = await this.supabase
      .from('templates')
      .select('*', { count: 'exact' })
      .range(offset, offset + limit - 1)
      .order('created_at', { ascending: false });

    if (error) {
      return { data: [], count: 0, page, limit };
    }

    return { data: data || [], count: count || 0, page, limit };
  }

  async getTemplatesByCategory(category: string): Promise<DatabaseResponse<Template[]>> {
    const { data, error } = await this.supabase
      .from('templates')
      .select('*')
      .eq('category', category)
      .order('name');

    return { data, error: error?.message || null };
  }

  async createTemplate(template: Omit<Template, 'id' | 'created_at' | 'updated_at'>): Promise<DatabaseResponse<Template>> {
    const { data, error } = await this.supabase
      .from('templates')
      .insert(template)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // PSA Configurations
  async getPSAConfigurations(): Promise<DatabaseResponse<PSAConfiguration[]>> {
    const { data, error } = await this.supabase
      .from('psa_configurations')
      .select('*')
      .eq('is_active', true)
      .order('name');

    return { data, error: error?.message || null };
  }

  async createPSAConfiguration(config: Omit<PSAConfiguration, 'id' | 'created_at' | 'updated_at'>): Promise<DatabaseResponse<PSAConfiguration>> {
    const { data, error } = await this.supabase
      .from('psa_configurations')
      .insert(config)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // Email Accounts
  async getEmailAccounts(): Promise<DatabaseResponse<EmailAccount[]>> {
    const { data, error } = await this.supabase
      .from('email_accounts')
      .select('*')
      .eq('is_active', true)
      .order('name');

    return { data, error: error?.message || null };
  }

  async createEmailAccount(account: Omit<EmailAccount, 'id' | 'created_at' | 'updated_at'>): Promise<DatabaseResponse<EmailAccount>> {
    const { data, error } = await this.supabase
      .from('email_accounts')
      .insert(account)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // Email Rules
  async getEmailRules(): Promise<DatabaseResponse<EmailRule[]>> {
    const { data, error } = await this.supabase
      .from('email_rules')
      .select(`
        *,
        template:templates(*),
        email_account:email_accounts(*),
        psa_configuration:psa_configurations(*)
      `)
      .eq('is_active', true)
      .order('priority', { ascending: false });

    return { data, error: error?.message || null };
  }

  async createEmailRule(rule: Omit<EmailRule, 'id' | 'created_at' | 'updated_at'>): Promise<DatabaseResponse<EmailRule>> {
    const { data, error } = await this.supabase
      .from('email_rules')
      .insert(rule)
      .select()
      .single();

    return { data, error: error?.message || null };
  }

  // Processing Logs
  async getProcessingLogs(page = 1, limit = 50): Promise<PaginatedResponse<ProcessingLog>> {
    const offset = (page - 1) * limit;
    
    const { data, error, count } = await this.supabase
      .from('processing_logs')
      .select('*', { count: 'exact' })
      .range(offset, offset + limit - 1)
      .order('processed_at', { ascending: false });

    if (error) {
      return { data: [], count: 0, page, limit };
    }

    return { data: data || [], count: count || 0, page, limit };
  }

  async createProcessingLog(log: Omit<ProcessingLog, 'id' | 'processed_at'>): Promise<DatabaseResponse<ProcessingLog>> {
    const { data, error } = await this.supabase
      .from('processing_logs')
      .insert(log)
      .select()
      .single();

    return { data, error: error?.message || null };
  }
}

// Helper function to create database client
export function createDatabaseClient(supabase: SupabaseClient): DatabaseClient {
  return new DatabaseClient(supabase);
}