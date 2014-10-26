# *****************************************************************************
# *
# * Easy ODAC Installer
# * Copyright (c) 2014 @stknohg
# *
# * ODAC 11.2～12.1で動作を確認しています。
# * 
# * このスクリプトは以下の様なディレクトリ構成を前提としています。
# *   .\
# *       Config.ps1        - インストールに関わる設定情報です。
# *       Install.bat       - 実行ファイルです。"管理者として実行"してください。
# *       Install.ps1       - 本ファイルです。
# *       \ODAC             - XCopy版のODAC。環境に合わせたバージョンを展開してください。
# *           …
# *           configure.bat   - ODACに同梱されているconfigure.bat
# *           install.bat     - ODACに同梱されているinstall.bat
# *           …
# *       \template
# *           sqlnet.ora      - 環境に合わせた設定済みのsqlnet.ora
# *           tnsnames.ora    - 環境に合わせた設定済みのtnsnames.ora
# *
# *****************************************************************************

#
# メイン処理です。
#
Function Main {
    # 初期設定
    $SCRIPT_PATH = (Split-Path $script:myInvocation.MyCommand.path -parent);
    $ODAC_LOCATION = Join-Path $SCRIPT_PATH 'ODAC';
    $TEMPLATE_LOCATION = Join-Path $SCRIPT_PATH 'Template';

    # カレントディレクトリをスクリプトのあるディレクトリにする。
    # ※管理者として実行された場合 %Systemroot%\System32 がカレントになる場合があるのでそれに対応している。
    Set-Location $SCRIPT_PATH;

    # 設定情報の読み込み。
    . .\Config.ps1;

    # 事前チェック
    # ODACのモジュールチェック
    $ErrorMessage = '';
    If ( !(Validate-ODACModule $ODAC_LOCATION ([ref]$ErrorMessage)) ) {
        Write-Host $ErrorMessage -ForegroundColor Red;
        Write-Host ("{0}フォルダに各種モジュールが展開されているか確認してください。" -F $ODAC_LOCATION) -ForegroundColor Red;
        Return;
    }
    # 管理者権限で実行されているか
    If ( !(Check-RunAsAdministrator) ) {
        Write-Host "このインストーラーは""管理者として実行""してください。" -ForegroundColor Red;
        Return;
    }
    
    # Install Oracle Client(ODP.NET)
    # ODACのXcopyインストーラーにあるinstall.batは同じディレクトリにあるconfigure.batを
    # 呼び出すのでカレントディレクトリを移動しておく必要がある。
    Write-Host  "ODAC Component        : $ODAC_COMPONENTS" 
    Write-Host ("ORACLE_HOME Directory : {0}" -F $ORACLE_HOME_DIR)
    Write-Host ("ORACLE_HOME Name      : {0}" -F $ORACLE_HOME_NAME)
    Write-Host ("TNS_ADMIN Directory   : {0}" -F $TNS_ADMIN_DIR)
    Write-Host "Install Oracle Client(ODP.NET)..."
    try {
        Set-Location $ODAC_LOCATION;
        foreach ($c in $ODAC_COMPONENTS) {
            Write-Host ("Install {0}..." -F $c)
            .\install.bat "$c" "$ORACLE_HOME_DIR" "$ORACLE_HOME_NAME" "true"
        }
    } Finally {
        Set-Location $SCRIPT_PATH;
    }

    # レジストリ更新
    # ODP.NETをインストールした時点で \\HKLM\Software\Oracle\KEY_{指定したORACLE_HOME名}
    # のレジストリキーが作成されているので必要に応じたカスタマイズをする。
    # WOW64の場合は \\HKLM\Software\Wow6432Node\Oracle\KEY_{指定したORACLE_HOME名}
    # になります。
    Write-Host "Update Registory..."
    If($IS_WOW64) {
        $RegPath = "HKLM:\Software\Wow6432Node\Oracle\KEY_$ORACLE_HOME_NAME"
    } else {
        $RegPath = "HKLM:\Software\Oracle\KEY_$ORACLE_HOME_NAME"
    }
    if( Test-Path $RegPath -PathType Container ){
        # NLS_LANG の更新
        Ensure-Registory $RegPath "NLS_LANG" $NLS_LANG
        # TNS_ADMIN の更新
        Ensure-Registory $RegPath "TNS_ADMIN" $TNS_ADMIN_DIR
    }

    # sqlnet.ora/tnsnames.oraのコピー
    Write-Host "Copying sqlnet.ora/tnsnames.ora..."
    Ensure-Directory $TNS_ADMIN_DIR
    Deploy-Item (Join-Path $TEMPLATE_LOCATION 'sqlnet.ora')   $TNS_ADMIN_DIR
    Deploy-Item (Join-Path $TEMPLATE_LOCATION 'tnsnames.ora') $TNS_ADMIN_DIR

    # 終了
    Write-Host "Installation has completed."
    Write-Host "Press any key to continue..."
    Read-Host
}

#
# ODACのインストール状況を検証します。
#
Function Validate-ODACModule($ODACRootDir, [ref]$ErrorMessage){
    # install.bat
    $Path = Join-Path $ODACRootDir "install.bat";
    If (! (Test-Path $Path -PathType Leaf) )
    {
        $ErrorMessage.value = ("{0} is not found." -F $Path);
        Return $false;
    }
    # configure.bat
    $Path = Join-Path $ODACRootDir "configure.bat";
    If (! (Test-Path $Path -PathType Leaf) )
    {
        $ErrorMessage.value = ("{0} is not found." -F $Path);
        Return $false;
    }
    Return $true;
}

#
# 現在のスクリプトが管理者権限で実行されているか否かを判定します。
#
Function Check-RunAsAdministrator{
    Return ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")
}

#
# レジストリのキーを更新します。
# とりあえずREG_SZのみ対応してます。
#
Function Ensure-Registory($Path, $Key, $Value ){
    if( (Get-ItemProperty -Path $Path).$Key -eq $null )
    {
        New-ItemProperty -Path $Path -Name $Key -PropertyTyp String -Value $Value | Out-Null
    }
    else
    {
        Set-ItemProperty -Path $Path -name $Key -value $Value | Out-Null
    }
}

#
# ディレクトリを更新します。
#
Function Ensure-Directory($Path){
    if( !(Test-Path $Path -PathType Container) )
    {
        New-Item $Path -Type Directory | Out-Null
    }
}

#
# 指定されたファイルを配置します。
# 配置するファイルが無い場合は何もしません。
# 配置先のディレクトリが無い場合は新規作成して配置します。
#
Function Deploy-Item($SourceItem, $Destination){
    If (Test-Path $SourceItem -PathType Leaf ) {
        Ensure-Directory $Destination
        Copy-Item $SourceItem $Destination -Force;
    }
}

#
# 処理開始
#
Main
