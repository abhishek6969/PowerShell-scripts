# Azure VM Monitoring Script

## Overview

This PowerShell script monitors the status of Azure Virtual Machines (VMs) based on data provided in a CSV file. It checks the VM's running status, the readiness of the VM agent, and installs the appropriate Azure Monitor agent based on the OS type. The script also associates the VM with a specified Data Collection Rule (DCR).

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

### 3. Prepare Your Monitoring Data

1. **Create or Update `vmi.csv`**:
   - The CSV file should contain the following columns: `name`, `rg`, `subscription`.
   - Example format:
     ```csv
     name,rg,subscription
     VM1,ResourceGroup1,SubscriptionName
     VM2,ResourceGroup2,SubscriptionName
     ```

### 4. Run the Script

1. **Save the Script**:
   - Save the provided script in a `.ps1` file, e.g., `MonitorVMScript.ps1`.

2. **Open PowerShell**:

3. **Execute the Script**:
   ```powershell
   .\MonitorVMScript.ps1
   ```
   - Ensure the `vmi.csv` is in the same directory as the script.

4. **Check the Output**:
   - The script logs the status of each VM, including the running state, VM agent readiness, and installation status of the Azure Monitor agent.
