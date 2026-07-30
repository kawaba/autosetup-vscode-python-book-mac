#!/bin/bash
# ============================================================
# VS Code 起動スクリプト (Mac版)
# Python パスを環境変数に設定してから VS Code を起動します
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PYTHON_DIR="$SCRIPT_DIR/python"
VSCODE_APP="$SCRIPT_DIR/vscode/Visual Studio Code.app"
VSCODE_DATA="$SCRIPT_DIR/vscode/data"

# Python の PATH を設定
export PATH="$PYTHON_DIR/bin:$PATH"
export PORTABLE_PYTHON_PATH="$PYTHON_DIR/bin/python3"

# ポータブルモード用データディレクトリを指定
export VSCODE_PORTABLE="$VSCODE_DATA"

# VS Code の存在確認
if [ ! -d "$VSCODE_APP" ]; then
    echo "エラー: VS Code が見つかりません: $VSCODE_APP"
    echo "先に setup.command を実行してください。"
    read -n 1 -s
    exit 1
fi

# VS Code を起動（バイナリ直接起動でVSCODE_PORTABLEを継承させる）
# --locale=ja: argv.jsonのlocale設定だけではmacOSでバイナリ直接起動した場合に
# UI文字列の言語切り替えが反映されないため、明示的に指定する
echo "VS Code を起動中..."
"$VSCODE_APP/Contents/MacOS/Code" --locale=ja &
