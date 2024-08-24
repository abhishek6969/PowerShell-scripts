# Define the Action Group ID as a variable
$actionGroupId = "place your AG here"

# Import the CSV file
$source = Import-Csv vms.csv

# Initialize the report file
"Name`tSubscription`tRG`tStatus`tErrorMessage" >> "AlertScriptReport.csv"

# Process each entry in the CSV
foreach ($s in $source) {
    $subscription = $s.sub
    $vm_name = $s.name
    $rg = $s.rg
    $description = $s.tier

    # Set the Azure context
    Set-AzContext -SubscriptionName $subscription

    # Get the VM resource
    $vm = Get-AzResource -Name $vm_name -ResourceGroupName $rg | Where-Object { $_.Type -eq "Microsoft.Compute/virtualMachines" }

    # Define alert rules
    $alerts = @(
        @{
            Name = "${vm_name}_ITOPS_CPU"
            MetricName = "Percentage CPU"
            TimeAggregation = "Average"
            Operator = "GreaterThan"
            Threshold = 85
        },
        @{
            Name = "${vm_name}_ITOPS_AVAILABILITY"
            MetricName = "VmAvailabilityMetric"
            TimeAggregation = "Average"
            Operator = "LessThan"
            Threshold = 1
        },
        @{
            Name = "${vm_name}_ITOPS_OS-Disk-IOPS"
            MetricName = "OS Disk IOPS Consumed Percentage"
            TimeAggregation = "Average"
            Operator = "GreaterThan"
            Threshold = 95
        },
        @{
            Name = "${vm_name}_ITOPS_Network-Out-Total"
            MetricName = "Network Out Total"
            TimeAggregation = "Total"
            Operator = "GreaterThan"
            Threshold = 200000000000
        },
        @{
            Name = "${vm_name}_ITOPS_Network-In-Total"
            MetricName = "Network In Total"
            TimeAggregation = "Total"
            Operator = "GreaterThan"
            Threshold = 500000000000
        },
        @{
            Name = "${vm_name}_ITOPS_Data-Disk-IOPS"
            MetricName = "Data Disk IOPS Consumed Percentage"
            TimeAggregation = "Average"
            Operator = "GreaterThan"
            Threshold = 95
        },
        @{
            Name = "${vm_name}_ITOPS_Memory"
            MetricName = "Available Memory Bytes"
            TimeAggregation = "Total"
            Operator = "LessThan"
            Threshold = 1000000000
        }
    )

    # Create each alert rule
    foreach ($alert in $alerts) {
        $condition = New-AzMetricAlertRuleV2Criteria -MetricName $alert.MetricName -TimeAggregation $alert.TimeAggregation -Operator $alert.Operator -Threshold $alert.Threshold
        Add-AzMetricAlertRuleV2 -Name $alert.Name -ResourceGroupName $rg -WindowSize 0:5 -Frequency 0:5 -TargetResourceId $vm.id -Severity 4 -Condition $condition -ActionGroupId $actionGroupId -Description $description -ErrorAction SilentlyContinue | Out-Null
    }

    # Log the result
    if ($?) {
        $message11 = "Alert created successfully"
        $message12 = "NA"
        "$vm_name`t$subscription`t$rg`t$message11`t$message12" >> "AlertScriptReport.csv"
    } else {
        $msg1 = "Errored OUT"
        $msg2 = $Error[0].Exception.Message.Replace("`n", ", ").Replace("`r", ", ")
        "$vm_name`t$subscription`t$rg`t$msg1`t$msg2" >> "AlertScriptReport.csv"
    }
}
