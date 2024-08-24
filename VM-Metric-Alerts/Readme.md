
# Azure VM Alerting Script

## Overview

This PowerShell script automates the creation of Azure Monitor alert rules for Azure Virtual Machines (VMs) based on data provided in a CSV file. The script sets up various performance and availability metrics as alert conditions and generates a report detailing the success or failure of each operation.

## Usage

### 1. Prerequisites

To run this script, ensure that you have the Azure PowerShell module installed and are authenticated to your Azure subscription.

#### Install Azure PowerShell Module

1. **Open PowerShell as Administrator**:
   - Search for PowerShell in the Start menu, right-click, and select "Run as administrator."

2. **Install the Azure PowerShell Module**:
   ```powershell
   Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
   ```

3. **Verify Installation**:
   ```powershell
   Get-Module -Name Az -ListAvailable
   ```

### 2. Authenticate with Azure

Before running the script, authenticate to your Azure account:

1. **Open PowerShell**.

2. **Sign In to Azure**:
   ```powershell
   Connect-AzAccount
   ```
   - This command opens a login prompt for your Azure credentials.

3. **Verify Your Subscription**:
   ```powershell
   Get-AzSubscription
   ```
   - This command lists the available subscriptions in your account.

### 3. Prepare Your Alerting Data

1. **Create or Update `vms.csv`**:
   - The CSV file should contain the following columns: `sub`, `name`, `rg`, `tier`.
   - Example format:
     ```csv
     sub,name,rg,tier
     SubscriptionName,VM1,ResourceGroup1,Production
     SubscriptionName,VM2,ResourceGroup2,Development
     ```

### 4. Run the Script

1. **Save the Script**:
   - Save the provided script in a `.ps1` file, e.g., `AlertScript.ps1`.

2. **Open PowerShell**:

3. **Execute the Script**:
   ```powershell
   .\AlertScript.ps1
   ```
   - Ensure the `vms.csv` is in the same directory as the script.

4. **Check the Output**:
   - The script generates an `AlertScriptReport.csv` file in the same directory, logging the status of each alert rule creation operation.
