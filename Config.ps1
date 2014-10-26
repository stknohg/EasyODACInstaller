# *****************************************************************************
# *
# * Easy ODAC Installer (設定情報)
# *
# *****************************************************************************

# 以下は環境に応じた設定をしてください。
# ODAC_COMPONENTS には以下の指定が可能です。
# ※詳細はODACのinstall.batを参照してください。
# 
#   asp.net2 - ASP.NET Providers 2 (.NET 2.0-3.5) *ODP.NET 2,Instant Clientを含みます。
#   asp.net4 - ASP.NET Providers 4 (.NET 4-)      *ODP.NET 4,Instant Clientを含みます。
#   odp.net2 - ODP.NET 2 (.NET 2.0-3.5)           *Instant Clientを含みます。
#   odp.net4 - ODP.NET 4 (.NET 4-)                *Instant Clientを含みます。
#   oledb    - OraOLEDB                           *Instant Clientを含みます。
#   oramts   - ORAMTS                             *Instant Clientを含みます。
#   basic    - Oracle Instant Client Only
#   all      - All Components
#
$ODAC_COMPONENTS  = @('odp.net2'; 'odp.net4')

# 64bitマシンに32bit版ODACをインストールする場合は$trueを、
# 32bitマシンに32bit、64bitマシンに64bit版ODACをインストールする場合は$falseを指定してください。
$IS_WOW64         = $false;

# ORACLE_HOME のディレクトリを指定してください。
$ORACLE_HOME_DIR  = 'C:\oracle\product\12.1.0\client_1'

# ORACLE_HOME 名を指定してください。
$ORACLE_HOME_NAME = 'OraClient12Home1'

# NLS_LANGの値を指定してください。
$NLS_LANG         = 'JAPANESE_JAPAN.JA16SJISTILDE'

# TNS_ADMINのディレクトリを指定してください。
$TNS_ADMIN_DIR    = $ORACLE_HOME_DIR + '\network\admin'

# アンインストール時にORACLE_HOMEを強制削除するか否か。
# 通常は$falseにしておいてください。
$UNINSTALL_FORCE  = $false;
