function Compare-Files{
 param(
 $file1,
 $file2,
 [switch]$IncludeEqual
 )
 $content1 = Get-Content $file1
 $content2 = Get-Content $file2
 $comparedLines = Compare-Object $content1 $content2 -IncludeEqual:$IncludeEqual |
 group { $_.InputObject.ReadCount } | sort Name
 $comparedLines | foreach {
 $curr=$_
 switch ($_.Group[0].SideIndicator){
¡°==¡± { $right=$left = $curr.Group[0].InputObject;break}
¡°=>¡± { $right,$left = $curr.Group[0].InputObject,$curr.Group[1].InputObject;break }
¡°<=" { $right,$left = $curr.Group[1].InputObject,$curr.Group[0].InputObject;break }
 }
 [PSCustomObject] @{
 Line = $_.Name
 Left = $left
 Right = $right
 }
 }
 }

Compare-Files E:\TFS2015\1-tfs-azure-env-config.ps1 E:\TFS2015\2-tfs-server-installation.ps1