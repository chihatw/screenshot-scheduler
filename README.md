# screenshot-scheduler

一定時間ごとに Mac のスクリーンショットを撮影し、`~/Pictures/Screenshots` に保存するスクリプトです。

- Time Machine のバックアップからは除外してください。

### process_screenshots.sh

- `~/Pictures/Screenshots` 内の前日のスクリーンショットをサブディレクトリにまとめ、画像ビューアを起動します。
- 主な機能：
  1. 前日のスクリーンショット（ファイル名パターン: MMDD*\*.jpg、MMDD*\*.png など）を検索
  2. ファイルを日付ごとのサブディレクトリ（例: `~/Pictures/Screenshots/0531`）に移動
  3. 移動したスクリーンショットを `/images` ディレクトリにコピー
  4. Node.js サーバーを起動
  5. Safari で画像ビューア（http://localhost:3000）を開く
- 既にサブディレクトリに移動済みの場合も対応（コピーと表示のみ実行）
- 複数の Node.js 環境に対応（NVM や Homebrew など）
- スクリプトの場所: `scripts/process_screenshots.sh`
- 実行例:
  ```sh
  ./scripts/process_screenshots.sh
  ```

| スクリプト名                      | 役割・特徴                                                                              |
| :-------------------------------- | :-------------------------------------------------------------------------------------- |
| `scripts/capture.sh`              | すべてのディスプレイのスクリーンショットを撮影し、`~/Pictures/Screenshots` に保存します |
| `scripts/cleanup.sh`              | 2 日以上前のスクリーンショット画像（.png）を自動で削除します                            |
| `scripts/process_screenshots.sh`  | 前日のスクリーンショットをサブディレクトリに移動し、画像ビューアを起動します            |
| `scripts/com.chiha.cleanup.plist` | launchd 用の設定ファイル。`cleanup.sh`を毎日自動実行するために使用します                |

---

## 運用方法（おすすめの使い方）

### スクリーンショットの自動取得

- Automator アプリを定期的に起動することで、Mac のスクリーンショットを自動で保存できます。
- 例: 1 分ごとに実行したい場合は、カレンダーやリマインダー、または別のスケジューラを利用してください。

### 古いスクリーンショットの自動削除

- 定期的に `scripts/cleanup.sh` を実行することで、2 日以上前の画像ファイルを自動で削除できます。
- Automator アプリやスケジューラで 1 日 1 回などの頻度で実行するのがおすすめです。
  ```sh
  /Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh
  ```

### launchd（macOS 標準）による自動削除の設定方法

macOS では`launchd`を使うことで、スリープや電源 OFF 時も含めて、毎日決まった時刻に`cleanup.sh`を自動実行できます。

- 12:00 に Mac がスリープや電源 OFF の場合、復帰・起動時に自動で実行されます。

#### 1. plist ファイルの用意

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

#### 3. LaunchAgents ディレクトリへコピー

```zsh
cp /Users/chiha/projects-active/screenshot-scheduler/scripts/com.chiha.cleanup.plist ~/Library/LaunchAgents/
```

#### 4. launchd へ登録

```zsh
launchctl load ~/Library/LaunchAgents/com.chiha.cleanup.plist
```

#### 5. 動作

- 毎日 12:00 に自動実行されます。
- 12:00 に Mac がスリープや電源 OFF の場合、復帰・起動時に自動で実行されます。
- 設定を変更した場合は`launchctl unload`→`load`で再読み込みしてください。

---

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

## 前日のスクリーンショットをサブディレクトリにまとめる

### Automator アプリ「ScreenshotViewer.app」

- Automator で「アプリケーション」として作成し、
  - 「シェルスクリプトを実行」アクションに以下のコードを設定
    ```sh
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    cd /Users/chiha/projects-active/screenshot-scheduler
    /Users/chiha/projects-active/screenshot-scheduler/scripts/process_screenshots.sh
    ```
- 任意の場所に保存し、ダブルクリックで実行すると：
  - 前日のスクリーンショットを整理
  - Node.js サーバーを起動
  - Safari で画像ビューアを表示

> ※ capture.sh などで保存したファイルを日付ごとに整理したい場合に便利です。

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
   - 10 分ごとに Automator アプリを起動:
     ```sh
     */10 * * * * open /Users/chiha/projects-active/screenshot-scheduler/ScreenshotCapture.app
     ```
     > crontab はスリープ時や電源オフ時には実行されません。Mac がスリープ・電源オフ中はスクリーンショットは撮影されません。
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

## 新機能: 画像ペア表示とナビゲーション

### 概要

- `/images` ディレクトリ内の画像ペアをブラウザで表示する機能を追加しました。
- キーボードの矢印キーを使用して画像ペアを切り替えることができます。
- 自動再生機能により、0.8 秒ごとに画像ペアを自動で切り替えることができます。
- 画像にマウスホバーすると自動再生が一時停止する機能を実装しました。
- 画像ファイル名を日本語形式の日付と時刻に変換して表示します（例: `MMDD_HHMM_1.jpg` → `M月D日 H時MM分`）。

### サーバー設定

- Node.js を使用して静的ファイルを配信し、画像ファイル名を取得する API を提供します。
- サーバーはポート `3000` で動作します。

#### サーバーの起動方法

1. 必要な依存関係をインストールします。
   ```sh
   npm install
   ```
2. サーバーを起動します。
   ```sh
   node server.js
   ```
3. ブラウザで以下の URL にアクセスしてください。
   ```
   http://localhost:3000
   ```

### API エンドポイント

- `/api/images`
  - `/images` ディレクトリ内の `.jpg` ファイル名を取得します。
  - ファイル名はソートされた状態で返されます。

### 注意事項

- ポート `5000` が macOS の Control Center によって使用されている場合があるため、ポート `3000` を使用するよう設定しました。
- サーバーが正しく動作しない場合は、他のプロセスがポート `3000` を使用していないか確認してください。

### 画像ペア表示機能の操作方法

1. 矢印キーで画像ペアを切り替えます。
   - 左矢印キー: 前の画像ペア
   - 右矢印キー: 次の画像ペア
2. 画像の上部にファイル名が日本語形式で表示されます。
3. スライダーを使用して任意の画像ペアに素早く移動できます。
   - カウンター（例: 1/65）の下にあるスライダーをドラッグすると、対応する位置の画像ペアが表示されます。
4. 自動再生と停止機能：
   - 「自動再生」ボタンをクリックすると、0.8 秒ごとに次の画像ペアに自動で切り替わります。
   - 「停止」ボタンをクリックすると、自動再生が停止します。
   - 画像にマウスカーソルを合わせると自動再生が一時停止し、マウスが離れると再開します。
   - 矢印キーやスライダーで手動操作すると、自動再生は停止します。
5. 画像をクリックすると拡大表示されます。
   - 画像をクリックすると、モーダルウィンドウで拡大表示されます。
   - 拡大表示中は自動再生が一時停止し、閉じると元の状態に戻ります。
   - 拡大表示を閉じるには、以下のいずれかの操作を行います：
     - 画像外の暗い領域をクリック
     - 右上の × ボタンをクリック
     - Esc キーを押す

### ファイル構成

- `index.html`: 画像ペア表示のための HTML ファイル。自動再生・停止機能とホバー機能を含みます。
- `server.js`: Node.js サーバーの設定と API 実装。
- `/images`: 表示対象の画像ファイルを格納するディレクトリ。
