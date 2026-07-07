# Scripts

This directory contains reusable PowerShell scripts to automate common Azure tasks. Each category lives in its own subfolder for clarity and discoverability.

## Folder Structure

```
scripts/
├─ networking/          VNet, DNS & firewall automation
├─ storage/             Azure Files AD-DS integration & storage helpers
├─ monitoring/          Log purges & health checks
├─ governance/          Tagging, RBAC/SPN reporting & policy enforcement
└─ utilities/           General-purpose helper scripts
```

## Categories

### networking

Automate Azure network infrastructure:

| Script | Description |
|---|---|
| `Add-PdnsVnetLink.ps1` | Links one or more VNets to a Private DNS Zone. Supports bulk operations across subscriptions. |
| `Update-AzVnetSubnet.ps1` | Disables Private Link Service network policies on a specified subnet. |

### storage

Scripts to connect, join, and test Azure Storage accounts with Active Directory:

| Script | Description |
|---|---|
| `Join-AzStorageAccount.ps1` | Joins an Azure Storage account to an on-premises AD domain (AD-DS). Depends on AzFilesHybrid. |
| `Test-AzStorageConnection.ps1` | Validates connectivity to a specified Azure Storage account and file share endpoints. |
| `CopyToPSPath.ps1` | Copies AzFilesHybrid module files into a path in `$env:PSModulePath`. Run before `Join-AzStorageAccount.ps1`. |
| `AzFilesHybrid.psm1` | Microsoft AzFilesHybrid module — enables AD-based authentication for Azure Files. |

### monitoring

Scripts for log management and health checks:

| Script | Description |
|---|---|
| `Purge-AzLogData.ps1` | Purges old data from a Log Analytics workspace table by time range and table name. |

### governance

Enforce tagging, audit roles, and manage policy compliance:

| Script | Description |
|---|---|
| `Apply-TagToRGResources.ps1` | Applies a set of tags to all resources within one or more resource groups. |
| `Create-PolicyTagEnforcement.ps1` | Creates and assigns an Azure Policy initiative that enforces required tags on resources. |
| `Get-SpnRoleAssignments.ps1` | Exports all RBAC role assignments for Service Principals across one or more subscriptions. |

### utilities

General-purpose scripts for Azure administration tasks:

| Script | Description |
|---|---|
| `Get-CustomRoles.ps1` | Searches for custom RBAC role definitions across all subscriptions or a specific one. Supports pattern filtering and CSV export. |
| `Get-WsusRolesPerVm.ps1` | Detects whether the WSUS Server Role is installed on running Windows VMs using Azure RunCommand. |

## How to Add a New Script

1. **Pick a category** above or propose a new one if none fits.
2. **Place your script** in the matching folder.
3. **Name it clearly**, using PowerShell `Verb-Noun` convention, e.g. `Set-ResourceGroupTags.ps1`.
4. **Include a header comment block**:
   ```powershell
   <#
     .SYNOPSIS
       One-line summary of what this script does.
     .DESCRIPTION
       Detailed explanation, parameters, and example usage.
     .PARAMETER ParameterName
       Description of the parameter.
     .EXAMPLE
       .\MyScript.ps1 -ParameterName "value"
   #>
   ```
5. **Update this README**: add your script filename under its category with a one-sentence description.
