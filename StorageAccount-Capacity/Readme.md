# Azure Storage Account Used Capacity Reporting Script

## Overview

This PowerShell script generates a report of used capacities for all storage accounts across multiple resource groups and subscriptions in Azure. It performs the following tasks:
- Retrieves all Azure subscriptions.
- Iterates through each resource group within each subscription.
- Collects used capacity metrics for each storage account.
- Outputs the results to a CSV file (`storage.csv`) with details such as storage account name, used capacity (in MB), resource group, and subscription.

## Usage

### 1. Install Azure PowerShell

To run this script, you need to have Azure PowerShell installed on your machine. Follow these steps to install it:

#### **Windows**

1. **Open PowerShell as Administrator**:
   - Search for PowerShell in the Start menu, right-click on Windows PowerShell, and select "Run as administrator."

2. **Install Azure PowerShell Module**:
   ```powershell
   Install-Module -Name Az -AllowClobber -Scope CurrentUser
   ```
   - This command installs the `Az` module, which is the new module for managing Azure resources.

3. **Verify Installation**:
   ```powershell
   Get-Module -Name Az -ListAvailable
   ```
   - Check that the `Az` module is installed correctly.

#### **macOS and Linux**

1. **Open Terminal**.

2. **Install Azure PowerShell Module**:
   ```bash
   # Install PowerShell if not already installed
   brew install --cask powershell

   # Open PowerShell
   pwsh

   # Install Azure PowerShell module
   Install-Module -Name Az -AllowClobber -Scope CurrentUser
   ```

3. **Verify Installation**:
   ```powershell
   Get-Module -Name Az -ListAvailable
   ```

### 2. Authenticate with Azure

Before running the script, you need to authenticate to Azure:

1. **Open PowerShell**.

2. **Sign In to Azure**:
   ```powershell
   Connect-AzAccount
   ```
   - This command opens a login prompt where you can enter your Azure credentials. If you are using a service principal or managed identity, use the following command instead:
     ```powershell
     $credential = Get-Credential
     Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant "<Tenant-ID>"
     ```
   - Replace `<Tenant-ID>` with your Azure tenant ID.

3. **Verify Your Account**:
   ```powershell
   Get-AzContext
   ```
   - This command displays the current context to ensure you are logged in correctly.

### 3. Run the Script

1. **Open PowerShell**:
   - Make sure you are in the directory where the script is saved.

2. **Execute the Script**:
   ```powershell
   .\YourScriptName.ps1
   ```
   - Replace `YourScriptName.ps1` with the name of your script file.

3. **Check the Output**:
   - The script generates a `storage.csv` file in the same directory where it is run. Review this file to see the used capacities and any errors encountered.

### Notes

- **Permissions**:
  - Ensure that your account has sufficient permissions to access storage account metrics and read data.

- **Scheduled Runs**:
  - Consider scheduling the script to run periodically using Task Scheduler (Windows) or cron jobs (macOS/Linux) if you need regular reporting.

- **Error Handling**:
  - Monitor the `storage.csv` for any errors or issues during execution and address them as needed.
