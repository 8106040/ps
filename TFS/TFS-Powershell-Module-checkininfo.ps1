# Add the snapin if its not already added
 trap {
 Add-PSSnapin Microsoft.TeamFoundation.PowerShell
 } 

# Move to my local workspace folder
 push-location C:MyWorkspaceFolder

# Get all the checkin info for the last 7 days
 $history = Get-TfsItemHistory . -Recurse -Stopafter 1000 | Where {$_.CreationDate -gt (get-date).AddDays(-7)}

# Group by owner, figure out how many checkins they did, how many were
 # commented and what the coverage was as a percentage. Finally, sort by
 # that coverage percentage

$history |
 group Owner |
 select Name,
 @{Name="Checkins";Expression={($_.Group).Count}}
 @{Name="Commented";Expression={($_.Group | where { $_.Comment -ne $null }).Count}} |
 select Name,
 Checkins,
 Commented,
 @{Name="Coverage";Expression={[math]::round(($_.Commented / $_.Checkins) * 100.0, 2)}} |
 sort "Coverage" -desc

# Move back to the starting directory
 pop-location
