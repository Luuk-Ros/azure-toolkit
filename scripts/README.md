# Scripts

This directory contains reusable PowerShell (and CLI) scripts to automate common Azure and Windows-related tasks.  Each category lives in its own subfolder for clarity and discoverability.

## Folder Structure
``` text
scripts/
├─ networking/ VNet, DNS & firewall automation
├─ storage/ Azure Storage account helpers
├─ monitoring/ Agent installs, log purges & health checks
├─ governance/ Tagging, RBAC/SPN reporting & policy checks
├─ device-management/ Windows/Intune/Winget provisioning & scans
└─ utilities/ Generic helper functions & data munging
```

## Categories

### networking-dns  
Automate your network infrastructure in Azure:  
- Virtual Network peering and links  
- Subnet updates  
- Firewall rule deployments  

### storage  
Scripts to connect to, join, mount or test Azure Storage accounts.

### monitoring  
Install or configure monitoring agents (Zabbix, Log Analytics, etc.), purge old log data, and run health-check routines.

### governance  
Enforce tagging standards, report on Service Principal role assignments, and audit policy compliance.

### device-management  
Bootstrap Windows machines with Winget installs, trigger Defender scans or other endpoint-management tasks.

### utilities  
General-purpose functions for PowerShell workflows: list/string conversion, HTML parsing, object flattening, path helpers, etc.

## How to Add a New Script

1. **Pick a category** above or propose a new one if none fits.  
2. **Place your script** in the matching folder.  
3. **Name it clearly**, e.g. `Set-ResourceGroupTags.ps1` or `Export-AzCostReport.ps1`.  
4. **Include a Top-of-File Comment Block**:
```powershell
   <#
     .SYNOPSIS
       One-line summary of what this script does.

     .DESCRIPTION
       Detailed explanation, parameters, and example usage.
   #>
```
5. Update this README: add your script filename under its category with a one-sentence description.


