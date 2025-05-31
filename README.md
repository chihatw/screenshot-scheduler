# screenshot-scheduler

一定時間ごとに Mac のスクリーンショットを撮影し、`~/Pictures/Screenshots` に保存するスクリプトです。

- Time Machine のバックアップからは除外してください。

## 注意: 画面収録権限について

- スクリーンショットが壁紙のみになる場合は、**システム設定 > プライバシーとセキュリティ > 画面収録** で「ターミナル」に画面収録の権限を与えてください。
- 権限を付与した後は、**Mac の再起動**が必要です。

## 注意: Automator での環境変数について

- Automator でシェルスクリプトを実行する場合、ターミナルとは異なり PATH などの環境変数が異なります。
- そのため、ImageMagick の convert など外部コマンドを使う場合は、必ずフルパス（例: /usr/local/bin/convert）で指定してください。

## ファイル名の形式

- `MMDD_HHMM_ディスプレイ番号.png` 形式で保存されます（例: `0531_0913_1.png`）。
- 複数ディスプレイが接続されている場合、各ディスプレイごとに保存されます。

## scripts/capture.sh

- 接続されているすべてのディスプレイのスクリーンショットを撮影し、`~/Pictures/Screenshots` に保存します。
- 実行例:
  ```sh
  ./scripts/capture.sh
  ```

## scripts/cleanup.sh

- `~/Pictures/Screenshots` 内のファイル名を見て、2 日以上前のスクリーンショット画像（.png）を削除します。
- ファイル名の先頭 4 桁（MMDD）が今日・昨日以外のファイルが削除対象です。
- 実行例:
  ```sh
  ./scripts/cleanup.sh
  ```

## Automator 経由での自動実行方法

crontab では macOS のセキュリティ制限により壁紙しか撮影できない場合があります。Automator アプリ経由で capture.sh を実行することで、画面収録権限を正しく反映できます。

### Automator アプリの作成手順

1. **Automator**を起動し、「アプリケーション」を新規作成します。
2. 「シェルスクリプトを実行」アクションを追加し、下記のように記述します。
   ```sh
   /Users/chiha/projects-active/screenshot-scheduler/scripts/capture.sh
   ```
3. 任意の場所にアプリケーションとして保存します（例: `ScreenshotCapture.app`）。
4. **システム設定 > プライバシーとセキュリティ > 画面収録** で、作成した Automator アプリに画面収録の権限を与えます。
5. 必要に応じて Mac を再起動します。
6. 定期実行したい場合は、カレンダーの通知やリマインダー、または別のスケジューラからこのアプリを`open`コマンドで起動してください。
   ```sh
   open /path/to/ScreenshotCapture.app
   ```

### crontab で Automator アプリを定期実行する方法

1. ターミナルで以下のコマンドを実行して crontab を編集します。
   ```sh
   crontab -e
   ```
2. エディタが開いたら、下記のような行を追加します。
   - 1 分ごとに Automator アプリを起動:
     ```sh
     * * * * * open /Users/chiha/projects-active/screenshot-scheduler/ScreenshotCapture.app
     ```
3. 保存してエディタを閉じると、設定が反映されます。

### crontab のスケジュール確認方法

- 現在設定されている crontab のスケジュールは、以下のコマンドで確認できます。
  ```sh
  crontab -l
  ```

#### vi（Vim）エディタの簡単な操作方法

- 編集を始める: `i` を押す（挿入モード）
- 編集が終わったら: `Esc` を押す（ノーマルモード）
- 保存して終了: `:wq` と入力し Enter
- 保存せず終了: `:q!` と入力し Enter

## 運用方法

### スクリーンショットの自動取得

- Automator アプリを定期的に起動することで、Mac のスクリーンショットを自動で保存できます。
- 例: 1 分ごとに実行したい場合は、カレンダーやリマインダー、または別のスケジューラを利用してください。

### 古いスクリーンショットの自動削除

- 定期的に `scripts/cleanup.sh` を実行することで、2 日以上前の画像ファイルを自動で削除できます。
- Automator アプリやスケジューラで 1 日 1 回などの頻度で実行するのがおすすめです。
  ```sh
  /Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh
  ```

### launchd（macOS標準）による自動削除の設定方法

macOSでは`launchd`を使うことで、スリープや電源OFF時も含めて、毎日決まった時刻に`cleanup.sh`を自動実行できます。

#### 1. plistファイルの用意

`scripts/com.chiha.cleanup.plist` を用意します（本リポジトリにサンプルあり）。内容例：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.chiha.cleanup</string>
  <key>ProgramArguments</key>
  <array>
    <string>/Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>12</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

#### 2. 実行権限の付与

```zsh
chmod +x /Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh
```

#### 3. LaunchAgentsディレクトリへコピー

```zsh
cp /Users/chiha/projects-active/screenshot-scheduler/scripts/com.chiha.cleanup.plist ~/Library/LaunchAgents/
```

#### 4. launchdへ登録

```zsh
launchctl load ~/Library/LaunchAgents/com.chiha.cleanup.plist
```

#### 5. 動作

- 毎日12:00に自動実行されます。
- 12:00にMacがスリープや電源OFFの場合、復帰・起動時に自動で実行されます。
- 設定を変更した場合は`launchctl unload`→`load`で再読み込みしてください。

---
