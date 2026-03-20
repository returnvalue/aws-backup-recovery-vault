# AWS provider configuration for LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    backup         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kms            = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    sts            = "http://localhost:4566"
  }
}

# KMS Key: Provides encryption for our backup vault
resource "aws_kms_key" "backup_key" {
  description             = "KMS key for AWS Backup Vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "backup-vault-key"
    Environment = "CloudOps-Lab"
  }
}

# Backup Vault: Secure logical container for our backup recovery points
resource "aws_backup_vault" "central_vault" {
  name        = "sysops-recovery-vault"
  kms_key_arn = aws_kms_key.backup_key.arn

  tags = {
    Name        = "central-backup-vault"
    Environment = "CloudOps-Lab"
  }
}

# IAM Role: Identity for AWS Backup to perform backup and restore operations
resource "aws_iam_role" "backup_role" {
  name = "aws-backup-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
    }]
  })
}

# IAM Policy Attachment: Grants the role the standard AWS backup permissions
resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup_role.name
}

# Backup Plan: Defines the schedule and lifecycle for our backups
resource "aws_backup_plan" "daily_backup_plan" {
  name = "sysops-daily-backup-plan"

  rule {
    rule_name         = "daily-incremental-rule"
    target_vault_name = aws_backup_vault.central_vault.name
    schedule          = "cron(0 5 ? * * *)" # Every day at 5:00 AM

    lifecycle {
      delete_after = 35 # Retain backups for 35 days
    }
  }

  tags = {
    Name        = "daily-backup-plan"
    Environment = "CloudOps-Lab"
  }
}

# Backup Selection: Automatically assigns resources to the plan based on tags
resource "aws_backup_selection" "tagged_resources" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "tagged-resource-selection"
  plan_id      = aws_backup_plan.daily_backup_plan.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "Daily"
  }
}

# Outputs: Key identifiers for the backup architecture
output "backup_vault_arn" {
  value = aws_backup_vault.central_vault.arn
}

output "backup_plan_id" {
  value = aws_backup_plan.daily_backup_plan.id
}
