# Azure VM Tagging Script

## Overview

This PowerShell script is designed to automate the process of tagging Azure Virtual Machines (VMs) based on data provided in a CSV file. The script updates tags on specified VMs and generates a report detailing the success or failure of each operation.

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

### 3. Prepare Your Tagging Data

1. **Create or Update `taggingvalue.csv`**:
   - The CSV file should contain the following columns: `sub`, `name`, `rg`, `key`, `value`.
   - Example format:
     ```csv
     sub,name,rg,key,value
     SubscriptionName,VM1,ResourceGroup1,Environment,Production
     SubscriptionName,VM2,ResourceGroup2,Owner,JohnDoe
     ```

### 4. Run the Script

1. **Save the Script**:
   - Save the provided script in a `.ps1` file, e.g., `TagVMScript.ps1`.

2. **Open PowerShell**:

3. **Execute the Script**:
   ```powershell
   .\TagVMScript.ps1
   ```
   - Ensure the `taggingvalue.csv` is in the same directory as the script.

4. **Check the Output**:
   - The script generates a `tagScriptReport.csv` file in the same directory, logging the status of each tagging operation.
