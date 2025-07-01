<#
.SYNOPSIS
    Ensures a virtual network link exists for a specified VNet in all Private DNS zones.

.DESCRIPTION
    Scans all Private DNS zones in a given resource group. If a zone is not already linked to the specified VNet,
    it adds it to a list and then creates the missing link with a suffix-based name.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    02-06-2025
#>

# Configuration
$TenantId = "<your-tenant-id-here>"
$PDNSSubscriptionId = "<your-pdns-subscription-id-here>"
$PDNSResourceGroupName = "<your-pdns-resource-group-name-here>"
$VNetResourceId = "<your-vnet-resource-id-here>"
$LinkNameSuffix = "<your-link-name-suffix-here>"

# Authenticate & set context
Connect-AzAccount -TenantId $TenantId -SubscriptionId $PDNSSubscriptionId -ErrorAction Stop | Out-Null
Set-AzContext -SubscriptionId $PDNSSubscriptionId | Out-Null

# Retrieve all zones
$dnsZones = Get-AzPrivateDnsZone -ResourceGroupName $PDNSResourceGroupName

# Prepare zones that need linking
$zonesToLink = @()

foreach ($zone in $dnsZones) {
    if ($zone.Name -like "*privatelink.*") {
        Write-Host "*** Checking zone: $($zone.Name) ***" -ForegroundColor Cyan

        $links = @(Get-AzPrivateDnsVirtualNetworkLink -ZoneName $zone.Name -ResourceGroupName $PDNSResourceGroupName -ErrorAction SilentlyContinue)

        $linkedToVNet = $false
        foreach ($link in $links) {
            if ($link.VirtualNetworkId) {
                $linkId = $link.VirtualNetworkId
                if ($linkId.ToLower() -like "$($VNetResourceId.ToLower())*") {
                    $linkedToVNet = $true
                    break
                }
            }
        }

        if (-not $linkedToVNet) {
            Write-Host "→ Zone '$($zone.Name)' is missing the VNet link." -ForegroundColor Yellow
            $zonesToLink += $zone
        }
        else {
            Write-Host "✔ Zone '$($zone.Name)' already linked to VNet." -ForegroundColor Green
        }
    }
    else {
        Write-Host "*** Skipping non-privatelink zone: $($zone.Name) ***" -ForegroundColor Gray
    }
}

# Create links for all zones that need it
foreach ($zone in $zonesToLink) {
    if ($zone.Name -match "privatelink\.([^.]+)\.") {
        $segment = $matches[1]
        $linkName = "$segment$LinkNameSuffix"

        Write-Host "*** Creating link '$linkName' in zone '$($zone.Name)' ***" -ForegroundColor Yellow
        try {
            New-AzPrivateDnsVirtualNetworkLink `
                -ZoneName $zone.Name `
                -ResourceGroupName $PDNSResourceGroupName `
                -Name $linkName `
                -VirtualNetworkId $VNetResourceId `
                -EnableRegistration:$false -ErrorAction Stop | Out-Null

            Write-Host "Link '$linkName' created successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to create link for '$($zone.Name)': $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Warning "Could not parse link name from zone '$($zone.Name)'. Skipping."
    }
}

Write-Host "*** All done. Missing links (if any) have been created. ***" -ForegroundColor Cyan