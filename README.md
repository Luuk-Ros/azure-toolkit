# azure-toolkit

> A practical toolkit for Azure administrators — ready-to-use PowerShell automation scripts and KQL query examples for managing, monitoring, and governing Azure environments.

[![Language](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/en-us/powershell/)
[![Platform](https://img.shields.io/badge/Azure-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [About](#about)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Scripts](#scripts)
  - [networking](#networking)
  - [storage](#storage)
  - [monitoring](#monitoring)
  - [governance](#governance)
  - [utilities](#utilities)
- [KQL Examples](#kql-examples)
  - [data](#data)
  - [security](#security)
  - [network](#network)
  - [cost](#cost)
- [Contributing](#contributing)
- [License](#license)

---

## About

`azure-toolkit` is a collection of production-ready PowerShell scripts and Kusto Query Language (KQL) examples built for day-to-day Azure administration. Whether you are automating network changes, joining storage accounts to Active Directory, auditing RBAC roles, or analysing log ingestion costs — this toolkit gives you a well-organised starting point you can adapt to your own environment.

**Who is this for?**
- Azure administrators managing infrastructure at scale
- Cloud engineers who want reusable automation building blocks
- Security / governance teams that use Microsoft Sentinel or Log Analytics

---

## Prerequisites

| Requirement | Notes |
|---|---|
| PowerShell 7+ | Scripts are tested on PowerShell 7. Most also run on Windows PowerShell 5.1. |
| Az PowerShell module | `Install-Module -Name Az -Scope CurrentUser` |
| Azure CLI (optional) | Used in some scripts alongside Az PowerShell |
| Contributor or Owner role | Required for write operations (tagging, policy, networking) |
| Log Analytics Workspace | Needed to run KQL queries |

---

## Getting Started

```powershell
# 1. Clone the repository
git clone https://github.com/Luuk-Ros/azure-toolkit.git
cd azure-toolkit

# 2. Sign in to Azure
Connect-AzAccount

# 3. Browse the relevant folder and open the script you need
# 4. Edit the configuration block at the top of the file
# 5. Run the script or integrate it into your pipeline
```

> **Tip:** Every script contains a comment block at the top (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) — read it before running.

---

## Scripts

All automation scripts are under `scripts/`, grouped by functional category.

```
scripts/
├─ networking/          VNet, DNS & firewall automation
├─ storage/             Azure Files AD-DS integration & storage helpers
├─ monitoring/          Log purges & health checks
├─ governance/          Tagging, RBAC/SPN reporting & policy enforcement
├─ device-management/   Windows/Intune/Winget provisioning & scans
└─ utilities/           General-purpose helper scripts
```

### networking

| Script | Description |
|---|---|
| `Add-PdnsVnetLink.ps1` | Links one or more VNets to a Private DNS Zone. Supports bulk operations across subscriptions. |
| `Update-AzVnetSubnet.ps1` | Updates subnet address prefixes and associated NSGs on an existing virtual network. |

### storage

| Script | Description |
|---|---|
| `Join-AzStorageAccount.ps1` | Joins an Azure Storage account to an on-premises Active Directory domain (AD-DS). |
| `Test-AzStorageConnection.ps1` | Validates connectivity and authentication to an Azure Files share. |
| `CopyToPSPath.ps1` | Copies files to a path accessible via PowerShell, with retry logic and error handling. |
| `AzFilesHybrid.psm1` | Microsoft AzFilesHybrid module — enables Active Directory authentication for Azure Files. |

### monitoring

| Script | Description |
|---|---|
| `Purge-AzLogData.ps1` | Purges old data from a Log Analytics workspace table by time range and table name. |

### governance

| Script | Description |
|---|---|
| `Apply-TagToRGResources.ps1` | Applies a set of tags to all resources within one or more resource groups. |
| `Create-PolicyTagEnforcement.ps1` | Creates and assigns an Azure Policy initiative that enforces required tags on resources. |
| `Get-SpnRoleAssignments.ps1` | Exports all RBAC role assignments for Service Principals across one or more subscriptions. |

### utilities

| Script | Description |
|---|---|
| `getCustomRoles.ps1` | Lists all custom RBAC role definitions in a subscription or management group. |
| `getWsusRolesPerVm.ps1` | Retrieves WSUS update roles and patch status per VM from Azure Update Manager. |

---

## KQL Examples

All Kusto Query Language (KQL) examples are under `kql/`, organised by query domain. Open any `.kql` file directly in **Azure Data Explorer**, **Log Analytics**, or **Microsoft Sentinel**.

```
kql/
├─ data/        Log ingestion stats & event counts
├─ security/    Sign-in logs & MFA failure analysis
├─ network/     Firewall, DNS proxy & VPN diagnostics
└─ cost/        Cost breakdown & spending trends
```

### data

| Query | Description |
|---|---|
| `ingestion-daily.kql` | Daily ingestion volume over the last 30 days, rendered as a time chart. |
| `ingestion-by-type-month.kql` | Ingestion volume broken down by data type for the current month. |
| `diagnostics-1d.kql` | Diagnostic log ingestion for the last 24 hours. |
| `diagnostics-30d piechart.kql` | 30-day diagnostic log distribution as a pie chart. |
| `get-event-total-count.kql` | Total event count per table across the workspace. |
| `top-hosts-month.kql` | Top log-emitting hosts for the current month. |

### security

| Query | Description |
|---|---|
| `failed-signins-24h.kql` | All failed sign-in attempts in the last 24 hours. |
| `filtered-signins-30d.kql` | Sign-ins filtered by device, location, or user over the last 30 days. |
| `mfa-fails-7d.kql` | MFA failure events grouped by user over the last 7 days. |
| `windows-signins-30d.kql` | Windows device sign-ins over the last 30 days, with OS and device details. |

### network

| Query | Description |
|---|---|
| `firewall-dns-proxy.kql` | Azure Firewall DNS proxy log analysis — top queried domains and blocked requests. |
| `vpn-ike-diagnostics.kql` | VPN Gateway IKE diagnostic events for troubleshooting tunnel establishment. |

### cost

| Query | Description |
|---|---|
| `cost-per-rg.kql` | Total data ingestion cost broken down per resource group. |
| `daily-cost-trend.kql` | Daily cost trend over time, rendered as a time chart. |

---

## Contributing

Contributions are welcome! Follow these steps:

1. **Fork** this repository and create a new branch:
   ```
   git checkout -b feature/your-feature-name
   ```
2. **Place your file** in the correct folder (`scripts/<category>/` or `kql/<category>/`).
3. **Name it clearly**, e.g. `Set-ResourceGroupTags.ps1` or `export-sentinel-incidents.kql`.
4. **Add a header** to scripts:
   ```powershell
   <#
     .SYNOPSIS
       One-line summary of what this script does.
     .DESCRIPTION
       Detailed explanation including parameters and example usage.
     .PARAMETER ParameterName
       Description of the parameter.
     .EXAMPLE
       .\MyScript.ps1 -ParameterName "value"
   #>
   ```
5. **Update the relevant README** (this file or the subfolder README) with a one-line description of your addition.
6. **Open a Pull Request** describing your changes and the problem they solve.

---

## License

This project is licensed under the [MIT License](LICENSE).
