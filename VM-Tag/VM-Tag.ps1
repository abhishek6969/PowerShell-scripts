# Import the CSV file containing tagging data
$source = Import-Csv taggingvalue.csv

# Create the header for the output CSV file
"Name`tSubscription`tRG`tStatus`tTaggedValue`tErrorMessage" >> "tagScriptReport.csv"

# Iterate through each record in the source CSV
foreach ($s in $source) {
    # Extract variables from the CSV record
    $subscription = $s.sub
    $vmName = $s.name
    $resourceGroup = $s.rg
    $tagValue = $s.value
    $subscriptionID = Get-AzSubscription -SubscriptionName $subscription

    # Set the context to the current subscription
    Set-AzContext -Subscription $subscriptionID

    # Get the VM resource based on name and resource group
    $vm = Get-AzResource -Name $vmName -ResourceGroupName $resourceGroup |
        Where-Object { $_.Type -eq "Microsoft.Compute/virtualMachines" }

    # Prepare the tag to be updated
    $tags = @{ $s.key = $s.value }

    # Update the tag on the VM resource
    Update-AzTag -ResourceId $vm.ResourceId -Tag $tags -Operation Merge -ErrorAction SilentlyContinue | Out-Null

    # Check if the tag update was successful
    if ($?) {
        $statusMessage = "Tagged Successfully"
        $errorMessage = "NA"
    } else {
        $statusMessage = "Errored Out"
        $errorMessage = $Error[0].Exception.Message.Replace("`n", ", ").Replace("`r", ", ")
    }

    # Write the result to the output CSV file
    "$vmName`t$subscription`t$resourceGroup`t$statusMessage`t$tagValue`t$errorMessage" >> "tagScriptReport.csv"
}
