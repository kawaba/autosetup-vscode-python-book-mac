#!/bin/bash
# ============================================================
# Portable Python + VS Code セットアップスクリプト (Mac版)
# ============================================================

set -e  # エラー発生時に停止

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m'

# 途中で止まったときに、どこで止まったかを表示してからウィンドウを残す
on_error() {
    echo ""
    echo -e "${RED}エラーが発生したため、セットアップを中止しました (setup.command の $1 行目)。${NC}"
    echo -e "${RED}上に表示されているメッセージを確認してください。${NC}"
    echo "Press any key to exit..."
    read -n 1 -s
}
trap 'on_error $LINENO' ERR

# スクリプト自身のディレクトリを基準にする
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# zip を展開したファイルに付く「インターネットから取得した」印 (com.apple.quarantine) を
# フォルダ全体から外す。これで launch-vscode.command を初めて開くときに
# Gatekeeper の警告が出なくなる (setup.command 自身の初回の警告は避けられない)。
xattr -dr com.apple.quarantine "$SCRIPT_DIR" 2>/dev/null || true

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} Portable Python + VS Code 環境セットアップ開始${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""

# ============================================================
# アーキテクチャ検出 (Intel / Apple Silicon)
# ============================================================
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    VSCODE_OS="darwin-arm64"
    echo "  検出: Apple Silicon (arm64)"
else
    VSCODE_OS="darwin"
    echo "  検出: Intel Mac (x86_64)"
fi
echo ""

# ============================================================
# 1. Python のセットアップ (自己完結型スタンドアロンビルド)
# ============================================================
echo -e "${GREEN}[1/5] Python 3.13 をセットアップ中...${NC}"

PYTHON_DIR="$SCRIPT_DIR/python"
PYTHON_BIN="$PYTHON_DIR/bin/python3"

# python-build-standalone (uv/rye/pyenv-win 等が使っているのと同じ自己完結ビルド)。
# Homebrew の python@3.13 から作る venv は bin/python3 が Homebrew 本体への
# シンボリックリンクに過ぎず、共有ライブラリの参照も /opt/homebrew/... に
# 焼き付いているため、フォルダを移動/配布すると壊れる。
# このビルドはOS標準ライブラリ以外への依存がなく、tkinter (Tcl/Tk) も同梱済みで
# フォルダごと移動・別Macへのコピーが可能な真の意味でポータブルな構成になる。
PBS_RELEASE_TAG="20260728"
PBS_PYTHON_VERSION="3.13.14"

if [ -d "$PYTHON_DIR" ]; then
    echo -e "  ${YELLOW}★ Python は既に存在します。スキップします。${NC}"
else
    if [ "$ARCH" = "arm64" ]; then
        PBS_TRIPLE="aarch64-apple-darwin"
    else
        PBS_TRIPLE="x86_64-apple-darwin"
    fi

    PBS_ASSET="cpython-${PBS_PYTHON_VERSION}+${PBS_RELEASE_TAG}-${PBS_TRIPLE}-install_only.tar.gz"
    PBS_URL="https://github.com/astral-sh/python-build-standalone/releases/download/${PBS_RELEASE_TAG}/${PBS_ASSET}"
    PBS_ARCHIVE="$SCRIPT_DIR/python.tar.gz"

    echo "  自己完結型 Python (python-build-standalone, tkinter同梱) をダウンロード中..."
    curl -fL --retry 3 -o "$PBS_ARCHIVE" "$PBS_URL"

    echo "  展開中..."
    tar xzf "$PBS_ARCHIVE" -C "$SCRIPT_DIR"
    rm "$PBS_ARCHIVE"

    echo -e "  ${GREEN}Python (自己完結ビルド) の展開完了${NC}"
fi

echo ""

# ============================================================
# 1b. フォント (HackGen) のインストール
# ============================================================
# SPD の罫線 (─│├└┬) を全角幅で表示して、縦罫線の位置をそろえるために使う。
# HackGen (Console でない方) は罫線が全角幅。Mac 標準の等幅フォント (Menlo など) は
# 罫線が半角幅なので、日本語と混ざると縦罫線がずれる。
# Homebrew は管理者権限が必要で学校の Mac などでは使えないため、GitHub の配布 zip から
# 直接取得し、管理者権限の要らない ~/Library/Fonts に置く。
# フォントは OS 全体へのインストールとなり、Python のポータブル性とは無関係。
# 失敗してもセットアップは続ける (VS Code は settings.json の代わりのフォントで表示する)。
echo -e "${GREEN}フォント (HackGen) をセットアップ中...${NC}"

HACKGEN_VERSION="v2.10.0"
HACKGEN_FILES=("HackGen-Regular.ttf" "HackGen-Bold.ttf")
USER_FONT_DIR="$HOME/Library/Fonts"

# set -e は「if ! 関数」の中では効かないので、失敗は 1 つずつ return 1 で返す
install_hackgen() {
    local f tmp zip_dir missing=0
    for f in "${HACKGEN_FILES[@]}"; do
        [ -f "$USER_FONT_DIR/$f" ] || missing=1
    done
    if [ "$missing" -eq 0 ]; then
        echo -e "  ${YELLOW}★ HackGen は既にインストールされています。スキップします。${NC}"
        return 0
    fi

    tmp=$(mktemp -d) || return 1
    zip_dir="HackGen_${HACKGEN_VERSION}"

    echo "  HackGen ${HACKGEN_VERSION} をダウンロード中..."
    curl -fL --retry 3 -o "$tmp/hackgen.zip" \
        "https://github.com/yuru7/HackGen/releases/download/${HACKGEN_VERSION}/${zip_dir}.zip" \
        || { rm -rf "$tmp"; return 1; }

    mkdir -p "$USER_FONT_DIR" || { rm -rf "$tmp"; return 1; }
    for f in "${HACKGEN_FILES[@]}"; do
        # -j: zip 内のフォルダ (HackGen_v2.10.0/) を付けずに取り出す
        unzip -q -o -j "$tmp/hackgen.zip" "$zip_dir/$f" -d "$tmp" \
            && cp "$tmp/$f" "$USER_FONT_DIR/" \
            || { rm -rf "$tmp"; return 1; }
    done
    rm -rf "$tmp"
    echo -e "  ${GREEN}HackGen を $USER_FONT_DIR にインストールしました${NC}"
}

if ! install_hackgen; then
    echo -e "  ${YELLOW}警告: HackGen フォントをインストールできませんでした${NC}"
    echo -e "  ${YELLOW}  SPD の縦罫線がずれる場合は、README の「トラブルシューティング」を参照してください${NC}"
fi

echo ""

# ============================================================
# 2. pip のアップグレード
# ============================================================
echo -e "${GREEN}[2/5] pip をアップグレード中...${NC}"

"$PYTHON_BIN" -m pip install --upgrade pip

echo -e "  ${GREEN}pip バージョン確認:${NC}"
"$PYTHON_BIN" -m pip --version

echo ""

# ============================================================
# 3. Python ライブラリのインストール
# ============================================================
echo -e "${GREEN}[3/5] Python ライブラリをインストール中...${NC}"
echo -e "  ${YELLOW}(この処理には5〜10分かかる場合があります)${NC}"
echo ""

"$PYTHON_BIN" -m pip install wheel
"$PYTHON_BIN" -m pip install build
"$PYTHON_BIN" -m pip install black pylint flake8 autopep8 isort mypy
"$PYTHON_BIN" -m pip install requests python-dotenv tqdm colorama
"$PYTHON_BIN" -m pip install numpy pandas matplotlib scipy seaborn
"$PYTHON_BIN" -m pip install flask fastapi uvicorn beautifulsoup4 lxml
"$PYTHON_BIN" -m pip install openpyxl pillow pyyaml pytest faker
"$PYTHON_BIN" -m pip install notebook jupyterlab ipykernel ipywidgets
"$PYTHON_BIN" -m pip install jupyterlab-lsp python-lsp-server
"$PYTHON_BIN" -m pip install plotly xlsxwriter
"$PYTHON_BIN" -m pip install streamlit debugpy pygame arcade pyglet
"$PYTHON_BIN" -m pip install scikit-learn statsmodels sqlalchemy
"$PYTHON_BIN" -m pip install psycopg2-binary || {
    # Apple Silicon では psycopg2-binary がビルド失敗することがある
    echo -e "  ${YELLOW}警告: psycopg2-binary のインストールをスキップしました${NC}"
}
"$PYTHON_BIN" -m pip install pydantic httpx janome rich
"$PYTHON_BIN" -m pip install https://k-webs.jp/lib/python/tkxlib-2.0.1-py3-none-any.whl || {
    echo -e "  ${YELLOW}警告: tkxlib のインストールをスキップしました (URLが存在しない可能性があります)${NC}"
}

