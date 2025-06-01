# Automator での ScreenshotViewer.app 作成手順

## 1. Automator を起動する

- Finder から「アプリケーション」→「Automator」を開きます

## 2. 新規ドキュメントを作成

- 「アプリケーション」を選択して「選択」をクリックします

## 3. シェルスクリプト実行アクションを追加

- 左側の「ライブラリ」から「ユーティリティ」を選択します
- 「シェルスクリプトを実行」を右側のワークフローエリアにドラッグ＆ドロップします
- 以下の設定を行います:

  - シェル: `/bin/bash`
  - 入力の受け渡し: `スクリプトのみを渡す`
  - スクリプト:

  ```bash
  # PATHを拡張してNode.jsを含める
  export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/chiha/.nvm/versions/node/current/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
  cd /Users/chiha/projects-active/screenshot-scheduler

  # スクリプトを実行
  /Users/chiha/projects-active/screenshot-scheduler/scripts/process_screenshots.sh
  ```

## 4. アプリケーションを保存

- メニューから「ファイル」→「保存」を選択します
- 名前を「ScreenshotViewer」とします
- 場所は「アプリケーション」または任意の場所を選択します
- 「保存」をクリックします

## 5. 作成したアプリケーションのセキュリティ設定

- 作成したアプリケーションを初めて実行する際に、セキュリティの警告が表示される場合があります
- 「システム環境設定」→「セキュリティとプライバシー」で、アプリの実行を許可する必要があるかもしれません
- ファイルアクセス許可が必要な場合も、同様にプライバシー設定から許可を与えてください

## トラブルシューティング

- アプリが正常に動作しない場合は、デバッグログを確認してください:
  `/Users/chiha/projects-active/screenshot-scheduler/debug_log.txt`
- シェルスクリプトを直接ターミナルから実行して、エラーを確認することも有効です:
  ```bash
  cd /Users/chiha/projects-active/screenshot-scheduler
  ./scripts/process_screenshots.sh
  ```
