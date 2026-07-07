<#
.SYNOPSIS
    Searches for custom RBAC roles across all subscriptions or in a specific subscription.

.DESCRIPTION
    Connects to Azure and searches for custom role definitions. Can filter by role name pattern
    and search across all accessible subscriptions or target a specific one.

.PARAMETER TenantId
    The Azure Active Directory tenant ID to authenticate against.

.PARAMETER SubscriptionId
    The subscription ID to search. If not specified, all enabled subscriptions are searched.

.PARAMETER SearchPattern
    Wildcard pattern to filter role names, e.g. '*MyRole*'. Defaults to '*'.

.EXAMPLE
    .\Get-CustomRoles.ps1
    Searches all enabled subscriptions for custom roles.

.EXAMPLE
    .\Get-CustomRoles.ps1
    # Set $SearchPattern = "*Reader*" to filter by name pattern.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    20-10-2025
#>

# Configuration
$TenantId = "<tenant-id-here>"
$SearchPattern = "*<role-name-pattern>*"
$SubscriptionId = "<your-subscription-id-here>"

# Authenticate met device code
Write-Host "*** Connecting to Azure with Device Code ***" -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# Determine which subscriptions to search
if ($TargetSubscriptionId) {
    Write-Host "*** Searching in specific subscription: $TargetSubscriptionId ***" -ForegroundColor Cyan
    $subscriptions = @(Get-AzSubscription -SubscriptionId $TargetSubscriptionId)
} else {
    Write-Host "*** Retrieving all accessible subscriptions ***" -ForegroundColor Cyan
    $subscriptions = Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' }
    Write-Host "Found $($subscriptions.Count) enabled subscriptions" -ForegroundColor Green
}

# Search for custom roles
$foundRoles = @()

foreach ($sub in $subscriptions) {
    Write-Host "`n*** Checking subscription: $($sub.Name) ($($sub.Id)) ***" -ForegroundColor Yellow
    
    try {
        Set-AzContext -SubscriptionId $sub.Id -ErrorAction Stop | Out-Null
        
        # Get all custom roles in this subscription
        $customRoles = Get-AzRoleDefinition | Where-Object { 
            $_.IsCustom -eq $true -and 
            $_.Name -like $SearchPattern 
        }
        
        if ($customRoles.Count -gt 0) {
            Write-Host "✔ Found $($customRoles.Count) matching custom role(s)" -ForegroundColor Green
            
            foreach ($role in $customRoles) {
                $foundRoles += [PSCustomObject]@{
                    SubscriptionName = $sub.Name
                    SubscriptionId   = $sub.Id
                    RoleName         = $role.Name
                    RoleId           = $role.Id
                    Description      = $role.Description
                    AssignableScopes = $role.AssignableScopes -join "; "
                }
                
                Write-Host "  → Role: $($role.Name)" -ForegroundColor Cyan
                Write-Host "    ID: $($role.Id)" -ForegroundColor Gray
                Write-Host "    Description: $($role.Description)" -ForegroundColor Gray
            }
        } else {
            Write-Host "→ No matching custom roles found" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "✗ Error accessing subscription: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n*** Search Complete ***" -ForegroundColor Cyan
if ($foundRoles.Count -gt 0) {
    Write-Host "Found $($foundRoles.Count) total custom role(s) matching pattern '$SearchPattern'" -ForegroundColor Green
    
    # Display summary table
    Write-Host "`n=== Summary Table ===" -ForegroundColor Cyan
    $foundRoles | Format-Table -Property SubscriptionName, RoleName, RoleId -AutoSize
    
    # Export option
    $export = Read-Host "`nExport results to CSV? (Y/N)"
    if ($export -eq 'Y' -or $export -eq 'y') {
        $exportPath = "CustomRoles_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        $foundRoles | Export-Csv -Path $exportPath -NoTypeInformation
        Write-Host "✔ Exported to: $exportPath" -ForegroundColor Green
    }
} else {
    Write-Host "No custom roles found matching pattern '$SearchPattern'" -ForegroundColor Yellow
}
