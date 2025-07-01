<#
.SYNOPSIS
    Retrieves RBAC role assignments for a Service Principal across Azure subscriptions.

.DESCRIPTION
    This script retrieves the role assignments for a specific Service Principal (SPN) across
    either a predefined list of subscriptions or all subscriptions in the tenant if the 
    `-AllSubscriptions` switch is provided.

.HOW TO RUN
    - To check role assignments for a predefined list of subscriptions:
        .\Get-SPNRoleAssignments.ps1
    - To check role assignments for all subscriptions in the tenant:
        .\Get-SPNRoleAssignments.ps1 -AllSubscriptions    

.AUTHOR
    Luuk Ros

.LAST UPDATED
    28-11-2024

.NOTES
    - Ensure the Azure PowerShell module is installed and up to date.
    - The SPN Object ID must be provided in the script for accurate results.
    - The script requires the executing user to have sufficient permissions to read RBAC roles.
#>

param (
    [switch]$AllSubscriptions,
    [string]$SPNObjectId = "103756ff-b4c7-4735-96ef-e2fce8b2c43a" # Replace with your default SPN Object ID
)

# Predefined list of subscription IDs
$SubscriptionIds = @(
    "1b1d5253-7f5a-4359-aa8c-f2a8cfc09f67"
)

# Log in to Azure
$TenantId = "29ebd335-b1bc-4b1d-b89b-ea6e27378762" # Replace with your tenant ID
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionIds[0]

# Determine subscriptions to process
if ($AllSubscriptions) {
    # Get all subscriptions in the tenant
    $Subscriptions = Get-AzSubscription
    Write-Host "Retrieving roles for all subscriptions in the tenant." -ForegroundColor Green
} else {
    # Use predefined subscription list
    $Subscriptions = @()
    foreach ($SubId in $SubscriptionIds) {
        $Subscriptions += Get-AzSubscription -SubscriptionId $SubId
    }
    Write-Host "Retrieving roles for predefined subscriptions: $SubscriptionIds" -ForegroundColor Green
}

# Initialize an array to store results
$Results = @()

# Loop through each subscription
foreach ($Subscription in $Subscriptions) {
    try {
        # Set the context to the subscription
        Set-AzContext -Subscription $Subscription.Id -ErrorAction Stop

        # Fetch role assignments for the SPN
        $RoleAssignments = Get-AzRoleAssignment -ObjectId $SPNObjectId | Select-Object RoleDefinitionName, Scope

        # Add results to the array
        foreach ($RoleAssignment in $RoleAssignments) {
            $Results += [PSCustomObject]@{
                SubscriptionId   = $Subscription.Id
                SubscriptionName = $Subscription.Name
                RoleDefinition   = $RoleAssignment.RoleDefinitionName
                Scope            = $RoleAssignment.Scope
            }
        }
    } catch {
        Write-Warning "Failed to process subscription: $($Subscription.Id). Error: $_"
    }
}

# Output results in a table format
$Results | Format-Table -AutoSize

# Optionally export the results to a CSV file
$Results | Export-Csv -Path "RBAC_Roles_Overview.csv" -NoTypeInformation

Write-Host "Role assignments export completed. File saved as RBAC_Roles_Overview.csv" -ForegroundColor Green