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
