# Import the server list from CSV
$server_list = Import-Csv "win.csv"

# Initialize the summary CSV file
"Name`tRG`tSubscription`tResult" >> "machines-Summary.csv"

# Process each item in the server list
ForEach ($item in $server_list) {
    $vmRG = $item.rg
    $vmName = $item.name
    $subscription = $item.subscription

    # Set the Azure context
    $subscriptionID = Get-AzSubscription -SubscriptionName $subscription
    Set-AzContext -Subscription $subscriptionID

    # Get VM status
    $vmStatus = Get-AzVM -ResourceGroupName $vmRG -Name $vmName -Status
    $vm = Get-AzVM -ResourceGroupName $vmRG -Name $vmName

    # Check VM status
    if ($vmStatus.statuses[1].DisplayStatus -ne "VM running") {
        Write-Output "$vmName is not running"
        $stat = "VM is not running"
        "$vmName`t$vmRG`t$subscription`t$stat" >> "machines-Summary.csv"
    } else {
        if ($vmStatus.vmagent.statuses[0].DisplayStatus -ne "Ready" -and $vmStatus.statuses[1].DisplayStatus -eq "VM running") {
            Write-Output "$vmName VM-agent is not in ready state."
            $stat = "VM agent not ready"
            "$vmName`t$vmRG`t$subscription`t$stat" >> "machines-Summary.csv"
        } elseif ($vmStatus.vmagent.statuses[0].DisplayStatus -eq "Ready" -and $vmStatus.statuses[1].DisplayStatus -eq "VM running") {
            # Get VM feature installation state
            $result = Invoke-AzVMRunCommand -VMName $vmName -ResourceGroupName $vmRG -CommandId 'RunPowerShellScript' -ScriptString '(Get-WindowsFeature Failover*).InstallState'
            $result1 = $result.value[0].Message
            "$vmName`t$vmRG`t$subscription`t$result1" >> "machines-Summary.csv"
        }
    }
}
