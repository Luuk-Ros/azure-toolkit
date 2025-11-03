<#
.SYNOPSIS
    Detects Windows Server Update Services (WSUS) role on VMs within a given Azure subscription.

.DESCRIPTION
    Connects to Azure and checks each Windows VM in the specified subscription
    to determine if the WSUS Server Role (UpdateServices) is installed.
    Uses Azure RunCommand to remotely query the Windows features on each VM.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    31-10-2025
#>

# Configuration
$TenantId       = "<tenant-id-here>"
$SubscriptionId = "<your-subscription-id-here>"

# Authenticate
Write-Host "*** Connecting to Azure with Device Code ***" -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

Write-Host "`n*** Checking for WSUS role (UpdateServices) in subscription: $SubscriptionId ***" -ForegroundColor Cyan

$VMs = Get-AzVM -Status | Where-Object {
    $_.StorageProfile.OSDisk.OSType -eq "Windows" -and
    $_.PowerState -eq "VM running" -and
    ($_.StorageProfile.ImageReference.Offer -notmatch "windows-10") -and
    ($_.StorageProfile.ImageReference.Offer -notmatch "windows-11") -and
    ($_.StorageProfile.ImageReference.Offer -notmatch "AzureVirtualDesktop")
}

if ($VMs.Count -eq 0) {
    Write-Host "No running Windows VMs found in this subscription." -ForegroundColor Yellow
    exit
}

Write-Host "Found $($VMs.Count) running Windows VM(s)" -ForegroundColor Green

# Initialize results array
$results = @()

# PowerShell script to execute remotely
$remoteScript = @'
$feature = Get-WindowsFeature -Name UpdateServices -ErrorAction SilentlyContinue
if ($feature -and $feature.InstallState -eq "Installed") {
    Write-Output "Installed"
} else {
    Write-Output "NotInstalled"
}
'@

# Loop through VMs
foreach ($vm in $VMs) {
    Write-Host "`n→ Checking VM: $($vm.Name)" -ForegroundColor Yellow
    try {
        $response = Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName `
                                          -Name $vm.Name `
                                          -CommandId "RunPowerShellScript" `
                                          -ScriptString $remoteScript `
                                          -ErrorAction Stop

        $status = $response.Value.Message.Trim()

        if ($status -eq "Installed") {
            Write-Host "✔ WSUS role detected on $($vm.Name)" -ForegroundColor Green
        } else {
            Write-Host "→ No WSUS role found on $($vm.Name)" -ForegroundColor Gray
        }

        $results += [PSCustomObject]@{
            VMName          = $vm.Name
            ResourceGroup   = $vm.ResourceGroupName
            Location        = $vm.Location
            PowerState      = $vm.PowerState
            WSUSInstalled   = $status
        }
    }
    catch {
        Write-Host "✗ Error checking VM $($vm.Name): $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{
            VMName          = $vm.Name
            ResourceGroup   = $vm.ResourceGroupName
            Location        = $vm.Location
            PowerState      = $vm.PowerState
            WSUSInstalled   = "Error"
        }
    }
}

# Summary
Write-Host "`n*** WSUS Scan Complete ***" -ForegroundColor Cyan

$installed = $results | Where-Object { $_.WSUSInstalled -eq "Installed" }
if ($installed.Count -gt 0) {
    Write-Host "⚠️  Found $($installed.Count) VM(s) with WSUS role installed:" -ForegroundColor Yellow
    $installed | Format-Table -Property VMName, ResourceGroup, Location -AutoSize
} else {
    Write-Host "No WSUS role detected on any VM." -ForegroundColor Green
}

# Export option
$export = Read-Host "`nExport results to CSV? (Y/N)"
if ($export -eq 'Y' -or $export -eq 'y') {
    $exportPath = "WSUS_ScanResults_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $results | Export-Csv -Path $exportPath -NoTypeInformation
    Write-Host "✔ Exported to: $exportPath" -ForegroundColor Green
}

Write-Host "`nScript execution complete." -ForegroundColor Cyan
