# このリポジトリで作業するときの約束

Mac 版の Portable Python + VS Code セットアップ（`kawaba/autosetup-vscode-python-book-mac`）。
Windows 版は `kawaba/autosetup-vscode-python-book`。使い方の説明や GitHub Copilot の設定ガイドは
Windows 版に載せている。

## 応答のしかた（利用者からの依頼）

- 機能追加や修正でリポジトリを更新したときは、応答に次をはっきり書く。
  - どのリポジトリか（例: `kawaba/autosetup-vscode-python-book-mac`）
  - どのブランチに push したか
  - 変更したファイル（リポジトリ内のパス）
- 利用者は GitHub の操作に慣れていない。GitHub での操作が必要なときは、
  画面のどこを押すかまで、手順を 1 つずつ細かく説明する。
- これまでは `main` に直接コミットして push している。

## 構成

- `portable-python-vscode/setup.command`: セットアップ本体。Python（python-build-standalone）、
  pip ライブラリ、VS Code、拡張機能、HackGen フォント、`VS Code Python.app` を用意し、Dock に置く。
  完了時に `config/` を自分で削除する。
- `portable-python-vscode/launch-vscode.command`: VS Code の起動スクリプト。
- `portable-python-vscode/VS Code Python.app`: `setup.command` が `osacompile` で生成する起動用アプリ
  （`.gitignore` 済み）。中身は `launch-vscode.command` を `do shell script` で呼ぶだけ。
- `portable-python-vscode/config/settings.json`: VS Code のユーザー設定の元。
  `vscode/data/user-data/User/settings.json` にコピーされる。
- `portable-python-vscode/workspace/.vscode/settings.json`: ワークスペース設定。
  ユーザー設定より優先されるので、同じ項目を両方に書くときは両方を直す。

## 方針（理由つき）

- **Homebrew は使わない。** インストールに管理者権限が必要で、学校の Mac では使えない。
  以前は Homebrew の失敗で `set -e` によりセットアップ全体が止まっていた。
  必要なものは GitHub などから `curl` で直接取得する。
- **管理者権限が要らない方法だけを使う。** フォントは `~/Library/Fonts` に置く。
- **フォント**
  - エディター（`editor.fontFamily`）は **HackGen**。SPD の罫線（`─│├└┬`）が全角幅で、
    日本語と混ざっても縦罫線がそろう。`HackGen Console` は罫線が半角幅なので使わない。
    Mac 標準の Menlo も罫線が半角幅でずれる。
  - ターミナル（`terminal.integrated.fontFamily`）は **Menlo**。ターミナルは罫線を半角 1 マスとして
    扱うので、HackGen だと表示が崩れる。指定しないと `editor.fontFamily` が使われるので、必ず指定する。
  - HackGen は v2.10.0 の配布 zip から `HackGen-Regular.ttf` と `HackGen-Bold.ttf` だけを取り出す。
- **起動の流れ**: `VS Code Python.app` → `launch-vscode.command` →
  `open -a ... --env VSCODE_PORTABLE=... --args --locale=ja --disable-workspace-trust workspace`
  - `open` で起動すると VS Code がターミナルから切り離される（ターミナルを閉じても終了しない）。
  - `open` で起動したアプリには環境変数が引き継がれないので、`--env` で渡す。
  - `VS Code Python.app` はその Mac の上で作るので quarantine の印が付かず、Gatekeeper の警告が出ない。
    ファイル名が Finder や Dock に表示される名前になる（以前は `launch-vscode.app` だった。
    `setup.command` は古い名前のアプリを消す）。
  - アプリ自体はフォルダの外へ移せない（`path to me` で隣の `launch-vscode.command` を探すため）。
    `setup.command` が Dock の `persistent-apps` に追加して `killall Dock` で反映させる。
    既に置いてあれば追加しない（Dock は場所を `file://` の URL で覚えることがあるので、パスに戻して比べる）。
  - Mac では ✕ でウインドウを閉じてもアプリは終了しない（終了は Cmd + Q）。動いている VS Code に
    `open -a ... --args` を送っても引数は無視され、空のウインドウが開くだけになる。そこで
    `launch-vscode.command` は、このフォルダの VS Code が動いているときは付属の `code` コマンドで
    workspace を開かせる。
  - この Mac にはほかの場所の VS Code も同時に動いていることがある（バンドル ID は同じ）。
    プロセスは実行ファイルのフルパス（`ps -axo comm=`）で見分ける。
- **日本語表示**: VS Code は表示言語を起動した瞬間に決めるが、翻訳の一覧
  `vscode/data/user-data/languagepacks.json` は初めて起動したときに作られる。そのままだと最初の起動は
  必ず英語になるので、`setup.command` の最後に一度隠して起動し（`open -g -j`）、一覧ができたら
  そのプロセスだけを `kill` で終了させている。次の起動で翻訳キャッシュ `clp/` が作られ、日本語になる。
- **Gatekeeper**: ZIP から展開したファイルには `com.apple.quarantine` が付く。
  `setup.command` の最初に `xattr -dr com.apple.quarantine` でフォルダ全体から外している。
  `setup.command` 自身の初回の警告は避けられない（macOS 15 Sequoia 以降は「右クリック → 開く」が使えず、
  「システム設定」→「プライバシーとセキュリティ」→「このまま開く」で許可する）。

## 文字コード・ファイルの注意

- `.command` / `.sh` は **LF 改行**・**実行権限 755** で保存する（`.gitattributes` で LF に固定済み）。
  CRLF だと `bad interpreter: /bin/bash^M` で実行できない。
- macOS の `/bin/bash` は 3.2。bash 4 以降の機能（連想配列、`${var,,}` など）は使わない。
- `sed` は BSD 版（`sed -i ''`）。GNU 版の書き方は使わない。

## 検証のしかた

- **リポジトリの作業フォルダの中で `setup.command` を実行しない。** ダウンロードしたファイルが
  リポジトリに入り、完了時に `config/` が削除される。試すときは別の場所にコピーしたフォルダで行う。
- 処理の一部だけを確かめるときは、その部分を取り出したスクリプトを一時フォルダで動かす。
- Gatekeeper の動きは、`git clone` したファイルでは確かめられない（quarantine の印が付かない）。
  GitHub から **Download ZIP** でダウンロードして展開したもので確かめる。
- 画面の表示（警告ダイアログ、日本語表示、SPD の縦罫線）は、利用者に見てもらって確認する。
- VS Code を動かして試すフォルダは、`~/pvtest` のような**短いパス**に置く。通信用のソケット
  `user-data/1.14-main.sock` のパスが 103 文字を超えると VS Code が正しく起動しない
  （スクラッチパッドのパスは長すぎる）。試したあとは削除する。

## 未解決の課題

- 特になし。以前の「日本語になるまで何回か再起動が必要」は、上の「日本語表示」と
  ✕ で閉じても終了しないこと（「起動の流れ」）が原因だった。
