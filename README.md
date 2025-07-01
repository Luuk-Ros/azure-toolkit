# azure-toolkit

**A comprehensive toolkit for Azure administrators and developers, featuring automation scripts and KQL query examples.**

---

## Table of Contents

- [Description](#description)  
- [Getting Started](#getting-started)  
- [Scripts](#scripts)  
- [KQL Examples](#kql-examples)  
- [Contributing](#contributing)  
- [License](#license)  

---

## Description

`azure-toolkit` is your go-to repo for reusable Azure automation scripts and Kusto Query Language (KQL) examples. Whether you’re managing resources via PowerShell/CLI or analyzing logs with Log Analytics, you’ll find ready-to-run tools here to speed up your workflows.

---

## Getting Started

1. **Clone the repo**  
    
    git clone https://github.com/your-username/azure-toolkit.git  
    cd azure-toolkit  

2. **Browse** the `scripts/` and `kql/` folders for items that match your needs.  
3. **Customize** the configuration block at the top of any script or KQL file.  
4. **Run** or integrate into your pipelines.

---

## Scripts

All automation scripts live under `scripts/`, grouped by functional category:

    scripts/
    ├─ networking/      VNet peering, subnet & firewall automation
    ├─ storage/             Azure Files AD-DS integration & storage tests
    ├─ monitoring/          Agent installs & Log Analytics purges
    ├─ governance/          Tagging, RBAC/SPN reporting & policy checks
    ├─ device-management/   Windows provisioning, Winget installs & scans
    └─ utilities/           Generic helper functions & data munging

- **networking/**  
  Automate virtual network links, subnet updates, firewall rule deployments.  
- **storage/**  
  Deploy and test Azure Files “hybrid” AD authentication (AzFilesHybrid), join storage accounts to AD.  
- **monitoring/**  
  Install monitoring agents (Zabbix, Log Analytics), purge old logs, run health checks.  
- **governance/**  
  Apply and audit tags, report on Service Principal role assignments, enforce policy.  
- **device-management/**  
  Bootstrap Windows endpoints via Winget, trigger Defender scans, Intune-style tasks.  
- **utilities/**  
  PowerShell helper scripts for list/string conversion, HTML parsing, object flattening, path helpers, etc.

---

## KQL Examples

All Kusto Query Language examples live under `kql/`, organized by query domain:

    kql/
    ├─ data/          Ingestion stats
    ├─ security/      Sign-in & audit logs analytics
    ├─ network/       DNS, NSG flow & firewall diagnostics
    └─ cost/          Usage & cost analysis

- **data/**  
  Time-series charts of ingestion volume  
- **security/**  
  Unique or failed sign-ins, MFA failures, device-based filters.  
- **network/**  
  Azure Firewall DNS proxy logs, NSG flow summaries, top blocked IPs.  
- **cost/**  
  Data ingestion by type, cost per resource group, daily cost trends, pie charts.

---

## Contributing

We welcome your contributions!

1. **Fork** this repository.  
2. git checkout -b feature/YourFeatureName  
3. **Add** your script or KQL file, following naming convention and folder structure.  
4. **Document** it with the standard header (`.SYNOPSIS`, `.DESCRIPTION`, etc.) or a README entry.  
5. **Submit** a Pull Request describing your changes.

---

## License

This project is licensed under the [MIT License](LICENSE).