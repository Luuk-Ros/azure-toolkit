<#
.SYNOPSIS
    Installs the AzFilesHybrid module and configures a storage account for Active Directory authentication.

.DESCRIPTION
    Based on the Microsoft “Join-AzStorageAccountForAuth” sample, this script unblocks the execution policy,
    copies the AzFilesHybrid module into the PowerShell module path, imports the module, authenticates to Azure,
    selects the target subscription, registers the specified storage account under the given OU in Active Directory
    with the chosen encryption type, optionally enables AES256 authentication, and runs a debug check.
.REQUIREMENTS
    - PowerShell 5.1 or later
    - AzFilesHybrid psd1 and psm1 files in the same directory as this script
    - CopyToPSPath.ps1 script in the same directory as this script

.AUTHOR
    Luuk Ros

.LAST UPDATED
    01-07-2025
#>

# Configuration
$TenantId                 = "<your-tenant-id-here>"
$SubscriptionId           = "<your-subscription-id-here>"
$ResourceGroupName        = "<your-resource-group-name-here>"
$StorageAccountName       = "<your-storage-account-name-here>"
$DomainAccountType        = "ComputerAccount"      # or 'ServiceLogonAccount'
$OuDistinguishedName      = "<your-ou-distinguished-name-here>" # e.g., "OU=StorageAccounts,DC=domain,DC=com"
$EncryptionType           = "AES256,RC4"               # 'AES256', 'RC4', or 'AES256,RC4'

# 1) Allow script/module import
Write-Host "*** Setting execution policy..." -ForegroundColor Cyan
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force

# 2) Copy AzFilesHybrid module into PS path
Write-Host "*** Copying AzFilesHybrid module into module path..." -ForegroundColor Cyan
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$copyScript = Join-Path $scriptDir 'CopyToPSPath.ps1'
if (-Not (Test-Path $copyScript)) {
    Write-Error "CopyToPSPath.ps1 not found in $scriptDir"
    exit 1
}
& $copyScript

# 3) Import the module
Write-Host "*** Importing AzFilesHybrid module..." -ForegroundColor Cyan
Import-Module -Name AzFilesHybrid -ErrorAction Stop

# 4) Authenticate and select subscription
Write-Host "*** Authenticating to Azure..." -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -ErrorAction Stop | Out-Null

Write-Host "*** Selecting subscription $SubscriptionId..." -ForegroundColor Cyan
Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null

# 5) Register storage account for AD auth
Write-Host "*** Registering storage account '$StorageAccountName' for AD authentication..." -ForegroundColor Cyan
try {
    Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -DomainAccountType $DomainAccountType `
        -OrganizationalUnitDistinguishedName $OuDistinguishedName `
        -EncryptionType $EncryptionType -ErrorAction Stop | Out-Null

    Write-Host "Storage account '$StorageAccountName' registered successfully." -ForegroundColor Green
}
catch {
    Write-Error "Failed to register storage account: $_"
    exit 1
}

# 6) Enable AES256 if requested
if ($EncryptionType -match 'AES256') {
    Write-Host "*** Enabling AES256 authentication..." -ForegroundColor Cyan
    try {
        Update-AzStorageAccountAuthForAES256 `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $StorageAccountName -ErrorAction Stop | Out-Null

        Write-Host "AES256 authentication enabled." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to enable AES256 authentication: $_"
        exit 1
    }
}
else {
    Write-Host "*** Skipping AES256 update (EncryptionType = '$EncryptionType')." -ForegroundColor Yellow
}

# 7) Run debug checks
Write-Host "*** Running debug checks on storage account authentication..." -ForegroundColor Cyan
try {
    Debug-AzStorageAccountAuth `
        -StorageAccountName $StorageAccountName `
        -ResourceGroupName $ResourceGroupName `
        -Verbose -ErrorAction Stop

    Write-Host "Debug checks completed successfully." -ForegroundColor Green
}
catch {
    Write-Error "Debug checks failed: $_"
    exit 1
}

Write-Host "*** Script completed successfully. ***" -ForegroundColor Cyan