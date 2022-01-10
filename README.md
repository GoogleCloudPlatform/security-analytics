# Threat Detection As Code

![Security Monitoring](./img/gcp_security_mon.png)

List of security analytics queries for **threat detection** and **access audit** for your data &amp; workloads in Google Cloud. This non-comprehensive set of SQL queries ([BigQuery](https://cloud.google.com/bigquery/)) is designed to provide organizations with a rich starting point of threat detections that they can readily use and extend to help their Security Operations on Google Cloud. The security analytics use cases below are grouped in 6 categories depending on underlying activity type and log sources:

1. :vertical_traffic_light: Login & Access Patterns
2. :key: IAM, Keys & Secretes Admin Activity
3. :building_construction: Cloud Provisoning Activity
4. :cloud: Cloud Workload Usage
5. :droplet: Data Usage
6. :zap: Network Activity

To learn more about Google Cloud logs and how to export from Cloud Logging to destinations like [BigQuery](https://cloud.google.com/bigquery/docs) or [Chronicle](https://cloud.google.com/chronicle/docs) for in-depth security analytics, refer to Google Cloud [Security and access analytics solution guide](https://cloud.google.com/architecture/exporting-stackdriver-logging-for-security-and-access-analytics). 

This repository is provided as is, without warranty. See [Copyright & License](#copyright-&-license) below.

## Security Analytics Use Cases

| # | Cloud Security Threat | Log Source | Audit | Detect | Respond |
|---|---|---|:-:|:-:|:-:|
| 1 | :vertical_traffic_light: **Login & Access Patterns**
| 1.01 | [Login occured from a highly-priviledged account](./sql/1_01_login_highly_priviledged_account.sql) (e.g. Super Admin, Organization Admin) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.02 | [Suspicious login attempts flagged by Google Workspace](./sql/1_02_suspicious_login_attempt.sql) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.03 | [Excessive login failures from any user identity ( >= 3)](./sql/1_03_excessive_login_failures.sql) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.10 | [Access attempts violating VPC service controls](./sql/1_10_access_attempts_blocked_by_VPC_SC.sql) | Audit Logs - Policy | :white_check_mark: | :white_check_mark: | |
| 1.20 | [Access attempts violating Identity-Aware Proxy (IAP) access controls](./sql/1_20_access_attempts_blocked_by_IAP.sql) | HTTP(S) LB Logs | :white_check_mark: | :white_check_mark: | |
| 2 | :key: **IAM, Keys & Secrets Admin Activity**
| 2.01 | [Super admin or Admin permissions granted](./sql/2_01_super_admin_or_admin_permissions_granted.sql) | Audit Logs - Admin Activity<br>(Google Workspace Admin) | :white_check_mark: | :white_check_mark: | |
| 2.10 | [Organization admin permissions granted](./sql/2_10_org_admin_permissions_granted.sql) | Audit Logs - Admin Activity| :white_check_mark: | :white_check_mark: | |
| 2.11 | [Permissions granted to a user from a non-allowed domain](./sql/2_11_permissions_granted_to_non_allowed_user.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.20 | [Permissions granted over a Service Account](./sql/2_20_permissions_granted_over_SA.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.21 | [Permissions granted to impersonate Service Account](./sql/2_21_permissions_granted_to_impersonate_SA.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.22 | [Permissions granted to create or manage Service Account keys](./sql/2_22_permissions_granted_to_create_SA_keys.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.30 | [Service accounts or keys created by non-approved identity](./sql/2_10_service_accounts_or_keys_created_by_non_approved_identity.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.40 | [User access added (or removed) from IAP-protected HTTPS services](./sql/2_40_user_access_modified_in_IAP.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3 | :building_construction: **Cloud Provisioning Activity**
| 3.01 | [Changes made to logging settings](./sql/3_01_logging_settings_modified.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.10 | [Unusual admin activity by user & country in the last 7 days](./sql/3_10_unusual_admin_activity_by_user_country.sql) | Audit Logs - Admin Activity | | :white_check_mark: | |
| 3.11 | [Unusual number of firewall rules modified in the last 7 days](./sql/3_11_unusual_number_of_firewall_rules_modified.sql) | Audit Logs - Admin Activity | | :white_check_mark: | |
| 3.12 | [Firewall rules modified or deleted in the last 24 hrs](./sql/3_12_firewall_rules_modified_or_deleted.sql) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.13 | VPN tunnels created or deleted | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.14 | DNS zones modified or deleted | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.15 | Storage buckets modified or deleted by unfamiliar user identities | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.20 | [VMs deleted in the last 7 days](./sql/3_20_virtual_machines_deleted.sql) | Audit Logs - Admin Activity | :white_check_mark: | | |
| 3.21 | SQL databases created, modified or deleted in the last 7 days | Audit Log - Admin Activity | :white_check_mark: | | |
| 4 | :cloud: **Cloud Workload Usage**
| 4.01 | [Unusually high API usage by any user identity](./sql/4_01_unusually_high_api_usage_by_user_identity.sql) | Audit Logs | :white_check_mark: | :white_check_mark: | |
| 4.10 | [Autoscaling usage in the past month ](./sql/4_10_autoscaling_usage_frequency.sql) | Audit Log - Admin Activity | :white_check_mark: | | |
| 4.11 | [Autoscaling usage in the past month broken by day](./sql/4_11_autoscaling_usage_frequency_by_day.sql) | Audit Log - Admin Activity | :white_check_mark: | | |
| 5 | :droplet: **Data Usage**
| 5.01 | [Which users **most frequently** accessed data in the past week?](./sql/5_01_users_who_most_frequently_accessed_data.sql) | Audit Log - Data Access | :white_check_mark: | | |
| 5.02 | [Which users accessed **most amount** of data in the past week?](./sql/5_02_users_who_accessed_most_amount_of_data.sql) | Audit Log - Data Access | :white_check_mark: | | |
| 5.03 | [How much data was accessed by each user per day in the past week?](./sql/5_03_data_amount_accessed_by_user_per_day.sql) | Audit Log - Data Access | :white_check_mark: | | |
| 5.04 | [Which users accessed data in the "accounts" table in the past month?](./sql/5_04_users_who_accessed_data_in_table.sql) | Audit Log - Data Access | :white_check_mark: | | :white_check_mark: |
| 5.05 | [What tables are most frequently accessed and by whom?](./sql/5_05_tables_most_frequently_accessed.sql) | Audit Log - Data Access | :white_check_mark: | | |
| 5.06 | [Top 10 queries against BigQuery in the past week](./sql/5_06_BQ_queries_top.sql) | Audit Log - Data Access | :white_check_mark: | | |
| 5.07 | [Any queries doing very large scans?](./sql/5_07_BQ_queries_with_large_scans.sql) | Audit Log - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.08 | [Any destructive queries or jobs (i.e. update or delete)?](./sql/5_08_BQ_queries_destructive.sql) | Audit Log - Data Access & Admin Activity | :white_check_mark: | :white_check_mark: | |
| 5.09 | [Any exfiltration queries or jobs (i.e. copy or extract)?](./sql/5_09_BQ_queries_exfiltration.sql) | Audit Log - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.20 | [Most common data (and metadata) access actions in the past month](./sql/5_20_top_data_access_actions.sql) | Audit Log - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.30 | Cloud Storage buckets enumerated by unfamiliar users | Audit Log - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.31 | [Cloud Storage objects accessed from a new IP](./sql/5_31_cloud_storage_object_accessed_from_new_IP.sql) (60-day lookback) | Audit Log - Data Access | :white_check_mark: | :white_check_mark: | |
| 6 | :zap: **Network Activity**
| 6.01 | [Hosts reaching out to many other hosts or ports per hour](./sql/6_01_hosts_reaching_to_many_other_hosts_or_ports.sql) (indicating potential scanning activity) | VPC Flow Logs | :white_check_mark: | :white_check_mark: | |
| 6.10 | [Connections from a new IP to an in-scope network](./sql/6_10_connection_from_new_IP.sql) (GDPR, PCI, etc.) | VPC Flow Logs | | :white_check_mark: | :white_check_mark: |
| 6.11 | [Connections to a malicious IP](./sql/6_11_connections_to_malicious_IP.sql) | VPC Flow Logs | | :white_check_mark: | :white_check_mark: |
| 6.20 | [Connections blocked by Cloud Armor](./sql/6_20_connections_blocked_by_cloud_armor.sql) | HTTP(S) LB Logs | :white_check_mark: | :white_check_mark: | |
| 6.21 | [Log4j 2 vulnerability exploit attempts](./sql/6_21_log4j_exploit_attempts.sql) | HTTP(S) LB Logs | | :white_check_mark: | |
| 6.22 | [List remote IP addresses attemting to exploit Log4j 2 vulnerability](./sql/6_22_log4j_exploit_attempts_remote_IP_address_list.sql) | HTTP(S) LB Logs | | :white_check_mark: | |
| 6.30 | [Virus or malware detected by Cloud IDS](./sql/6_30_virus_or_malware_detected_by_cloud_IDS.sql) | Cloud IDS Logs | | :white_check_mark: | |
| 6.31 | [Traffic sessions correlated to high severity threats detected by Cloud IDS](./sql/6_31_traffic_sessions_of_high_severity_threats_detected_by_cloud_IDS.sql) | Cloud IDS Logs | | :white_check_mark: | |
| 6.40 | [Top 10 DNS queried domains](./sql/6_40_DNS_top_queried_domains.sql) | Cloud DNS Logs | :white_check_mark: | :white_check_mark: | |

## Copyright & License

Copyright 2022 Google LLC

Threat detection queries & rules under Threat Detections As Code are licensed under the Apache license, v2.0. Details can be found in [LICENSE](./LICENSE) file.