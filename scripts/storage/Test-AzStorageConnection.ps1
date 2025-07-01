<#
.SYNOPSIS
    Retrieves identity-based authentication settings for a specified Azure Storage account.

.DESCRIPTION
    Authenticates to Azure, selects the target subscription, fetches the specified storage account,
    and outputs its Directory Service Options and Active Directory properties for Azure Files
    identity-based authentication.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    01-07-2025
#>

# Configuration
$TenantId            = "<your-tenant-id-here>"
$SubscriptionId      = "<your-subscription-id-here>"
$ResourceGroupName   = "<your-resource-group-name-here>"
$StorageAccountName  = "<your-storage-account-name-here>"

# 1) Authenticate & select subscription
Write-Host "*** Authenticating to Azure..." -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -ErrorAction Stop | Out-Null

Write-Host "*** Selecting subscription $SubscriptionId..." -ForegroundColor Cyan
Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null

# 2) Retrieve the storage account
Write-Host "*** Retrieving storage account '$StorageAccountName' in resource group '$ResourceGroupName'..." -ForegroundColor Cyan
try {
    $storageAccount = Get-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName -ErrorAction Stop
}
catch {
    Write-Host "Failed to retrieve storage account: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 3) Output Directory Service options
Write-Host "*** Azure Files Directory Service Options:" -ForegroundColor Green
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions

# 4) Output Active Directory properties
Write-Host "*** Azure Files Active Directory Properties:" -ForegroundColor Green
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties

Write-Host "*** Script completed successfully. ***" -ForegroundColor Cyan