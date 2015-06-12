function Diff-Txt([io.fileinfo]$firstFile,[io.fileinfo]$secondFile)
{
    #参数判断
    if( -not $firstFile.Exists)
    {
        throw "$firstFile 不存在"
    }
    if( -not $secondFile.Exists)
    {
        throw "$secondFile 不存在"
    }
    $sr1=[IO.StreamReader]$firstFile.FullName
    $sr2=[IO.StreamReader]$secondFile.FullName
 
    #内部函数：比较字符串
    #返回-1表示相等，返回其它表示从$str1开始不等的索引
    function Diff-String([string]$str1,[string]$str2)
    {
        for( $i=0; $i -lt $str1.Length; $i++)
        {
            if($i -lt $str2.Length)
            {
                if($str1[$i] -cne $str2[$i]){ return $i }
            }
            else { return $i }
        }
        if($str2.Length -gt $i ) { return $i }
        return -1
    }
 
    # firstFile 没到文件末尾
    $line=1
    while(-not $sr1.EndOfStream) 
    {
        $str1 = $sr1.ReadLine()
 
        # secondFile 到了文件末尾
        if($sr2.EndOfStream) 
        {
            Write-Host "=> [$line 行,1 列]"
        }
 
        # secondFile 没到文件末尾
        else
        {
            $str2 = $sr2.ReadLine()
            $result = Diff-String -str1 $str1 -str2 $str2
            if($result -ne -1)
            {
                Write-Host "<> [$line 行,$result 列] 字符->" -NoNewline
                Write-Host  $str1[$result]   -ForegroundColor red
            }
        }
 
        $line++
    }
    # 第二个文件没到文件末尾
    while( -not $sr2.EndOfStream)
    {
        $str2 = $sr2.ReadLine()
        Write-Host "<= [$line 行,1 列]"
    }
    # 关闭文件流
    $sr1.Close()
    $sr2.Close()
}

diff-txt E:\TFS2015\1-tfs-azure-env-config.ps1 E:\TFS2015\2-tfs-server-installation.ps1
