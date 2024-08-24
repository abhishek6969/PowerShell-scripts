# Import the CSV file containing tagging data
$source = Import-Csv taggingvalue.csv

# Create the header for the output CSV file
"Name`tSubscription`tResourceGroup`tStatus`tTaggedValue`tErrorMessage" >> "tagScriptReport.csv"

# Iterate through each record in the source CSV
foreach ($record in $source) {
    # Extract variables from the CSV record
    $subscriptionName = $record.sub
    $vmName = $record.name
    $resourceGroup = $record.rg
    $tagValue = $record.value
    
    # Get the subscription ID based on the subscription name
    $subscriptionID = Get-AzSubscription -SubscriptionName $subscriptionName
    
    # Set the context to the current subscription
    Set-AzContext -Subscription $subscriptionID
    
    # Get the VM resource based on name and resource group
    $vm = Get-AzResource -Name $vmName -ResourceGroupName $resourceGroup |
        Where-Object { $_.Type -eq "Microsoft.Compute/virtualMachines" }
    
    # Prepare the tag to be updated
    $tags = @{$record.key = $record.value}
    
    # Update the tag on the VM resource
    Update-AzTag -ResourceId $vm.ResourceId -Tag $tags -Operation Delete -ErrorAction SilentlyContinue | Out-Null
    
    # Check if the tag update was successful
    if ($?) {
        $statusMessage = "UN-Tagged Successfully"
        $errorMessage = "NA"
    } else {
        $statusMessage = "Errored Out"
        $errorMessage = $Error[0].Exception.Message.Replace("`n", ", ").Replace("`r", ", ")
    }
    
    # Write the result to the output CSV file
    "$vmName`t$subscriptionName`t$resourceGroup`t$statusMessage`t$tagValue`t$errorMessage" >> "tagScriptReport.csv"
}
