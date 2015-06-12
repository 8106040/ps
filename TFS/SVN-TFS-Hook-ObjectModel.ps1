#TFS object model wit update script
#requrie TFS Team Explorer 2013, TFS object Model 2013
#for SVN 1.8.3

Param($REPOS,$REV,$TXN)

#get SVN info
$svnlog = svnlook log $REPOS -r $REV
$svninfo = svnlook info $REPOS -r $REV
$svnchanged = svnlook changed $REPOS -r $REV

#get tfs work item id
$svnlog = $svnlog -csplit ":"
$witnum = $svnlog[0]
#$detail = $svninfo
#Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#Add-PSSnapin Microsoft.TeamFoundation.PowerShell

#set object model path
$pathToAss2 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0"
#$pathToAss4 = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v4.5"
Add-Type -Path "$pathToAss2\Microsoft.TeamFoundation.Client.dll"
Add-Type -Path "$pathToAss2\Microsoft.TeamFoundation.WorkItemTracking.Client.dll"
Add-Type -Path "$pathToAss2\Microsoft.TeamFoundation.VersionControl.Client.dll"

#$clientobjpath = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.Client.dll"
#$witobjpath = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\ReferenceAssemblies\v2.0\Microsoft.TeamFoundation.WorkItemTracking.Client.dll"
#$tfsclient = [System.Reflection.Assembly]::LoadFrom($clientobjpath)
#$tfswit = [System.Reflection.Assembly]::LoadFrom($witobjpath)

#init tfs connection
$tfsurl = "http://192.168.1.11:8080/tfs/DefaultCollection"
$tfsuser = "administrator"
$tfspwd = "!@#QWEasdzxc"
$tfscred = new-object System.Net.NetworkCredential($tfsuser, $tfspwd)
#$tfscred = New-Object System.Management.Automation.PSCredential($tfsuser, $tfspwd)
$tfs = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($tfsurl)
$tfs.Credentials = $tfscred

#update tfs wit
$wit = $tfs.GetService([type]"Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore")
$svnwit = $wit.GetWorkItem($witnum)
$olddetail = $svnwit.Description
$svnwit.Description = $olddetail + "<br>" + $detail
$svnwit.History = "Rev:" + $REV + "  Changed:" + $svnchanged

<#
$oldlink = $svnwit
 foreach($oldink in $oldItem.Links | ? { $_.BaseType -eq "HyperLink" }) {        
        if (($newItem.Links | ? { $_.Location -eq $oldLink.Location }).count -gt 0) {
            Write-Host "      ...link already exists on new work item"
        } else {
            $newLink = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.Hyperlink -ArgumentList $oldLink.Location
            #$newLink.Comment = $oldLink.Comment
            $newItem.Links.Add($newLink)
        }
#$svnLink = New-Object Microsoft.TeamFoundation.WorkItemTracking.Client.Hyperlink -ArgumentList $link
#$svnwit.Links.Add($svnLink)
#>
$svnwit.save()
exit
