# Storage Scripts

This directory contains PowerShell scripts and modules for configuring Azure Storage account integration with Active Directory and testing connectivity.

**Note:**  
- `Join-AzStorageAccount.ps1` depends on the **AzFilesHybrid** module.  
- Use `CopyToPSPath.ps1` to install the module before running the join script.

## Files

- **AzFilesHybrid.psd1**  
  PowerShell module manifest for AzFilesHybrid.

- **AzFilesHybrid.psm1**  
  Implementation of the AzFilesHybrid module enabling AD-based authentication for Azure Files.

- **CopyToPSPath.ps1**  
  Copies the AzFilesHybrid module files into one of the paths listed in `$env:PSModulePath`.

- **Join-AzStorageAccount.ps1**  
  Registers an Azure Storage account with Active Directory for identity-based authentication.  
  Automatically invokes `CopyToPSPath.ps1` if the module isn’t already installed.

- **Test-AzStorageConnection.ps1**  
  Validates connectivity to a specified Azure Storage account and file share endpoints.

## Usage

1. **Install & Import AzFilesHybrid Module**  
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
   .\CopyToPSPath.ps1
   Import-Module AzFilesHybrid
   ``` 
2. Register Storage Account with AD

- Open `Join-AzStorageAccount.ps1` and update its Configuration block:
    - Tenant ID
    - Subscription ID
    - Resource Group
    - Storage account name
    - OU Distinguished Name
    - Encryption type (AES256 or RC4)
- Run:
    ```powershell
    .\Join-AzStorageAccount.ps1
    ```
3. Test Connectivity
 - Open `Test-AzStorageConnection.ps1` and confgiure the Configuration Block.
 - Run:
    ```powershell
    .\Test-AzStorageConnection.ps1
    ```