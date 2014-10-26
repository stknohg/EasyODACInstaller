# *****************************************************************************
# *
# * Easy ODAC UnInstaller
# * Copyright (c) 2014 @stknohg
# *
# * ODAC 11.2～12.1で動作を確認しています。
# *
# * このスクリプトはインストール時の構成に関わらずODACのすべてのコンポーネントをアンインストールします。
# * 
# * このスクリプトは以下の様なディレクトリ構成を前提としています。
# *   .\
# *       Config.ps1          - インストール時の設定情報です。
# *       UnInstall.bat           - 実行ファイルです。"管理者として実行"してください。
# *       UnInstall.ps1           - 本ファイルです。
# *       \ODAC               - XCopy版のODAC。環境に合わせたバージョンを展開してください。
# *           …
# *           unconfigure.bat     - ODACに同梱されているconfigure.bat
# *           uninstall.bat       - ODACに同梱されているinstall.bat
# *           …
# *
# *****************************************************************************

#
# メイン処理です。
#
Function Main {
    # 初期設定
    $SCRIPT_PATH = (Split-Path $script:myInvocation.MyCommand.path -parent);
    $ODAC_LOCATION = Join-Path $SCRIPT_PATH 'ODAC';

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
        Write-Host "このアンインストーラーは""管理者として実行""してください。" -ForegroundColor Red;
        Return;
    }
    
    # UnInstall Oracle Client(ODP.NET)
    # UnInstall.batは ORACLE_HOME をカレントディレクトリにして呼び出す必要がある。
    Write-Host ("ORACLE_HOME Directory : {0}" -F $ORACLE_HOME_DIR)
    Write-Host ("ORACLE_HOME Name      : {0}" -F $ORACLE_HOME_NAME)
    Write-Host "UnInstall Oracle Client(ODP.NET)..."
    If( Test-Path $ORACLE_HOME_DIR -PathType Container ){
        try {
            Set-Location $ORACLE_HOME_DIR;
            Start-Process "$ODAC_LOCATION\uninstall.bat" -ArgumentList @("all"; $ORACLE_HOME_NAME) -Wait -NoNewWindow
        } Finally {
            Set-Location $SCRIPT_PATH;
        }
    }

    # 強制削除(通常Off)
    If ($UNINSTALL_FORCE) {
        # ORACLE_HOME 配下を全て削除
        Write-Host "Force Remove ORCLE_HOME Directory..."
        Remove-ItemForce $ORACLE_HOME_DIR
        # ORACLE_HOME のレジストリキー削除
        Write-Host "Force Remove ORCLE_HOME Registory..."
        If($IS_WOW64) {
            $RegPath = "HKLM:\Software\Wow6432Node\Oracle\KEY_$ORACLE_HOME_NAME"
            Remove-ItemForce $RegPath
            $RegPath = "HKLM:\Software\Wow6432Node\Oracle\ODP.NET"
            Remove-ItemForce $RegPath
        } else {
            $RegPath = "HKLM:\Software\Oracle\KEY_$ORACLE_HOME_NAME"
            Remove-ItemForce $RegPath
            $RegPath = "HKLM:\Software\Oracle\ODP.NET"
            Remove-ItemForce $RegPath
        }
    }

    # 終了
    Write-Host "UnInstallation has completed."
    Write-Host "Press any key to continue..."
    Read-Host
}

#
# ODACのインストール状況を検証します。
#
Function Validate-ODACModule($ODACRootDir, [ref]$ErrorMessage){
    # install.bat
    $Path = Join-Path $ODACRootDir "uninstall.bat";
    If (! (Test-Path $Path -PathType Leaf) )
    {
        $ErrorMessage.value = ("{0} is not found." -F $Path);
        Return $false;
    }
    # configure.bat
    $Path = Join-Path $ODACRootDir "unconfigure.bat";
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
# 指定されたパスを強制的に削除します。
#
Function Remove-ItemForce($Path){
    If(Test-Path $Path -PathType Any){
        Remove-Item -Path $Path -Recurse -Force
    }
}

#
# 処理開始
#
Main