echo ""

# ============================================================
# 4. VS Code のダウンロード・展開
# ============================================================
echo -e "${GREEN}[4/5] VS Code をダウンロード中...${NC}"

VSCODE_URL="https://update.code.visualstudio.com/latest/${VSCODE_OS}/stable"
VSCODE_ZIP="vscode.zip"
VSCODE_DIR="$SCRIPT_DIR/vscode"

if [ -d "$VSCODE_DIR/Visual Studio Code.app" ]; then
    echo -e "  ${YELLOW}★ VS Code は既に存在します。スキップします。${NC}"
else
    echo "  ダウンロード中 (サイズが大きいため時間がかかります)..."
    curl -fL --retry 3 -o "$VSCODE_ZIP" "$VSCODE_URL"

    echo "  展開中..."
    unzip -q "$VSCODE_ZIP" -d "$VSCODE_DIR"
    rm "$VSCODE_ZIP"

    # ポータブルモード有効化: .app の隣に data フォルダを作成
    mkdir -p "$VSCODE_DIR/data"

    echo -e "  ${GREEN}VS Code のダウンロード・展開完了${NC}"
fi

# VS Code の code コマンドパスを検索
CODE_BIN="$VSCODE_DIR/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ ! -f "$CODE_BIN" ]; then
    CODE_BIN=""
    echo -e "  ${YELLOW}警告: VS Code の code コマンドが見つかりません${NC}"
