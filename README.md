EasyODACInstaller
=================

XCopy版のODACインストーラーをカスタマイズし、より簡単なインストールを行うためのツールです。

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

セットアップ手順は以下の通りです。

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
