# Get all Azure subscriptions available in the current context and select only the Name property
$sub = Get-AzSubscription | select Name

# Create a CSV file named 'storage.csv' with headers
"Name`tCapacity`tRG`tSubscription" >> "storage.csv"

# Loop through each subscription
$sub | foreach {
    
    # Set the context to the current subscription
    Set-Azcontext -Subscription $_.Name
    
    # Store the name of the current subscription
    $currentSub = $_.Name

    # Get all resource groups within the current subscription and select only the ResourceGroupName property
    $RGs = Get-AzResourceGroup | select ResourceGroupName
    
    # Loop through each resource group
    $RGs | foreach {

        # Store the name of the current resource group
        $currentRG = $_.ResourceGroupName

        # Get all storage accounts within the current resource group and select only the StorageAccountName property
        $StorageAccounts = Get-AzStorageAccount -ResourceGroupName $currentRG | Select StorageAccountName
        
        # Loop through each storage account
        $StorageAccounts | foreach {

            # Store the name of the current storage account
            $StorageAccount = $_.StorageAccountName

            # Get the Resource ID of the current storage account
            $currentSAID = (Get-AzStorageAccount -ResourceGroupName $currentRG -AccountName $StorageAccount).Id

            # Retrieve the 'UsedCapacity' metric for the storage account
            $usedCapacity = (Get-AzMetric -ResourceID $currentSAID -MetricName "UsedCapacity").Data

            # Convert the used capacity from bytes to megabytes (MB)
            $usedCapacityInMB = $usedCapacity.Average / 1024 / 1024

            # Append the storage account name, used capacity, resource group name, and subscription name to the CSV file
            "$StorageAccount`t$usedCapacityInMB`t$currentRG`t$currentSub" >> "storage.csv"
        }
    }
}