fi

echo ""

# ============================================================
# 5. VS Code 拡張機能のインストール
# ============================================================
echo -e "${GREEN}[5/5] VS Code 拡張機能をインストール中...${NC}"

EXT_FILE="$SCRIPT_DIR/config/cleanExtentions.txt"

if [ -f "$EXT_FILE" ] && [ -n "$CODE_BIN" ]; then
    total=$(grep -cve '^\s*$' "$EXT_FILE" 2>/dev/null || echo 0)
    count=1

    while IFS= read -r ext || [ -n "$ext" ]; do
        ext=$(echo "$ext" | xargs)  # 前後の空白をトリム
        if [ -n "$ext" ]; then
            echo "  [$count/$total] インストール中: $ext"
            if ! EXT_ERR=$(VSCODE_PORTABLE="$VSCODE_DIR/data" "$CODE_BIN" \
                --install-extension "$ext" --force 2>&1 >/dev/null); then
                if VSCODE_PORTABLE="$VSCODE_DIR/data" "$CODE_BIN" --list-extensions 2>/dev/null | grep -qix "$ext"; then
                    echo -e "  ${GRAY}(依存拡張の警告のみ。$ext 自体はインストール済み)${NC}"
                else
                    # extensionPack依存(例: 内蔵化されたcopilot-chat)との衝突でマーケットプレイス
                    # 経由のインストールが丸ごと失敗することがあるため、.vsixを直接取得して試す
                    PUBLISHER="${ext%%.*}"
                    NAME="${ext#*.}"
                    VSIX_TMP="$SCRIPT_DIR/${ext}.vsix"
                    if curl -sL --compressed --retry 2 -o "$VSIX_TMP" \
                        "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${PUBLISHER}/vsextensions/${NAME}/latest/vspackage" \
                        && VSCODE_PORTABLE="$VSCODE_DIR/data" "$CODE_BIN" --install-extension "$VSIX_TMP" --force >/dev/null 2>&1; then
                        echo -e "  ${GRAY}(.vsix直接インストールで成功: $ext)${NC}"
                    else
                        echo -e "  ${YELLOW}警告: $ext のインストールをスキップ${NC}"
                        echo -e "  ${YELLOW}  理由: $EXT_ERR${NC}"
                    fi
                    rm -f "$VSIX_TMP"
                fi
            fi
            ((count++))
        fi
    done < "$EXT_FILE"

    echo -e "  ${GREEN}拡張機能のインストール完了${NC}"
elif [ ! -f "$EXT_FILE" ]; then
    echo -e "  ${YELLOW}警告: cleanExtentions.txt が見つかりません${NC}"
fi

echo ""

# ============================================================
# 6. VS Code 日本語化設定
# ============================================================
echo -e "${GREEN}VS Code の表示言語を日本語に設定中...${NC}"

# VS Code は表示言語を User/locale.json ではなく argv.json から読み込む。
# ポータブルモードでは argv.json は VSCODE_PORTABLE 直下（= data フォルダ直下）に
# 置かれる。user-data フォルダの中ではないので注意。
USER_DATA_DIR="$VSCODE_DIR/data/user-data"
ARGV_FILE="$VSCODE_DIR/data/argv.json"
LEGACY_LOCALE_FILE="$USER_DATA_DIR/User/locale.json"

