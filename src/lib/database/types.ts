export type SubscriptionStatus = 'trial' | 'active' | 'cancelled' | 'expired';
export type TemplateCategory = 'security' | 'monitoring' | 'backup' | 'network' | 'custom';
export type ProcessingStatus = 'pending' | 'processed' | 'failed' | 'skipped';

export interface Organization {
  id: string;
  name: string;
  slug: string;
  subscription_status: SubscriptionStatus;
  subscription_expires_at?: string;
  settings: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface UserProfile {
  id: string;
  organization_id: string;
  email: string;
  full_name?: string;
  role: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Template {
  id: string;
  name: string;
  description?: string;
  category: TemplateCategory;
  vendor?: string;
  is_public: boolean;
  created_by?: string;
  configuration: TemplateConfiguration;
  created_at: string;
  updated_at: string;
}

export interface TemplateConfiguration {
  email_patterns: {
    subject_contains?: string[];
    from_contains?: string[];
    body_contains?: string[];
  };
  psa_action: {
    action_type: 'create_ticket' | 'create_or_update' | 'update_existing';
    ticket_title_template: string;
    description_template: string;
    priority: 'low' | 'medium' | 'high' | 'urgent';
    category: string;
    duplicate_detection?: {
      match_fields: string[];
      time_window_hours: number;
    };
    find_ticket_by?: string;
    action?: string;
    note_template?: string;
    resolution_notes?: string;
  };
  field_mapping: Record<string, {
    extract_from: 'subject' | 'body' | 'from';
    pattern: string;
  }>;
}

export interface PSAConfiguration {
  id: string;
  organization_id: string;
  psa_type: string;
  name: string;
  api_credentials: Record<string, any>;
  field_mappings: Record<string, any>;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface EmailAccount {
  id: string;
  organization_id: string;
  name: string;
  email_address: string;
  nylas_grant_id?: string;
  nylas_account_id?: string;
  provider: string;
  is_active: boolean;
  last_sync_at?: string;
  created_at: string;
  updated_at: string;
}

export interface EmailRule {
  id: string;
  organization_id: string;
  template_id?: string;
  name: string;
  email_account_id: string;
  psa_configuration_id: string;
  conditions: Record<string, any>;
  actions: Record<string, any>;
  priority: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ProcessingLog {
  id: string;
  organization_id: string;
  email_rule_id?: string;
  email_account_id?: string;
  email_subject?: string;
  email_from?: string;
  email_message_id?: string;
  status: ProcessingStatus;
  psa_ticket_id?: string;
  error_message?: string;
  processing_data: Record<string, any>;
  processed_at: string;
}

// Helper types for API responses
export interface DatabaseResponse<T> {
  data: T | null;
  error: string | null;
}

export interface PaginatedResponse<T> {
  data: T[];
  count: number;
  page: number;
  limit: number;
}