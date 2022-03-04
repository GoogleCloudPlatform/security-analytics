# Community Security Analytics (CSA)

As organizations go through the Autonomic Security modernization journey, this repository serves as a community-driven list of sample security analytics for auditing cloud usage and for detecting threats to your data &amp; workloads in Google Cloud. These may assist **detection engineers**, **threat hunters** and **data governance analysts**.

![Security Monitoring](./img/gcp_security_mon.png)

CSA is a set of foundational security analytics designed to provide organizations with a rich baseline of pre-built queries and rules that they can readily use to start analyzing their Google Cloud logs including Cloud Audit logs, VPC Flow logs, DNS logs, and more using cloud-native or third-party analytics tools. The source code is provided as is, without warranty. See [Copyright & License](#copyright-&-license) below.

Current release include:
- SQL queries for [BigQuery](https://cloud.google.com/bigquery/)
- YARA-L rules for [Chroncile](https://chronicle.security/)

The security use cases below are grouped in 6 categories depending on underlying activity type and log sources:

1. :vertical_traffic_light: Login & Access Patterns
2. :key: IAM, Keys & Secrets Admin Activity
3. :building_construction: Cloud Provisoning Activity
4. :cloud: Cloud Workload Usage
5. :droplet: Data Usage
6. :zap: Network Activity

To learn more about the variety of Google Cloud logs, how to enable and natively export these logs to destinations like Chronicle or BigQuery for in-depth analytics, refer to Google Cloud [Security and access analytics solution guide](https://cloud.google.com/architecture/exporting-stackdriver-logging-for-security-and-access-analytics).

**Caution:** CSA is not meant to be a comprehensive set of threat detections, but a collection of community-contributed samples to get you started with detective controls. Use CSA in your threat detection and response capabilities (e.g. [Security Command Center](https://cloud.google.com/security-command-center), Chronicle, BigQuery, Siemplify, or third-party SIEM) in conjunction with threat prevention capabilities (e.g. [Security Command Center](https://cloud.google.com/security-command-center), [Cloud Armor](https://cloud.google.com/armor), [BeyondCorp](https://cloud.google.com/beyondcorp)). To learn more about Google’s approach to modern Security Operations, check out the [Autonomic Security Operations whitepaper](https://services.google.com/fh/files/misc/googlecloud_autonomicsecurityoperations_soc10x.pdf).


## Security Analytics Use Cases

| # | Cloud Security Threat | Log Source | Audit | Detect | Respond |
|---|---|---|:-:|:-:|:-:|
| 1 | :vertical_traffic_light: **Login & Access Patterns**
| 1.01 | [Login occured from a highly-privileged account](./detections/1.01/1.01.md) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.02 | [Suspicious login attempts flagged by Google Workspace](./detections/1.02/1.02.md) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.03 | [Excessive login failures from any user identity](./detections/1.03/1.03.md) | Cloud Identity Logs<br>(Google Workspace Login) | | :white_check_mark: | |
| 1.10 | [Access attempts violating VPC service controls](./detections/1.10/1.10.md) | Audit Logs - Policy | :white_check_mark: | :white_check_mark: | |
| 1.20 | [Access attempts violating Identity-Aware Proxy (IAP) access controls](./detections/1.20/1.20.md) | HTTP(S) LB Logs | :white_check_mark: | :white_check_mark: | |
| 2 | :key: **IAM, Keys & Secrets Admin Activity**
| 2.01 | [Super admin or Admin permissions granted](./detections/2.01/2.01.md) | Audit Logs - Admin Activity<br>(Google Workspace Admin) | :white_check_mark: | :white_check_mark: | |
| 2.10 | [Organization admin permissions granted](./detections/2.10/2.10.md) | Audit Logs - Admin Activity| :white_check_mark: | :white_check_mark: | |
| 2.11 | [Permissions granted to a user from a non-allowed domain](./detections/2.11/2.11.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.20 | [Permissions granted over a Service Account](./detections/2.20/2.20.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.21 | [Permissions granted to impersonate Service Account](./detections/2.21/2.21.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.22 | [Permissions granted to create or manage Service Account keys](./detections/2.22/2.22.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.30 | [Service accounts or keys created by non-approved identity](./detections/2.30/2.30.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 2.40 | [User access added (or removed) from IAP-protected HTTPS services](./detections/2.40/2.40.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3 | :building_construction: **Cloud Provisioning Activity**
| 3.01 | [Changes made to logging settings](./detections/3.01/3.01.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.10 | [Unusual admin activity by user & country in the last 7 days](./detections/3.10/3.10.md) | Audit Logs - Admin Activity | | :white_check_mark: | |
| 3.11 | [Unusual number of firewall rules modified in the last 7 days](./detections/3.11/3.11.md) | Audit Logs - Admin Activity | | :white_check_mark: | |
| 3.12 | [Firewall rules modified or deleted in the last 24 hrs](./detections/3.12/3.12.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.13 | [VPN tunnels created or deleted](./detections/3.13/3.13.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.14 | [DNS zones modified or deleted](./detections/3.14/3.14.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.15 | [Storage buckets modified or deleted by unfamiliar user identities](./detections/3.15/3.15.md) | Audit Logs - Admin Activity | :white_check_mark: | :white_check_mark: | |
| 3.20 | [VMs deleted in the last 7 days](./detections/3.20/3.20.md) | Audit Logs - Admin Activity | :white_check_mark: | | |
| 3.21 | [SQL databases created, modified or deleted in the last 7 days](./detections/3.21/3.21.md) | Audit Logs - Admin Activity | :white_check_mark: | | |
| 4 | :cloud: **Cloud Workload Usage**
| 4.01 | [Unusually high API usage by any user identity](./detections/4.01/4.01.md) | Audit Logs | :white_check_mark: | :white_check_mark: | |
| 4.10 | [Autoscaling usage in the past month ](./detections/4.10/4.10.md) | Audit Logs - Admin Activity | :white_check_mark: | | |
| 4.11 | [Autoscaling usage in the past month broken by day](./detections/4.11/4.11.md) | Audit Logs - Admin Activity | :white_check_mark: | | |
| 5 | :droplet: **Data Usage**
| 5.01 | [Which users **most frequently** accessed data in the past week?](./detections/5.01/5.01.md) | Audit Logs - Data Access | :white_check_mark: | | |
| 5.02 | [Which users accessed **most amount** of data in the past week?](./detections/5.02/5.02.md) | Audit Logs - Data Access | :white_check_mark: | | |
| 5.03 | [How much data was accessed by each user per day in the past week?](./detections/5.03/5.03.md) | Audit Logs - Data Access | :white_check_mark: | | |
| 5.04 | [Which users accessed data in the "accounts" table in the past month?](./detections/5.04/5.04.md) | Audit Logs - Data Access | :white_check_mark: | | :white_check_mark: |
| 5.05 | [What tables are most frequently accessed and by whom?](./detections/5.05/5.05.md) | Audit Logs - Data Access | :white_check_mark: | | |
| 5.06 | [Top 10 queries against BigQuery in the past week](./detections/5.06/5.06.md) | Audit Logs - Data Access | :white_check_mark: | | |
| 5.07 | [Any queries doing very large scans?](./detections/5.07/5.07.md) | Audit Logs - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.08 | [Any destructive queries or jobs (i.e. update or delete)?](./detections/5.08/5.08.md) | Audit Logs | :white_check_mark: | :white_check_mark: | |
| 5.09 | [Any exfiltration queries or jobs (i.e. copy or extract)?](./detections/5.09/5.09.md) | Audit Logs - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.20 | [Most common data (and metadata) access actions in the past month](./detections/5.20/5.20.md) | Audit Logs - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.30 | [Cloud Storage buckets enumerated by unfamiliar users](./detections/5.30/5.30.md) | Audit Logs - Data Access | :white_check_mark: | :white_check_mark: | |
| 5.31 | [Cloud Storage objects accessed from a new IP](./detections/5.31/5.31.md) | Audit Logs - Data Access | :white_check_mark: | :white_check_mark: | |
| 6 | :zap: **Network Activity**
| 6.01 | [Hosts reaching out to many other hosts or ports per hour](./detections/6.01/6.01.md) | VPC Flow Logs | :white_check_mark: | :white_check_mark: | |
| 6.10 | [Connections from a new IP to an in-scope network (GDPR, PCI, etc.)](./detections/6.10/6.10.md) | VPC Flow Logs | | :white_check_mark: | :white_check_mark: |
| 6.11 | [Connections to a malicious IP](./detections/6.11/6.11.md) | VPC Flow Logs | | :white_check_mark: | :white_check_mark: |
| 6.20 | [Connections blocked by Cloud Armor](./detections/6.20/6.20.md) | HTTP(S) LB Logs | :white_check_mark: | :white_check_mark: | |
| 6.21 | ["Log4j 2" vulnerability exploit attempts](./detections/6.21/6.21.md) | HTTP(S) LB Logs | | :white_check_mark: | |
| 6.22 | [List remote IP addresses attemting to exploit "Log4j 2" vulnerability](./detections/6.22/6.22.md) | HTTP(S) LB Logs | | :white_check_mark: | |
| 6.30 | [Virus or malware detected by Cloud IDS](./detections/6.30/6.30.md) | Cloud IDS Logs | | :white_check_mark: | |
| 6.31 | [Traffic sessions correlated to high severity threats detected by Cloud IDS](./detections/6.31/6.31.md) | Cloud IDS Logs | | :white_check_mark: | |
| 6.40 | [Top 10 DNS queried domains](./detections/6.40/6.40.md) | Cloud DNS Logs | :white_check_mark: | :white_check_mark: | |

## Copyright & License

Copyright 2022 Google LLC

Threat detection queries & rules under Threat Detections As Code are licensed under the Apache license, v2.0. Details can be found in [LICENSE](./LICENSE) file.
