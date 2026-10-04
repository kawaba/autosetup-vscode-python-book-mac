#!/bin/bash
# ============================================================
# VS Code 起動スクリプト (Mac版)
# Python パスを環境変数に設定してから VS Code を起動します
# (setup.command が作る launch-vscode.app からも、このスクリプトが呼ばれる)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PYTHON_DIR="$SCRIPT_DIR/python"
VSCODE_APP="$SCRIPT_DIR/vscode/Visual Studio Code.app"
VSCODE_DATA="$SCRIPT_DIR/vscode/data"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"

# VS Code の存在確認
# (launch-vscode.app から呼ばれたときは、標準エラーの内容がダイアログに表示される)
if [ ! -d "$VSCODE_APP" ]; then
    echo "エラー: VS Code が見つかりません: $VSCODE_APP" >&2
    echo "先に setup.command を実行してください。" >&2
    [ -t 0 ] && read -n 1 -s
    exit 1
fi

# このフォルダの VS Code が既に動いているかを調べる。
# Mac では ✕ でウインドウを閉じてもアプリは終了しない (終了は Cmd+Q)。
# 動いている VS Code に open -a で --args を渡しても無視され、空のウインドウが開くだけになる。
# そのときは付属の code コマンドで、動いている VS Code に workspace を開かせる。
# (ほかの場所の VS Code と区別するため、実行ファイルのフルパスで比べる)
VSCODE_EXE="$VSCODE_APP/Contents/MacOS/Code"
CODE_BIN="$VSCODE_APP/Contents/Resources/app/bin/code"
if ps -axo comm= | grep -qxF "$VSCODE_EXE"; then
    echo "VS Code は起動済みです。workspace を開きます..."
    VSCODE_PORTABLE="$VSCODE_DATA" "$CODE_BIN" "$WORKSPACE_DIR"
    exit 0
fi

# VS Code を起動する
# - open で起動すると、VS Code はこのターミナルから切り離される。
#   ターミナルのウインドウを閉じても VS Code は終了しない。
# - open で起動したアプリには、このスクリプトの環境変数が引き継がれないため、
#   VSCODE_PORTABLE (ポータブルモードのデータの場所) などは --env で渡す。
# - --locale=ja: argv.json の locale 設定だけでは、UI の言語切り替えが反映されない
#   ことがあるため、明示的に指定する
# - workspace フォルダを開いた状態で起動する (Windows 版の launch-vscode.bat と同じ)
echo "VS Code を起動中..."
open -a "$VSCODE_APP" \
    --env "VSCODE_PORTABLE=$VSCODE_DATA" \
    --env "PORTABLE_PYTHON_PATH=$PYTHON_DIR/bin/python3" \
    --env "PATH=$PYTHON_DIR/bin:$PATH" \
    --args --locale=ja --disable-workspace-trust "$WORKSPACE_DIR"
