$servers = Get-Content server.list
$count = 10
$outfile = 'hoge.csv'

while($count){
    $time = {Get-Date}
    Test-Connection $servers -Count 1 -Delay 1 -AsJob |
        Wait-Job | Receive-Job |
        Select @{n="Time";e=$time},Address,ReplySize,ResponseTime,ResponseTimeToLive,StatusCode -OutVariable result | Out-Null

    $result | Format-Table -AutoSize
    $result | Export-Csv -Append $outfile

    Remove-Job -State Completed

    $count -= 1
}
