# Import server list from CSV
$serverList = Import-Csv "deallocated.csv"

# Process each server in the list
foreach ($item in $serverList) {
    $vmResourceGroup = $item.rg
    $vmName = $item.name
    $subscriptionName = $item.subscription

    # Set the context to the appropriate subscription
    $subscription = Get-AzSubscription -SubscriptionName $subscriptionName
    Set-AzContext -Subscription $subscription.Id

    # Stop the VM
    Stop-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName -NoWait -Force
}
