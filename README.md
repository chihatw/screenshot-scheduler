# screenshot-scheduler

一定時間ごとに Mac のスクリーンショットを撮影し、`~/Pictures/Screenshots` に保存するスクリプトです。

- Time Machine のバックアップからは除外してください。

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

## crontab のスケジュール確認方法

- 現在設定されている crontab のスケジュールは、以下のコマンドで確認できます。
  ```sh
  crontab -l
  ```

## crontab の設定方法

1. ターミナルで以下のコマンドを実行して crontab を編集します。
   ```sh
   crontab -e
   ```
2. エディタが開いたら、下記のような行を追加します。
   - 1 分ごとにスクリーンショットを取得:
     ```sh
     * * * * * /Users/chiha/projects-active/screenshot-scheduler/scripts/capture.sh
     ```
   - 1 日 1 回、古いスクリーンショットを削除:
     ```sh
     0 3 * * * /Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh
     ```
3. 保存してエディタを閉じると、設定が反映されます。

### vi（Vim）エディタの簡単な操作方法

- 編集を始める: `i` を押す（挿入モード）
- 編集が終わったら: `Esc` を押す（ノーマルモード）
- 保存して終了: `:wq` と入力し Enter
- 保存せず終了: `:q!` と入力し Enter

## 運用方法

### スクリーンショットの自動取得

- crontab を使って `scripts/capture.sh` を定期実行することで、Mac のスクリーンショットを自動で保存できます。
- 例: 1 分ごとに実行する場合は、以下のように crontab を設定します。
  ```sh
  * * * * * /Users/chiha/projects-active/screenshot-scheduler/scripts/capture.sh
  ```
- 本番運用では `*/15 * * * *` のように 15 分間隔などに変更してください。

### 古いスクリーンショットの自動削除

- 定期的に `scripts/cleanup.sh` を実行することで、2 日以上前の画像ファイルを自動で削除できます。
- crontab で 1 日 1 回などの頻度で実行するのがおすすめです。
  ```sh
  0 3 * * * /Users/chiha/projects-active/screenshot-scheduler/scripts/cleanup.sh
  ```
