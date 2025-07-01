<#
.SYNOPSIS
    Purges Event logs for specified hostnames from an Azure Log Analytics workspace.

.DESCRIPTION
    - Uses the Azure CLI (`az`) to authenticate and select the target subscription.
    - Registers the Microsoft.OperationalInsights provider if needed.
    - Obtains an ARM access token for API calls.
    - Calculates a cutoff timestamp (90 days ago by default).
    - Loops through each hostname and sends a purge request to the Operational Insights REST API,
      targeting the `Event` table and deleting records older than the cutoff.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    01-07-2025
#>

# Configuration
$SubscriptionId    = "<your-subscription-id-here>"
$ResourceGroupName = "<your-resource-group-name-here>"
$WorkspaceName     = "<your-workspace-name-here>"
$DaysToKeep        = 90 # Data older than this will be purged
$Hostnames         = @(
    "<your-hostname-1-here>",
    "<your-hostname-2-here>"
)

# 1) Authenticate and set subscription
Write-Host "`n*** Logging in with Azure CLI..." -ForegroundColor Cyan
az login --only-show-errors | Out-Null

Write-Host "*** Setting subscription to $SubscriptionId..." -ForegroundColor Cyan
az account set --subscription $SubscriptionId

# 2) Ensure Operational Insights provider is registered
Write-Host "*** Registering Microsoft.OperationalInsights provider if needed..." -ForegroundColor Cyan
az provider register --namespace Microsoft.OperationalInsights --wait

# 3) Build purge URI and obtain access token
$purgeUri   = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/purge?api-version=2023-09-01"
$accessToken = az account get-access-token --resource https://management.azure.com --query accessToken --output tsv

# 4) Calculate cutoff timestamp
$cutoffDate = (Get-Date).AddDays(-$DaysToKeep).ToString("yyyy-MM-ddTHH:mm:ssZ")

# 5) Loop through hostnames and send purge requests
foreach ($hostname in $Hostnames) {
    Write-Host "*** Purging logs for hostname: $hostname (older than $cutoffDate)..." -ForegroundColor Cyan

    $body = @{
        table   = "Event"
        filters = @(
            @{ column = "Computer";       operator = "=="; value = $hostname },
            @{ column = "TimeGenerated"; operator = "<";  value = $cutoffDate }
        )
    } | ConvertTo-Json -Depth 4

    try {
        Invoke-RestMethod -Method Post -Uri $purgeUri -Headers @{
            "Authorization" = "Bearer $accessToken"
            "Content-Type"  = "application/json"
        } -Body $body -ErrorAction Stop

        Write-Host "Purge request for '$hostname' submitted successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to submit purge for '$hostname': $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "*** All purge requests completed. ***" -ForegroundColor Cyan
