# AzureAD User Report Script

## Overview

This PowerShell script retrieves information about Azure AD users and generates a report in CSV format. The report includes details about user account status, group memberships, and on-premises distinguished names.

## Usage

### 1. Install AzureAD Module

To run this script, you need to have the AzureAD PowerShell module installed.

#### **Windows**

1. **Open PowerShell as Administrator**:
   - Search for PowerShell in the Start menu, right-click on Windows PowerShell, and select "Run as administrator."

2. **Install AzureAD Module**:
   ```powershell
   Install-Module -Name AzureAD -Scope CurrentUser
   ```

3. **Verify Installation**:
   ```powershell
   Get-Module -Name AzureAD -ListAvailable
   ```

#### **macOS and Linux**

1. **Open Terminal**.

2. **Install PowerShell**:
   - **macOS**:
     ```bash
     brew install --cask powershell
     ```
   - **Linux**:
     Follow the [official installation guide](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux).

3. **Open PowerShell**:
   ```bash
   pwsh
   ```

4. **Install AzureAD Module**:
   ```powershell
   Install-Module -Name AzureAD -Scope CurrentUser
   ```

5. **Verify Installation**:
   ```powershell
   Get-Module -Name AzureAD -ListAvailable
   ```

### 2. Authenticate with Azure

Before running the script, you need to authenticate to Azure:

1. **Open PowerShell**.

2. **Sign In to Azure**:
   ```powershell
   Connect-AzureAD
   ```
   - This command opens a login prompt where you can enter your Azure credentials.

3. **Verify Your Account**:
   ```powershell
   Get-AzureADSignedInUser
   ```
   - This command displays the current user to ensure you are logged in correctly.

### 3. Prepare Your User List

1. **Create or Update `list.csv`**:
   - The CSV file should contain a list of users with at least the `userPrincipalName` column.
   - Example format:
     ```csv
     userPrincipalName
     user1@example.com
     user2@example.com
     ```

### 4. Run the Script

1. **Open PowerShell**:
   - Ensure you are in the directory where the script is saved.

2. **Execute the Script**:
   ```powershell
   .\YourScriptName.ps1
   ```
   - Replace `YourScriptName.ps1` with the name of your script file.

3. **Check the Output**:
   - The script generates a `ScriptReport.csv` file in the same directory. Review this file to see the actions taken and any errors encountered.

## Script Details

### Script Content

```powershell
# Import the AzureAD module
# Connect-AzureAD

# Import the list of users from a CSV file
$users_list = Import-Csv "list.csv"

# Initialize the CSV file for report output with headers
"UserName`tIsEnabled`tGroups`tOnPremisesDistinguishedName" >> "ScriptReport.csv"

# Iterate through each user in the imported list
ForEach ($user in $users_list) {
    try {
        # Retrieve the User Principal Name (UPN) from the current user object
        $upn = $user.userPrincipalName

        # Get the on-premises distinguished name for the user
        $onPremisesDistinguishedName = (Get-AzureADUser -SearchString $upn | Select-Object -ExpandProperty ExtensionProperty)["onPremisesDistinguishedName"]
        
        # Check if the user account is enabled
        $isEnabled = (Get-AzureADUser -ObjectId $upn).AccountEnabled

        # Retrieve the list of groups the user is a member of
        $groupsList = (Get-AzureADUser -SearchString $upn | Get-AzureADUserMembership | % {
            Get-AzureADObjectByObjectId -ObjectId $_.ObjectId | Select-Object DisplayName, ObjectType, MailEnabled, SecurityEnabled, ObjectId
        }).DisplayName | Out-String

        # Format the groups list to replace newline characters with delimiters
        $formattedGroupsList = $groupsList -replace "`n", "|||" -replace "`r", ""

        # Check if the user account is disabled and update the distinguished name accordingly
        if (-not $isEnabled) {
            $onPremisesDistinguishedName = "Disabled account"
        }

        # Write user information to the report CSV
        "$upn`t$isEnabled`t$formattedGroupsList`t$onPremisesDistinguishedName" >> "ScriptReport.csv"
    }
    catch {
        # Handle cases where the user account does not exist or the UPN is incorrect
        "$upn`tAccountDoesNotExist OR UPN is Incorrect`tNA`tNA" >> "ScriptReport.csv"
    }
}
```

## Notes

- Ensure `list.csv` is correctly formatted and located in the same directory as the script.
- Modify the script as needed to fit your environment and requirements.

