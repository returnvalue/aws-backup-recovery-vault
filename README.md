# AWS Automated Backup & Recovery Vault Lab

This lab demonstrates a mission-critical data protection pattern for the **AWS SysOps Administrator Associate**: implementing a centralized, automated backup strategy using **AWS Backup**.

## Architecture Overview

The system implements a secure and automated data lifecycle:

1.  **Encrypted Vault:** An AWS Backup Vault (\`sysops-recovery-vault\`) acts as the secure logical container for recovery points, protected by a dedicated KMS Customer Managed Key (CMK).
2.  **Scheduled Plans:** An AWS Backup Plan defines the "when and where" of data protection, specifying a daily incremental backup schedule and a 35-day retention policy.
3.  **Tag-Based Selection:** An automated resource selection mechanism identifies and assigns resources (like RDS instances or EBS volumes) to the backup plan based on the tag \`Backup: Daily\`.
4.  **Least-Privilege Security:** A dedicated IAM service role grants the Backup service only the permissions necessary to manage recovery points.

## Key Components

-   **AWS Backup Vault:** The secure repository for all backups.
-   **KMS CMK:** Root of trust for backup encryption.
-   **AWS Backup Plan:** The rule-set for automated data protection.
-   **Tag-Based Automation:** Ensures new resources are automatically protected without manual configuration.

## Prerequisites

-   [Terraform](https://www.terraform.io/downloads.html)
-   [LocalStack Pro](https://localstack.cloud/)
-   [AWS CLI / awslocal](https://github.com/localstack/awscli-local)

## Deployment

1.  **Initialize and Apply:**
    ```bash
    terraform init
    terraform apply -auto-approve
    
```

## Verification & Testing

To test the automated backup architecture:

1.  **Verify Backup Vault:**
    ```bash
    awslocal backup list-backup-vaults
    aws backup list-backup-vaults
    
```

2.  **Inspect Backup Plan:**
    ```bash
    awslocal backup list-backup-plans
    aws backup list-backup-plans
    
```

3.  **Confirm Resource Selection:**
    Check that the tag-based selection is correctly configured:
    ```bash
    awslocal backup get-backup-selection --plan-id <YOUR_PLAN_ID> --selection-id <YOUR_SELECTION_ID>
    aws backup get-backup-selection --plan-id <YOUR_PLAN_ID> --selection-id <YOUR_SELECTION_ID>
    
```

4.  **Test Tag-Based Protection (Conceptual):**
    Any resource created with the tag \`Backup: Daily\` will now be automatically captured by the daily 5:00 AM backup window.

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

💡 **Pro Tip: Using `aws` instead of `awslocal`**

If you prefer using the standard `aws` CLI without the `awslocal` wrapper or repeating the `--endpoint-url` flag, you can configure a dedicated profile in your AWS config files.

### 1. Configure your Profile
Add the following to your `~/.aws/config` file:
```ini
[profile localstack]
region = us-east-1
output = json
# This line redirects all commands for this profile to LocalStack
endpoint_url = http://localhost:4566
```

Add matching dummy credentials to your `~/.aws/credentials` file:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

### 2. Use it in your Terminal
You can now run commands in two ways:

**Option A: Pass the profile flag**
```bash
aws iam create-user --user-name DevUser --profile localstack
```

**Option B: Set an environment variable (Recommended)**
Set your profile once in your session, and all subsequent `aws` commands will automatically target LocalStack:
```bash
export AWS_PROFILE=localstack
aws iam create-user --user-name DevUser
```

### Why this works
- **Precedence**: The AWS CLI (v2) supports a global `endpoint_url` setting within a profile. When this is set, the CLI automatically redirects all API calls for that profile to your local container instead of the real AWS cloud.
- **Convenience**: This allows you to use the standard documentation commands exactly as written, which is helpful if you are copy-pasting examples from AWS labs or tutorials.
