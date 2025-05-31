#!/bin/bash

# スクリーンショットを撮影する
# ~/Pictures/Screenshots に保存

DIR=~/Pictures/Screenshots
mkdir -p "$DIR"

# 接続されているディスプレイの数を取得
NUM_DISPLAYS=$(system_profiler SPDisplaysDataType | grep -c 'Resolution:')

for ((i=1; i<=NUM_DISPLAYS; i++)); do
  FILENAME="$(date +%m%d_%H%M)_${i}.png"
  screencapture -x -D $i "$DIR/$FILENAME"
  echo "Saved: $DIR/$FILENAME"
done
