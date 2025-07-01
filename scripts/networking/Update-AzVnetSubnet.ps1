<#
.SYNOPSIS
    Updates a specified subnet in a virtual network to disable Private Link Service network policies.

.DESCRIPTION
    Connects to Azure, sets the subscription context, retrieves the specified virtual network,
    updates the subnet configuration by disabling Private Link Service network policies,
    and commits the change.

.AUTHOR
    Luuk Ros

.LAST UPDATED
    01-07-2025
#>

# Configuration
$TenantId          = "<your-tenant-id-here>"
$SubscriptionId    = "<your-subscription-id-here>"
$ResourceGroupName = "<your-resource-group-name-here>"
$VNetName          = "<your-vnet-name-here>"
$SubnetName        = "<your-subnet-name-here>"

# Authenticate & set context
Write-Host "*** Authenticating to Azure..." -ForegroundColor Cyan
Connect-AzAccount -TenantId $TenantId -SubscriptionId $SubscriptionId -ErrorAction Stop | Out-Null
Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# Retrieve the virtual network
Write-Host "*** Retrieving virtual network '$VNetName' in resource group '$ResourceGroupName'..." -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VNetName -ErrorAction SilentlyContinue
if (-not $vnet) {
    Write-Host "Virtual network '$VNetName' not found in resource group '$ResourceGroupName'." -ForegroundColor Red
    exit 1
}

# Retrieve the subnet configuration
Write-Host "`n*** Retrieving subnet '$SubnetName'..." -ForegroundColor Cyan
$subnetConfig = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $SubnetName -ErrorAction SilentlyContinue
if (-not $subnetConfig) {
    Write-Host "Subnet '$SubnetName' not found in virtual network '$VNetName'." -ForegroundColor Red
    exit 1
}

# Disable Private Link Service network policies
Write-Host "`n*** Disabling Private Link Service network policies on subnet '$SubnetName'..." -ForegroundColor Cyan
$addressPrefix = $subnetConfig.AddressPrefix
$vnet = Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name $SubnetName `
    -AddressPrefix $addressPrefix `
    -PrivateLinkServiceNetworkPolicies Disabled

# Commit the change
Write-Host "*** Applying update to virtual network '$VNetName'..." -ForegroundColor Cyan
try {
    $vnet | Set-AzVirtualNetwork -ErrorAction Stop | Out-Null
    Write-Host "Subnet '$SubnetName' updated successfully. Private Link Service network policies are now disabled." -ForegroundColor Green
}
catch {
    Write-Host "Failed to update subnet: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "*** All done. ***" -ForegroundColor Cyan