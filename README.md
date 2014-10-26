EasyODACInstaller
=================

XCopy版のODACインストーラーをカスタマイズし、より簡単なインストールを行うためのツールです。

動作環境
-----------------
このツールはバッチファイルとPowerShellから構成されています。
PowerShellが動く環境であれば大体動くはずです。
ODACのインストーラーが管理者権限を要求するのでこのツールの実行にも管理者権限が必要になります。

動作確認しているODACのバージョンは

* ODAC 12c Release 2 (12.1.0.1.2)

* ODAC 11.2 Release 6 (11.2.0.4.0) 

ですが他のバージョンでも多分動くと思います。

セットアップ手順
-----------------
このツールは以下のディレクトリ構成をしています。

```
./
   ODAC/
   Template/
       sqlnet.ora
       tnsnames.ora
   Config.ps1
   Install.bat
   Install.ps1
   Uninstall.bat
   Uninstall.ps1
```

セットアップ手順は次の通りです。

1. Oracleのダウンロードサイト([32bit](http://www.oracle.com/technetwork/database/windows/downloads/utilsoft-087491.html)/[64bit](http://www.oracle.com/technetwork/jp/database/windows/downloads/index-090165.html))よりインストールしたいバージョンのXCopy版のODACをダウンロードし、ODACフォルダに展開します。
**※ODACフォルダの直下に展開したinstall.bat,configure.batが来る様にします。**

2. Templateフォルダの中にあるsqlnet.ora、tnsmanes.oraをインストールする環境に合わせて変更してください。

3. Config.ps1にインストール先などの設定情報が記載されています。
インストールする環境に合わせてカスタマイズしてください。


使用方法
-----------------

* インストール時はInstall.batを実行してください。

* アンインストール時はUnInstall.batを実行してください。

処理内容
-
このスクリプトでは以下の処理を行っています。

* ODACのインストール

* ORACLE_HOMEのレジストリキーの変更

 * NLS_LANG
 * TNS_ADMIN

* sqlnet.ora、tnsnames.oraファイルの配置


ライセンス
-----------------

たいしたスクリプトでないので好き勝手に使ってもらって構わないのですが、一応MITライセンスにしておきます。