mkdir -p "$VSCODE_DIR/data"
if [ -f "$LEGACY_LOCALE_FILE" ]; then
    # 旧バージョンのスクリプトが作成した locale.json を argv.json にリネーム
    mv "$LEGACY_LOCALE_FILE" "$ARGV_FILE"
    echo -e "  ${GREEN}旧設定ファイル (locale.json) を argv.json にリネームしました${NC}"
else
    cat > "$ARGV_FILE" << 'EOF'
{
    "locale": "ja"
}
EOF
    echo -e "  ${GREEN}日本語化設定 (argv.json) の作成完了${NC}"
fi
echo ""

# ============================================================
# 7. settings.json のコピー
# ============================================================
echo -e "${GREEN}設定ファイルをコピー中...${NC}"

SETTINGS_SOURCE="$SCRIPT_DIR/config/settings.json"
SETTINGS_DIR="$VSCODE_DIR/data/user-data/User"
SETTINGS_DEST="$SETTINGS_DIR/settings.json"
WORKSPACE_SETTINGS="$SCRIPT_DIR/workspace/.vscode/settings.json"

# config/ はセットアップ完了時に自己削除されるため、フォルダ移動後に
# パス修正だけを目的として setup.command を再実行するケースでは
# config/settings.json (コピー元) が存在しない。そのため「config から
# コピーする」処理と「インタープリタパスを書き込む」処理を分離し、
# 既存の settings.json (前回のコピー済みファイル) に対しても
# パス書き込みだけは常に行えるようにする。
if [ -f "$SETTINGS_SOURCE" ]; then
    mkdir -p "$SETTINGS_DIR"
    cp "$SETTINGS_SOURCE" "$SETTINGS_DEST"
    echo -e "  ${GREEN}settings.json のコピー完了${NC}"
elif [ ! -f "$SETTINGS_DEST" ]; then
    echo -e "  ${YELLOW}警告: settings.json が見つかりません${NC}"
fi

# python.defaultInterpreterPath は ${env:...} 展開に対応していないため、
# 実際の Python パスを直接書き込む。初回セットアップ時のプレースホルダー
# (${env:PORTABLE_PYTHON_PATH}) だけでなく、以前のセットアップで書き込み
# 済みの絶対パス（フォルダ移動で古くなったもの）も置き換え対象にする。
for TARGET_SETTINGS in "$SETTINGS_DEST" "$WORKSPACE_SETTINGS"; do
    if [ -f "$TARGET_SETTINGS" ]; then
        sed -i '' -E "s|\"python\.defaultInterpreterPath\": *\"[^\"]*\"|\"python.defaultInterpreterPath\": \"$PYTHON_BIN\"|" "$TARGET_SETTINGS"
        echo -e "  ${GREEN}Python インタープリタパスを更新完了: $TARGET_SETTINGS${NC}"
    fi
done

echo ""

# ============================================================
# 完了メッセージ
# ============================================================
echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN} セットアップが完了しました！${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${WHITE}次の手順で起動してください:${NC}"
echo -e "  ${YELLOW}1. launch-vscode.command をダブルクリック${NC}"
echo -e "  ${YELLOW}2. VS Code が起動します${NC}"
echo ""
echo -e "${WHITE}⚠️  初回起動時だけ、もう一度開き直してください:${NC}"
echo -e "  ${GRAY}初めて起動したときだけ、メニューなどが英語表示になることがあります。${NC}"
echo -e "  ${GRAY}その場合は一度 VS Code をしっかり終了 (Cmd+Q) してから、${NC}"
echo -e "  ${GRAY}もう一度 launch-vscode.command を開いてください。${NC}"
echo -e "  ${GRAY}2回目からは日本語で表示されます。${NC}"
echo ""
echo -e "${WHITE}インストールされた環境:${NC}"
echo -e "  ${GRAY}・Python 3.13 (自己完結型スタンドアロンビルド)${NC}"
echo -e "  ${GRAY}・VS Code (Mac版 / $VSCODE_OS)${NC}"
echo -e "  ${GRAY}・Python ライブラリ (numpy, pandas, jupyter 等)${NC}"
echo ""

# ============================================================
# セットアップファイルの自動削除
# ============================================================
echo -e "${YELLOW}セットアップファイルを削除中...${NC}"

items_to_delete=(
    "$SCRIPT_DIR/config"
    "$SCRIPT_DIR/get-pip.py"
)

for item in "${items_to_delete[@]}"; do
    if [ -e "$item" ]; then
        rm -rf "$item"
        echo -e "  ${GRAY}削除完了: $item${NC}"
    fi
done

echo -e "  ${GREEN}セットアップファイルの削除が完了しました。${NC}"
echo ""
echo "Press any key to exit..."
read -n 1 -s
echo ""
