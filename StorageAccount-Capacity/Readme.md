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

