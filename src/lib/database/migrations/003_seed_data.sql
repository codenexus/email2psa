-- Seed Data for Email2PSA

-- Insert public templates for common MSP tools
INSERT INTO templates (name, description, category, vendor, is_public, configuration) VALUES

-- Todyl SASE Templates
('Todyl - Site Offline Alert', 'Detects when Todyl reports a site going offline', 'network', 'todyl', true, '{
  "email_patterns": {
    "subject_contains": ["offline", "disconnected"],
    "from_contains": ["todyl", "noreply@todyl.com"],
    "body_contains": ["site", "offline", "SGN"]
  },
  "psa_action": {
    "action_type": "create_or_update",
    "ticket_title_template": "Todyl Alert: {site_name} Offline",
    "description_template": "Site {site_name} has gone offline. Last seen: {last_seen}",
    "priority": "high",
    "category": "Network Issues",
    "duplicate_detection": {
      "match_fields": ["site_name"],
      "time_window_hours": 24
    }
  },
  "field_mapping": {
    "site_name": {"extract_from": "body", "pattern": "Site: ([^\\n]+)"},
    "last_seen": {"extract_from": "body", "pattern": "Last seen: ([^\\n]+)"}
  }
}'),

('Todyl - Site Back Online', 'Detects when Todyl reports a site coming back online', 'network', 'todyl', true, '{
  "email_patterns": {
    "subject_contains": ["online", "connected", "recovered"],
    "from_contains": ["todyl", "noreply@todyl.com"],
    "body_contains": ["site", "online", "recovered"]
  },
  "psa_action": {
    "action_type": "update_existing",
    "find_ticket_by": "site_name",
    "action": "add_note_and_resolve",
    "note_template": "Site {site_name} is back online as of {recovery_time}",
    "resolution_notes": "Site connectivity restored automatically"
  },
  "field_mapping": {
    "site_name": {"extract_from": "body", "pattern": "Site: ([^\\n]+)"},
    "recovery_time": {"extract_from": "body", "pattern": "Recovered at: ([^\\n]+)"}
  }
}'),

-- SentinelOne Templates
('SentinelOne - Threat Detection', 'Creates tickets for SentinelOne threat alerts', 'security', 'sentinelone', true, '{
  "email_patterns": {
    "subject_contains": ["threat", "malware", "suspicious"],
    "from_contains": ["sentinelone", "alerts@sentinelone.com"],
    "body_contains": ["threat detected", "quarantined"]
  },
  "psa_action": {
    "action_type": "create_ticket",
    "ticket_title_template": "Security Alert: {threat_type} on {device_name}",
    "description_template": "SentinelOne detected {threat_type} on device {device_name}. Status: {status}. User: {user_name}",
    "priority": "urgent",
    "category": "Security Incident"
  },
  "field_mapping": {
    "threat_type": {"extract_from": "body", "pattern": "Threat Type: ([^\\n]+)"},
    "device_name": {"extract_from": "body", "pattern": "Device: ([^\\n]+)"},
    "user_name": {"extract_from": "body", "pattern": "User: ([^\\n]+)"},
    "status": {"extract_from": "body", "pattern": "Status: ([^\\n]+)"}
  }
}'),

('SentinelOne - Agent Offline', 'Detects when SentinelOne agents go offline', 'security', 'sentinelone', true, '{
  "email_patterns": {
    "subject_contains": ["agent offline", "disconnected"],
    "from_contains": ["sentinelone"],
    "body_contains": ["agent", "offline", "last seen"]
  },
  "psa_action": {
    "action_type": "create_or_update",
    "ticket_title_template": "SentinelOne Agent Offline: {device_name}",
    "description_template": "SentinelOne agent on {device_name} has been offline since {last_seen}",
    "priority": "medium",
    "category": "Security Monitoring",
    "duplicate_detection": {
      "match_fields": ["device_name"],
      "time_window_hours": 48
    }
  },
  "field_mapping": {
    "device_name": {"extract_from": "body", "pattern": "Device: ([^\\n]+)"},
    "last_seen": {"extract_from": "body", "pattern": "Last seen: ([^\\n]+)"}
  }
}'),

-- Microsoft 365 Templates
('Microsoft 365 - Service Health Alert', 'M365 service disruption notifications', 'monitoring', 'microsoft', true, '{
  "email_patterns": {
    "subject_contains": ["service health", "service advisory", "incident"],
    "from_contains": ["microsoft", "office365"],
    "body_contains": ["service health", "impact", "affected services"]
  },
  "psa_action": {
    "action_type": "create_ticket",
    "ticket_title_template": "M365 Service Alert: {service_name} - {status}",
    "description_template": "Microsoft 365 service health alert for {service_name}. Status: {status}. Impact: {impact}",
    "priority": "medium",
    "category": "Service Monitoring"
  },
  "field_mapping": {
    "service_name": {"extract_from": "body", "pattern": "Service: ([^\\n]+)"},
    "status": {"extract_from": "body", "pattern": "Status: ([^\\n]+)"},
    "impact": {"extract_from": "body", "pattern": "Impact: ([^\\n]+)"}
  }
}'),

-- Generic Monitoring Templates
('Generic - Server Down Alert', 'Generic server monitoring alert template', 'monitoring', 'generic', true, '{
  "email_patterns": {
    "subject_contains": ["server down", "host down", "unreachable"],
    "body_contains": ["server", "down", "unreachable", "failed"]
  },
  "psa_action": {
    "action_type": "create_or_update",
    "ticket_title_template": "Server Alert: {server_name} - {status}",
    "description_template": "Server monitoring alert: {server_name} is {status}. Details: {details}",
    "priority": "high",
    "category": "Infrastructure",
    "duplicate_detection": {
      "match_fields": ["server_name"],
      "time_window_hours": 12
    }
  },
  "field_mapping": {
    "server_name": {"extract_from": "subject", "pattern": "([\\w\\.-]+)"},
    "status": {"extract_from": "body", "pattern": "Status: ([^\\n]+)"},
    "details": {"extract_from": "body", "pattern": "Details: ([^\\n]+)"}
  }
}');

-- Insert template categories for easy filtering
INSERT INTO templates (name, description, category, vendor, is_public, configuration) VALUES
('Backup Failure Alert', 'Generic backup failure notification template', 'backup', 'generic', true, '{
  "email_patterns": {
    "subject_contains": ["backup failed", "backup error", "backup incomplete"],
    "body_contains": ["backup", "failed", "error", "incomplete"]
  },
  "psa_action": {
    "action_type": "create_ticket",
    "ticket_title_template": "Backup Failure: {client_name} - {backup_type}",
    "description_template": "Backup failure reported for {client_name}. Backup type: {backup_type}. Error: {error_message}",
    "priority": "high",
    "category": "Data Protection"
  },
  "field_mapping": {
    "client_name": {"extract_from": "body", "pattern": "Client: ([^\\n]+)"},
    "backup_type": {"extract_from": "body", "pattern": "Backup Type: ([^\\n]+)"},
    "error_message": {"extract_from": "body", "pattern": "Error: ([^\\n]+)"}
  }
}');