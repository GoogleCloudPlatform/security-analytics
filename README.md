# Threat Detection As Code
List of security analytics queries for threat detection and access audit for your data &amp; workloads in Google Cloud

![Security Monitoring](security_mon.png)

## Security Analytics Use Cases

| # | Cloud Security Threat | Log Source | Audit | Detect | Remediate |
|---|---|---|:-:|:-:|:-:|
| 1 | **Login & Access Patterns**
| 1.01 | [Login occured from a highly-priviledged account](./sql/1_01_login_highly_priviledged_account.sql)<br>(e.g. Super Admin, Organization Admin) | Cloud Identity Logs (Google Workspace Login) | | :white_check_mark: | |
| 1.02 | [Suspicious login attempts flagged by Google Workspace](./sql/1_02_suspicious_login_attempt.sql) | Cloud Identity Logs (Google Workspace Login) | | :white_check_mark: | |
| 1.03 | [Excessive login failures from any user identity ( >= 3)](./sql/1_03_excessive_login_failures.sql) | Cloud Identity Logs (Google Workspace Login) | | :white_check_mark: | |
| 1.10 | [Access attempts violating VPC service controls](./sql/1_10_access_attempts_blocked_by_VPC_SC.sql) | Audit Logs - Policy | :white_check_mark: | :white_check_mark: | |
| 1.20 | [Access attempts violating Identity-Aware Proxy (IAP) access controls](./sql/1_20_access_attempts_blocked_by_IAP.sql) | HTTP(S) LB Logs | :white_check_mark: | :white_check_mark: | |
| 2 | **IAM, Keys & Secrets Admin Activity**
| 2.01 | [Super admin or Admin permissions granted](./sql/2_01_super_admin_or_admin_permissions_granted.sql) | Audit Logs - Admin Activity (Google Workspace Admin) | :white_check_mark: | :white_check_mark: | |
| 2.10 | [Organization admin permissions granted](./sql/2_10_org_admin_permissions_granted.sql) | Audit Logs - Admin Activity| :white_check_mark: | :white_check_mark: | |
| 2.11 | [Permissions granted to a user from a non-allowed domain](./sql/2_11_permissions_granted_to_non_allowed_user.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.20 | [Permissions granted over a Service Account](./sql/2_20_permissions_granted_over_SA.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.21 | [Permissions granted to impersonate Service Account](./sql/2_21_permissions_granted_to_impersonate_SA.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.22 | [Permissions granted to create or manage Service Account keys](./sql/2_22_permissions_granted_to_create_SA_keys.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.30 | [Service accounts or keys created by non-approved identity](./sql/2_10_service_accounts_or_keys_created_by_non_approved_identity.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.40 | [User access added (or removed) from IAP-protected HTTPS services](./sql/2_40_user_access_modified_in_IAP.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3 | **Cloud Provisioning Activity**

