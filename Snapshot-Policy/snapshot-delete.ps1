# Get all subscriptions from Azure
$subscriptions = Get-AzSubscription

# Prepare the CSV report file with headers
"SnapshotName`tSubscription`tActionTaken`tErrorMessage" >> "scriptReport.csv"

# Hashtable defining all subscriptions with exclusions
$ExclusionIDs = @{ 
    # Add subscription IDs to exclude here
}

# Loop through each subscription
foreach ($sub in $subscriptions) {
    $subID = $sub.Id
    $subName = $sub.Name

    # Check if the subscription is part of the exclusion list
    if (-not $ExclusionIDs.ContainsKey($subID)) {

        # Set the context to the current subscription
        Set-AzContext -Subscription $subID

        # Get all snapshots in the subscription
        $snapshots = Get-AzSnapshot

        # Iterate over each snapshot
        foreach ($snapshot in $snapshots) {
            $deletionDate = (Get-Date).AddDays(-14)
            $todayDate = Get-Date
            $snapshotTimeCreatedDate = $snapshot.TimeCreated
            $dateDiff = New-TimeSpan -Start $snapshotTimeCreatedDate -End $todayDate
            $snapRG = $snapshot.ResourceGroupName
            $dateDiffDays = $dateDiff.Days
            $snapNAME = $snapshot.Name
            $tag = $snapshot.Tags

            # Check if the snapshot is tagged
            if ($tag.ContainsKey("Exception")) {
                $tagdate = $tag["Exception"]
                $taggedDeletionDate = [DateTime]$tagdate

                # Delete snapshot if today's date is past the tagged deletion date
                if ($todayDate -gt $taggedDeletionDate) {
                    $deletionRes = Remove-AzSnapshot -ResourceGroupName $snapRG -SnapshotName $snapNAME -Force -ErrorAction SilentlyContinue
                    if ($?) {
                        $message = "Deleted $snapNAME since it was tagged with exception: $taggedDeletionDate which is already surpassed"
                        "$snapNAME`t$subName`t$message`tNA" >> "scriptReport.csv"
                    } else {
                        $msg = $Error[0].Exception.Message -replace "`n", ", " -replace "`r", ", "
                        $errorMessage = "Deletion failed for $snapNAME tagged with exception: $taggedDeletionDate which is already surpassed"
                        "$snapNAME`t$subName`t$errorMessage`t$msg" >> "scriptReport.csv"
                    }
                } else {
                    $errorMessage = "No action taken for $snapNAME tagged with exception: $taggedDeletionDate which is not surpassed yet"
                    "$snapNAME`t$subName`t$errorMessage`tNA" >> "scriptReport.csv"
                }
            } else {
                # Action when snapshot is not tagged
                if ($snapshotTimeCreatedDate -lt $deletionDate) {
                    $deletionResult = Remove-AzSnapshot -ResourceGroupName $snapRG -SnapshotName $snapNAME -Force -ErrorAction SilentlyContinue
                    if ($?) {
                        $message = "Deleted $snapNAME as it was created on $snapshotTimeCreatedDate ($dateDiffDays days old)"
                        "$snapNAME`t$subName`t$message`tNA" >> "scriptReport.csv"
                    } else {
                        $msg = $Error[0].Exception.Message -replace "`n", ", " -replace "`r", ", "
                        $errorMessage = "Deletion failed for $snapNAME created on $snapshotTimeCreatedDate ($dateDiffDays days old)"
                        "$snapNAME`t$subName`t$errorMessage`t$msg" >> "scriptReport.csv"
                    }
                } else {
                    # Do nothing if snapshot is not older than 14 days
                    $message = "No action taken for $snapNAME as it was created on $snapshotTimeCreatedDate ($dateDiffDays days old)"
                    "$snapNAME`t$subName`t$message`tNA" >> "scriptReport.csv"
                }
            }
        }
    } else {
        # Log if subscription is part of the exclusion list
        $excludedMessage = "Excluded $subName since it is part of the exclusion list"
        "Subscription : $subName`t$subName`t$excludedMessage`tNA" >> "scriptReport.csv"
    }
}
