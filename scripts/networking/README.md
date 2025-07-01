# Networking Scripts

This directory contains PowerShell scripts to automate common Azure networking tasks, such as managing Private DNS zone VNet links and subnet configurations.

## Scripts

- **Add-PdnsVNetLink.ps1**  
  Ensures a virtual network link exists for all Private DNS zones in a specified resource group. Based on the Microsoft sample for joining Private DNS zones to a VNet.

- **Update-AzVNetSubnet.ps1**  
  Disables Private Link Service network policies on a specified subnet. Updates an existing VNet's subnet to allow Private Link resources.

## Usage

1. Copy the script(s) into this `networking/` folder.  
2. Open the script and update the **Configuration** block at the top with your:
   - Tenant ID  
   - Subscription ID  
   - Resource Group  
   - VNet name (and subnet name for `Update-AzVNetSubnet.ps1`)  
   - Any other variables.  
3. Run in an elevated PowerShell session:
   ```powershell
   .\Add-PdnsVNetLink.ps1
   # or
   .\Update-AzVNetSubnet.ps1
   ```