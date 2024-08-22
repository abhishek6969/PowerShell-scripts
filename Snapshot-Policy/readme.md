# Azure Snapshot Management Script


## Overview

This PowerShell script manages Azure snapshots across multiple subscriptions. It performs the following tasks:
- Retrieves all Azure subscriptions.
- Excludes specified subscriptions from processing.
- Deletes snapshots based on certain criteria, including tagging and age.

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

### 3. Update the Script

- **Open the Script**:
  - Open the script file in your text editor.

- **Modify Exclusions**:
  - Update the `$ExclusionIDs` hashtable in the script with the subscription IDs you want to exclude from processing. For example:
    ```powershell
    $ExclusionIDs = @{
        "subscription-id-1" = $true
        "subscription-id-2" = $true
    }
    ```
  - Add the subscription IDs you wish to exclude. 

### 4. Run the Script

1. **Open PowerShell**:
   - Make sure you are in the directory where the script is saved.

2. **Execute the Script**:
   ```powershell
   .\YourScriptName.ps1
   ```
   - Replace `YourScriptName.ps1` with the name of your script file.

3. **Check the Output**:
   - The script generates a `scriptReport.csv` file in the same directory where it is run. Review this file to see the actions taken and any errors encountered.

### Notes

- **Permissions**:
  - Ensure that your account has sufficient permissions to manage Azure snapshots and perform deletions.

- **Scheduled Runs**:
  - Consider scheduling the script to run periodically using Task Scheduler (Windows) or cron jobs (macOS/Linux) if you need regular snapshot management.

- **Error Handling**:
  - Monitor the `scriptReport.csv` for any errors or issues during execution and address them as needed.

By following these steps, you can effecti
## Overview

This PowerShell script manages Azure snapshots across multiple subscriptions. It performs the following tasks:
- Retrieves all Azure subscriptions.
- Excludes specified subscriptions from processing.
- Deletes snapshots based on certain criteria, including tagging and age.

## Script Details

### 1. Fetch Subscriptions

```powershell
$subscriptions = Get-AzSubscription
```
Retrieves all Azure subscriptions.

### 2. Prepare CSV Report

```powershell
"SnapshotName`tSubscription`tActionTaken`tErrorMessage" >> "scriptReport.csv"
```
Initializes the CSV file to record actions taken by the script.

### 3. Define Exclusions

```powershell
$ExclusionIDs = @{ 
    # Add subscription IDs to exclude here
}
```
A hashtable for defining subscriptions that should be excluded from processing.

### 4. Process Subscriptions

```powershell
foreach ($sub in $subscriptions) {
    # Logic for processing each subscription
}
```
Loops through each subscription to manage snapshots.

### 5. Check for Exclusions

```powershell
if (-not $ExclusionIDs.ContainsKey($subID)) {
    # Logic for processing non-excluded subscriptions
}
```
Checks if the subscription is part of the exclusion list.

### 6. Manage Snapshots

```powershell
$snapshots = Get-AzSnapshot
foreach ($snapshot in $snapshots) {
    # Logic for managing each snapshot
}
```
Fetches and iterates through snapshots to apply actions based on tagging and age.

### 7. Handle Tagged Snapshots

```powershell
if ($tag.ContainsKey("Exception")) {
    # Logic for handling snapshots with the "Exception" tag
}
```
Checks if snapshots are tagged with "Exception" and deletes them if they surpass the tagged deletion date.

### 8. Handle Non-Tagged Snapshots

```powershell
if ($snapshotTimeCreatedDate -lt $deletionDate) {
    # Logic for handling non-tagged snapshots older than the specified date
}
```
Deletes snapshots that are older than the defined threshold.

## Error Handling

- Errors during snapshot deletion are logged to the CSV file with details about the failure.



## Notes

- Ensure the CSV file (`scriptReport.csv`) is correctly path-specified if running in a different directory.
- Modify the `$deletionDate` as needed based on your retention policy.
