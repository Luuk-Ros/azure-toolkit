<#
.SYNOPSIS
    Deploys a generic 'Tag Enforcement' policy (Modify effect) across Management Groups.

.DESCRIPTION
    A reusable Infrastructure-as-Code tool to enforce tagging standards.
    
    1.  **Dynamic Definition**: Creates a Policy Definition at the Parent MG (ALZ) based on the provided Tag Name & Value.
    2.  **Distributed Assignment**: Loops through specified Child MGs to assign the policy.
    3.  **Exclusion Handling**: Supports specific Resource Group exclusions (NotScopes) per assignment.
    4.  **Remediation**: Automatically grants 'Tag Contributor' rights and triggers remediation for existing resources.
    
    **Tech Stack**: Pure PowerShell + Azure REST API (No module dependency issues).

.PARAMETER TenantId
    Safety mechanism. The script verifies connection to this specific Tenant before running.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    07-01-2026
#>

# Configuration
# Safety & Scope
$TenantId = "<your-tenant-id-here>"
$SubscriptionId = "<your-subscription-id-here>" # used for context, not for deployment.

# Tagging Strategy
$DefinitionMgId       = "<your-parent-management-group-id-here>"
$TagName              = "axiansManaged"
$TagValue             = "false"
$PolicyDescription    = "Enforces the existence of the '$TagName' tag on all resources."
$DefinitionName       = "Axians - Enforce tag $TagName $TagValue" 
$DefinitionDisplayName= "Axians - Enforce tag $TagName $TagValue"

# Deployment Targets
$DeploymentTargets = @(
    @{
        MgId                  = "<your-child-management-group-id-here>"
        AssignmentName        = "xyz $TagName Enforcement"       
        # PORTAL ZICHTBAAR: Mag spaties en tekst bevatten
        AssignmentDisplayName = "xyz Enforce tag $TagName $TagValue"
        Exclusions            = @(
            # "<subscription-resource-id>/resourceGroups/<rg-name>"
        )
    },
    @{
        MgId                  = "<your-other-child-management-group-id-here>"
        AssignmentName        = "xyz $tagName Enforcement"
        AssignmentDisplayName = "xyz Enforce tag $TagName $TagValue"
        Exclusions            = @()
    }
)

# 2) Script Logic
# Auth check
Write-Host "*** Authenticating to Azure..." -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null

# 3) Create Definition
Write-Host "`n--- STEP 1: Syncing Definition at Parent MG ($DefinitionMgId) ---" -ForegroundColor Yellow

$alzScope = "/providers/Microsoft.Management/managementGroups/$DefinitionMgId"
$defUri   = "$alzScope/providers/Microsoft.Authorization/policyDefinitions/$($DefinitionName)?api-version=2021-06-01"

$policyRuleJson = @"
{
  "if": { "field": "tags['$TagName']", "exists": "false" },
  "then": {
    "effect": "modify",
    "details": {
      "roleDefinitionIds": [ "/providers/microsoft.authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f" ],
      "operations": [ { "operation": "add", "field": "tags['$TagName']", "value": "$TagValue" } ]
    }
  }
}
"@

$payload = @{
    properties = @{
        displayName = $DefinitionDisplayName
        description = $PolicyDescription
        mode        = "Indexed"
        metadata    = @{ category = "Tags" }
        policyRule  = ($policyRuleJson | ConvertFrom-Json)
    }
} | ConvertTo-Json -Depth 10

try {
    $resp = Invoke-AzRestMethod -Method PUT -Path $defUri -Payload $payload
    if ($resp.StatusCode -notin @(200, 201)) { throw "REST fail: $($resp.Content)" }
    $defResourceId = ($resp.Content | ConvertFrom-Json).id
    Write-Host " [OK] Definition '$DefinitionName' synced." -ForegroundColor Green
}
catch { throw " [ERROR] Definition deployment failed: $_" }

# 4) Assignments
Write-Host "`n--- STEP 2: Processing Deployments per Child MG ---" -ForegroundColor Yellow

foreach ($target in $DeploymentTargets) {
    $childMgId   = $target.MgId
    $assignName  = $target.AssignmentName
    $assignDisp  = $target.AssignmentDisplayName
    
    Write-Host "`nTarget: [$childMgId] -> Assignment: '$assignName'" -ForegroundColor Cyan

    # A) Validation checks
    if ($assignName.Length -gt 24) {
        Write-Host " [SKIP] Assignment Name '$assignName' is too long ($($assignName.Length) chars). Max 24 allowed." -ForegroundColor Red
        continue
    }
    if ($assignName -match "[^a-zA-Z0-9-]") {
        Write-Host " [SKIP] Assignment Name '$assignName' contains invalid characters. Only alphanumeric and hyphens allowed." -ForegroundColor Red
        continue
    }

    $childScope = "/providers/Microsoft.Management/managementGroups/$childMgId"
    $assignUri  = "$childScope/providers/Microsoft.Authorization/policyAssignments/$($assignName)?api-version=2021-06-01"

    # B) Assignment
    Write-Host " -> Assigning Policy..." -NoNewline
    $assignPayload = @{
        location = "westeurope"
        identity = @{ type = "SystemAssigned" }
        properties = @{
            displayName        = $assignDisp
            policyDefinitionId = $defResourceId
            scope              = $childScope
            notScopes          = $target.Exclusions
        }
    } | ConvertTo-Json -Depth 10

    try {
        $resp = Invoke-AzRestMethod -Method PUT -Path $assignUri -Payload $assignPayload
        if ($resp.StatusCode -notin @(200, 201)) { throw "API Error: $($resp.Content)" }
        
        $assignData  = $resp.Content | ConvertFrom-Json
        $principalId = $assignData.identity.principalId
        $assignResId = $assignData.id
        Write-Host " [OK] Identity Created." -ForegroundColor Green
    }
    catch { Write-Host " [FAIL] Assignment failed: $($_.Exception.Message)" -ForegroundColor Red; continue }

    # C) RBAC
    Write-Host " -> Granting Rights (Tag Contributor)..." -NoNewline
    Start-Sleep -Seconds 5
    try {
        New-AzRoleAssignment -ObjectId $principalId -RoleDefinitionName "Tag Contributor" -Scope $childScope -ErrorAction SilentlyContinue | Out-Null
        Write-Host " [OK]" -ForegroundColor Green
    }
    catch { Write-Host " [WARN] RBAC issue: $($_.Exception.Message)" -ForegroundColor Yellow }

    # D) Remediation
    Write-Host " -> Triggering Remediation..." -NoNewline
    try {
        $remName = "Fix-$(Get-Date -Format 'yyyyMMdd-HHmm')"
        $remTask = Start-AzPolicyRemediation -Name $remName -PolicyAssignmentId $assignResId -Scope $childScope -FailureThreshold 0.1 -ErrorAction Stop
        Write-Host " [OK] Task Started" -ForegroundColor Green
    }
    catch { Write-Host " [FAIL] Remediation start failed: $($_.Exception.Message)" -ForegroundColor Red }
}

Write-Host "`n*** Batch Deployment Completed ***" -ForegroundColor Cyan