$oldTpcUrl = "http://localhost:8080/tfs/oldCollection"
$newTpcUrl = "http://localhost:8080/tfs/newCollection"

$csvFile = ".\map.csv" #format: oldId, newId
$user = "domain\user"
$pass = "password"

[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Common')
[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.Client')
[Reflection.Assembly]::LoadWithPartialName('Microsoft.TeamFoundation.WorkItemTracking.Client')

$oldTpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($oldTpcUrl)
$newTpc = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($newTpcUrl)

$oldWorkItemStore = $oldTpc.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])
$newWorkItemStore = $newTpc.GetService([Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore])

$list = Import-Csv $csvFile
$cred = new-object System.Net.NetworkCredential($user, $pass)

foreach($map in $list) {
    $oldItem = $oldWorkItemStore.GetWorkItem($map.oldId)
    $newItem = $newWorkItemStore.GetWorkItem($map.newId)

    Write-Host "Processing $($map.oldId) -> $($map.newId)" -ForegroundColor Cyan
    
    foreach($oldLink in $oldItem.Links | ? { $_.BaseType -eq "HyperLink" }) {
        Write-Host "   processing link $($oldLink.Location)" -ForegroundColor Yellow

        if (($newItem.Links | ? { $_.Location -eq $oldLink.Location }).count -gt 0) {
            Write-Host "      ...link already exists on new work item"
        } else {
            $newLink = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.Hyperlink -ArgumentList $oldLink.Location
            $newLink.Comment = $oldLink.Comment
            $newItem.Links.Add($newLink)
        }
    }

    if ($oldItem.Attachments.Count -gt 0) {
        foreach($oldAttachment in $oldItem.Attachments) {
            mkdir $oldItem.Id | Out-Null
            Write-Host "   processing attachment $($oldAttachment.Name)" -ForegroundColor Magenta

            if (($newItem.Attachments | ? { $_.Name.Contains($oldAttachment.Name) }).count -gt 0) {
                Write-Host "      ...attachment already exists on new work item"
            } else {
                $wc = New-Object System.Net.WebClient
                $file = "$pwd\$($oldItem.Id)\$($oldAttachment.Name)"

                $wc.Credentials = $cred
                $wc.DownloadFile($oldAttachment.Uri, $file)

                $newAttachment = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.Attachment -ArgumentList $file, $oldAttachment.Comment
                $newItem.Attachments.Add($newAttachment)
            }
        }
    
        try {
            $newItem.Save();
            Write-Host "   Attachments and links saved" -ForegroundColor DarkGreen
        }
        catch {
            Write-Error "Could not save work item $newId"
            Write-Error $_
        }
    }

    $comments = $oldItem.GetActionsHistory() | ? { $_.Description.length -gt 0 } | % { $_.Description }
    if ($comments.Count -gt 0){
        Write-Host "   Porting $($comments.Count) comments..." -ForegroundColor Yellow
        foreach($comment in $comments) {
            Write-Host "      ...adding comment [$comment]"
            $newItem.History = $comment
            $newItem.Save()
        }
    }
    
    Write-Host "Done!" -ForegroundColor Green
}

Write-Host
Write-Host "Migration complete"