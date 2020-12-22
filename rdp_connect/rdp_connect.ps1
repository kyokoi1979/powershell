<#
RDP.ps1

IPアドレス、ユーザー名、パスワードを引数として指定するとリモートデスクトップ接続します。
ユーザー名を指定しない場合は、Administratorユーザ固定でログインします。

横幅、高さについては1種類固定です。

リモートデスクトップ接続が成功したかどうかについては評価しません。

#>
# 環境変数
$WIDTH        = 1024            # リモートデスクトップセッションの横幅
$HEIGHT       = 768             # リモートデスクトップセッションの高さ

# 『server.list』PATH取得
$SCRIPT_PATH = Split-Path $myInvocation.MyCommand.path

$LOGDIR  = $SCRIPT_PATH
$LOGFILE = "${SCRIPT_PATH}\RDP.log"

$HOST_LIST = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) server.list
$WAIT      = 1
$SV = @()
$HOSTS     = Get-Content $HOST_LIST

# リモートデスクトップを実行する関数
function RDPConnect($CONNECT_IP, $CONNECT_USER, $CONNECT_PASS)
{
    # Cmdkey用に、接続先情報にポート番号が指定されている場合は除外する
    $CMDKEY_CONNECT_IP = $CONNECT_IP | %{ $_.Split(":")[0]}

    # mstscコマンドに渡す引数を定義
    $CMD_ARG = "/v:" + $CONNECT_IP + " /w:" + $WIDTH + " /h:" + $HEIGHT

    # 接続先の資格情報を保存
    Cmdkey.exe /generic:TERMSRV/"$CMDKEY_CONNECT_IP" /user:"$CONNECT_USER" /pass:"$CONNECT_PASS"

    # リモートデスクトップクライアントを起動し、5秒待機する
    Start-Process -FilePath mstsc -ArgumentList $CMD_ARG
    Timeout 5

    # 保存した資格情報を削除する
    Cmdkey.exe /delete:TERMSRV/$CMDKEY_CONNECT_IP
}

function PrintMsg ([string] $ip ,[string] $msg) {
 
    $now = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
    $message = "[$now] ($ip) $msg"
 
    Write-Host $message

    # ログファイルに出力
    Write-Output $message | Out-File ${LOGFILE} -Append -Encoding Default
}

foreach($i in $HOSTS){
    if (($i -eq "") -Or ($i.substring(0,1) -eq "#")) {
        Continue
        }
    $HOST_IP        = $i | %{ $_.Split("`t")[0]}
    $HOST_USER      = $i | %{ $_.Split("`t")[1]}
    $HOST_PASS      = $i | %{ $_.Split("`t")[2]}

    $HOST_LIST = Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) server.list

    $SERVER = @{ "IP" = $HOST_IP; "USER" = $HOST_USER; "PASS" = $HOST_PASS}
    New-Object -TypeName PSObject -Property $SERVER -OutVariable result | Out-Null

    $SV += $result
}

foreach($i in $SV){
    PrintMsg( $i.IP )
    RDPConnect $i.IP $i.USER $i.PASS
    Sleep $WAIT
}
