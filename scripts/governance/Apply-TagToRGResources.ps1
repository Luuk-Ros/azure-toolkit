<#
.SYNOPSIS
    Applies a specific tag to all visible resources within an Azure Resource Group, excluding hidden resource types.

.DESCRIPTION
    - Authenticates to Azure using the Az PowerShell module.
    - Sets the subscription context.
    - Retrieves all resources in the specified Resource Group.
    - Filters out any resource types listed in $HiddenResourceTypes.
    - Preserves existing tags and applies the new tag ($TagKey=$TagValue) to each remaining resource.
    - Skips resources that already have the tag set to the desired value.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    01-07-2025

.NOTES
    - Requires the Az PowerShell module: Install-Module -Name Az -Scope CurrentUser
    - Requires Contributor or Owner role on the target subscription.
#>

# Configuration
$TenantId            = "<your-tenant-id-here>"
$SubscriptionId      = "<your-subscription-id-here>"
$ResourceGroupName   = "<your-resource-group-name-here>"
$TagKey              = "axiansManaged"
$TagValue            = "false"
$HiddenResourceTypes = @(
    "Microsoft.Resources/deployments",
    "Microsoft.Compute/virtualMachines/extensions",
    "Microsoft.Authorization/roleAssignments",
    "Microsoft.Security/securityContacts",
    "Microsoft.PolicyInsights/policyStates",
    "Microsoft.Insights/scheduledQueryRules",
    "Microsoft.Insights/workbooks",
    "Microsoft.AlertsManagement/smartDetectorAlertRules",
    "Microsoft.Insights/actiongroups"
)

# 1) Authenticate and set subscription
Write-Host "*** Authenticating to Azure..." -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null

Write-Host "*** Setting subscription context to $SubscriptionId..." -ForegroundColor Cyan
try {
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
    Write-Host "*** Subscription context set successfully. ***" -ForegroundColor Green
}
catch {
    Write-Host "*** Error: Failed to set subscription context: $($_.Exception.Message) ***" -ForegroundColor Red
    exit 1
}

# 2) Retrieve resources
Write-Host "*** Retrieving resources in Resource Group '$ResourceGroupName'..." -ForegroundColor Cyan
try {
    $allResources = Get-AzResource -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}
catch {
    Write-Host "*** Error: Could not retrieve resources: $($_.Exception.Message) ***" -ForegroundColor Red
    exit 1
}

# 3) Filter out hidden types
$resourcesToTag = $allResources | Where-Object { $_.ResourceType -notin $HiddenResourceTypes }

if ($resourcesToTag.Count -eq 0) {
    Write-Host "*** No resources to tag in Resource Group '$ResourceGroupName'. ***" -ForegroundColor Yellow
    exit 0
}

Write-Host "*** Found $($resourcesToTag.Count) resources to process. ***" -ForegroundColor Green

# 4) Apply tags
foreach ($resource in $resourcesToTag) {
    $existingTags = $resource.Tags
    if ($null -eq $existingTags) { $existingTags = @{} }

    if ($existingTags[$TagKey] -ne $TagValue) {
        $existingTags[$TagKey] = $TagValue
        Write-Host "*** Updating tags for resource: $($resource.Name) [$($resource.ResourceType)]" -ForegroundColor Cyan
        try {
            Set-AzResource -ResourceId $resource.ResourceId -Tag $existingTags -Force -ErrorAction Stop | Out-Null
            Write-Host "*** Tag '$TagKey=$TagValue' applied successfully to $($resource.Name). ***" -ForegroundColor Green
        }
        catch {
            Write-Host "*** Error updating tags on $($resource.Name): $($_.Exception.Message) ***" -ForegroundColor Red
        }
    }
    else {
        Write-Host "*** Resource $($resource.Name) already has tag '$TagKey=$TagValue'; skipping. ***" -ForegroundColor DarkGray
    }
}

Write-Host "*** Tagging operation completed. ***" -ForegroundColor Cyan