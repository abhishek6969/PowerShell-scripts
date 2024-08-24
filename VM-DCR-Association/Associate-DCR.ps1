# Import the server list from CSV
$server_list = Import-Csv "vmi.csv"

# Associate to DCR of your choice
Set-AzContext -Subscription "sub-name"
$rg = "rg-itops-monitoring"
$dcrName = "ITOPS_guest-metrics"
$dcr = Get-AzDataCollectionRule -ResourceGroupName $rg -RuleName $dcrName

# Process each item in the server list
ForEach ($item in $server_list) {
    $vmRG = $item.rg
    $vmName = $item.name
    $subscription = $item.subscription

    # Set the Azure context for the current subscription
    $subscriptionID = Get-AzSubscription -SubscriptionName $subscription
    Set-AzContext -Subscription $subscriptionID

    # Get VM status and details
    $vmStatus = Get-AzVM -ResourceGroupName $vmRG -Name $vmName -Status
    $vm = Get-AzVM -ResourceGroupName $vmRG -Name $vmName
    $os = $vm.StorageProfile.OSDisk.OSType
    $vmId = $vm.Id
    $location = $vm.Location

    # Check VM status
    if ($vmStatus.Statuses[1].DisplayStatus -ne "VM running") {
        Write-Output "$vmName is not running"
    } else {
        if ($vmStatus.VMAgent.Statuses[0].DisplayStatus -ne "Ready" -and $vmStatus.Statuses[1].DisplayStatus -eq "VM running") {
            Write-Output "$vmName VM-agent is not in ready state."
        } elseif ($vmStatus.VMAgent.Statuses[0].DisplayStatus -eq "Ready" -and $vmStatus.Statuses[1].DisplayStatus -eq "VM running") {
            # Install the appropriate Azure Monitor agent based on the OS type
            if ($os -eq "Linux") {
                Set-AzVMExtension -Name AzureMonitorLinuxAgent `
                                   -ExtensionType AzureMonitorLinuxAgent `
                                   -Publisher Microsoft.Azure.Monitor `
                                   -ResourceGroupName $vmRG `
                                   -VMName $vmName `
                                   -Location $location `
                                   -TypeHandlerVersion "1.0" `
                                   -EnableAutomaticUpgrade $true
            } else {
                Set-AzVMExtension -Name AzureMonitorWindowsAgent `
                                   -ExtensionType AzureMonitorWindowsAgent `
                                   -Publisher Microsoft.Azure.Monitor `
                                   -ResourceGroupName $vmRG `
                                   -VMName $vmName `
                                   -Location $location `
                                   -TypeHandlerVersion "1.0" `
                                   -EnableAutomaticUpgrade $true
            }

            # Associate the VM with the Data Collection Rule
            New-AzDataCollectionRuleAssociation -TargetResourceId $vmId `
                                                -AssociationName "test1DCR" `
                                                -RuleId $dcr.Id
        }
    }
}
