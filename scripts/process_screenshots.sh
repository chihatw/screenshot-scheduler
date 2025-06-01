#!/bin/bash

# 昨日の日付を MMDD 形式で取得
YESTERDAY=$(date -v-1d "+%m%d")

# スクリーンショットのディレクトリ
SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
TARGET_DIR="$SCREENSHOTS_DIR/$YESTERDAY"
PROJECT_IMAGES_DIR="/Users/chiha/projects-active/screenshot-scheduler/images"

# Node.js のパスを設定（Automator実行時のため）
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# 前日のスクリーンショットを探す
echo "前日 ($YESTERDAY) のスクリーンショットを検索中..."

# スクリーンショット検索（複数のパターンに対応）
SCREENSHOTS=$(find "$SCREENSHOTS_DIR" -maxdepth 1 -type f \( -name "${YESTERDAY}_*.jpg" -o -name "${YESTERDAY}_*.png" -o -name "*${YESTERDAY}*.jpg" -o -name "*${YESTERDAY}*.png" \))

# スクリーンショットが見つからず、ディレクトリが存在する場合は、すでに移動されたと仮定
if [ -z "$SCREENSHOTS" ] && [ -d "$TARGET_DIR" ]; then
    # ディレクトリ内のファイル数を確認
    FILE_COUNT=$(find "$TARGET_DIR" -type f | wc -l)
    
    # サブディレクトリにファイルがある場合は処理を続行
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "サブディレクトリにはすでにファイルがあります。スクリーンショットの移動をスキップします。"
        SCREENSHOTS_ALREADY_MOVED=true
    else
        echo "サブディレクトリは空です。処理を中止します。"
        exit 1
    fi
fi

# スクリーンショットが見つかった場合または既に移動済みの場合の処理
if [ -n "$SCREENSHOTS" ] || [ "$SCREENSHOTS_ALREADY_MOVED" = true ]; then
    # ターゲットディレクトリがなければ作成
    if [ ! -d "$TARGET_DIR" ]; then
        echo "ディレクトリを作成: $TARGET_DIR"
        mkdir -p "$TARGET_DIR"
    fi
    
    # スクリーンショットをサブディレクトリに移動
    echo "スクリーンショットをサブディレクトリに移動中..."
    for screenshot in $SCREENSHOTS; do
        if [ -f "$screenshot" ]; then
            mv "$screenshot" "$TARGET_DIR/"
            echo "移動: $screenshot -> $TARGET_DIR/"
        fi
    done
    
    # プロジェクトの images ディレクトリを空にする
    echo "プロジェクトの images ディレクトリを空にする..."
    rm -rf "$PROJECT_IMAGES_DIR"/*
    
    # 前日のスクリーンショットをプロジェクトディレクトリにコピー
    echo "前日のスクリーンショットをプロジェクトディレクトリにコピー中..."
    cp "$TARGET_DIR"/* "$PROJECT_IMAGES_DIR/"
    
    # Node.jsサーバーを起動（バックグラウンドで）
    cd /Users/chiha/projects-active/screenshot-scheduler
    
    # Node.js のパスを指定（NVMやHomebrewの場合に対応）
    NODE_PATH="/Users/chiha/.nvm/versions/node/v22.16.0/bin/node"
    if [ ! -f "$NODE_PATH" ]; then
        # デフォルトパスを試す
        NODE_PATH=$(which node 2>/dev/null)
        if [ -z "$NODE_PATH" ]; then
            # 他の一般的な場所を試す
            for possible_path in "/usr/local/bin/node" "/opt/homebrew/bin/node" "/usr/bin/node"; do
                if [ -f "$possible_path" ]; then
                    NODE_PATH="$possible_path"
                    break
                fi
            done
        fi
    fi
    
    # 既存のNode.jsサーバーを停止
    NODE_SERVER_PID=$(ps aux | grep "node server.js" | grep -v grep | awk '{print $2}')
    if [ -n "$NODE_SERVER_PID" ]; then
        echo "既存のNode.jsサーバーを停止中..."
        kill $NODE_SERVER_PID
        sleep 1
    fi
    
    echo "Node.jsサーバーを起動中..."
    nohup $NODE_PATH server.js > /dev/null 2>&1 &
    
    # Safariでローカルホストを開く
    sleep 2  # サーバーが起動するのを待つ
    open -a Safari http://localhost:3000
    
    echo "処理が完了しました。"
else
    echo "前日 ($YESTERDAY) のスクリーンショットが見つかりませんでした。"
    exit 1
fi
