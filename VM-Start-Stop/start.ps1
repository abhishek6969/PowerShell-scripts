# Import server list from CSV
$serverList = Import-Csv "win.csv"

# Initialize CSV file for output
"Name,ResourceGroup,Subscription,Result" | Out-File "deallocated.csv" -Encoding utf8

# Process each server in the list
foreach ($item in $serverList) {
    $vmResourceGroup = $item.rg
    $vmName = $item.name
    $subscriptionName = $item.subscription

    # Set the context to the appropriate subscription
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName
    Set-AzContext -Subscription $subscription.Id

    # Get the VM status
    $vmStatus = Get-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName -Status

    # Check if the VM is running
    if ($vmStatus.Statuses[1].DisplayStatus -ne "VM running") {
        Write-Output "$vmName is not running"
        $result = "VM was not running and hence started"

        # Log the result to CSV
        "$vmName,$vmResourceGroup,$subscriptionName,$result" | Out-File "deallocated-report.csv" -Append -Encoding utf8

        # Start the VM
        Start-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName -NoWait
    }
}
