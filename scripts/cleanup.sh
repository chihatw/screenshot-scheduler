#!/bin/bash

# ~/Pictures/Screenshots のファイル名を見て二日以上前のファイルを削除する
# ファイル名は FILENAME="$(date +%m%d_%H%M)_${i}.png" のようになっている

DIR=~/Pictures/Screenshots

# 今日・昨日の日付を取得
TODAY=$(date +%m%d)
YESTERDAY=$(date -v-1d +%m%d)

for file in "$DIR"/*.png; do
  BASENAME=$(basename "$file")
  FILEDATE=${BASENAME:0:4}  # MMDD 部分のみでOK
  # 今日・昨日以外なら削除
  if [[ "$FILEDATE" != "$TODAY" && "$FILEDATE" != "$YESTERDAY" ]]; then
    echo "削除: $file"
    rm "$file"
  fi
done
