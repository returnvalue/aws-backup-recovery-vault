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
    ```

2.  **Inspect Backup Plan:**
    ```bash
    awslocal backup list-backup-plans
    ```

3.  **Confirm Resource Selection:**
    Check that the tag-based selection is correctly configured:
    ```bash
    awslocal backup get-backup-selection --plan-id <YOUR_PLAN_ID> --selection-id <YOUR_SELECTION_ID>
    ```

4.  **Test Tag-Based Protection (Conceptual):**
    Any resource created with the tag \`Backup: Daily\` will now be automatically captured by the daily 5:00 AM backup window.

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```
