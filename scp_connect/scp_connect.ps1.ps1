# WinSCPのパス
$SCP       = 'C:\Program Files (x86)\WinSCP\WinSCP.exe'

# WinSCPログファイル
$SCPLOG    = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) winscp.log

# ホストリスト
$HOST_LIST = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) server.list

# ウェイト
$WAIT      = 5

$SV = @()
$HOSTS     = Get-Content $HOST_LIST

function ScpConnect($IP, $USER, $PASS)
{
    $ARG = '/default /log=' + $SCPLOG + ' sftp://' + $USER + ':' + $PASS + '@' + $IP
    Start-Process -FilePath $WINSCP -ArgumentList $ARG
}

foreach($i in $HOSTS){
    if (($i -eq "") -Or ($i.substring(0,1) -eq "#")) {
        Continue
        }
    $HOST_IP        = $i | %{ $_.Split("`t")[0]}
    $HOST_USER      = $i | %{ $_.Split("`t")[1]}
    $HOST_PASS      = $i | %{ $_.Split("`t")[2]}

    $SERVER = @{ "IP" = $HOST_IP; "USER" = $HOST_USER; "PASS" = $HOST_PASS}
    New-Object -TypeName PSObject -Property $SERVER -OutVariable result | Out-Null

    $SV += $result
    }

foreach($i in $SV){
    ScpConnect $i.IP $i.USER $i.PASS
    Sleep $WAIT
}
