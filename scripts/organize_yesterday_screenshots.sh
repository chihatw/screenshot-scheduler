#!/bin/bash

# 前日の日付を MMDD 形式で取得
target_date=$(date -v-1d +%m%d)

# スクリーンショット保存先
dir=~/Pictures/Screenshots

# サブフォルダ作成
dest_dir="$dir/$target_date"
mkdir -p "$dest_dir"

# ファイルを走査し、前日分を移動
for file in "$dir"/*.jpg; do
  # ファイル名から日付部分を抽出（例: 0601_1200_1.jpg → 0601）
  basename=$(basename "$file")
  file_date=${basename:0:4}
  if [[ "$file_date" == "$target_date" ]]; then
    mv "$file" "$dest_dir/"
    echo "Moved: $basename -> $dest_dir/"
  fi
done
