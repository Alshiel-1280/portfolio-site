#!/bin/bash

echo "================================================"
echo "Jekyll写真ポートフォリオサイトへの自動切り替え"
echo "================================================"
echo ""
echo "このスクリプトはssh接続を通じてサーバーを設定します。"
echo "サーバーのsudoパスワードが必要です。"
echo ""

SERVER="portfolio-admin@133.18.115.106"

# ステップ1: sudo操作
echo "[Step 1] sudo権限が必要な操作を実行します..."
ssh -t $SERVER "sudo bash ~/setup-jekyll-sudo.sh"

if [ $? -ne 0 ]; then
    echo "❌ エラーが発生しました。"
    exit 1
fi

# ステップ2: ユーザー操作
echo ""
echo "[Step 2] ユーザー権限での操作を実行します..."
ssh $SERVER "bash ~/setup-jekyll-user.sh"

if [ $? -ne 0 ]; then
    echo "❌ エラーが発生しました。"
    exit 1
fi

echo ""
echo "================================================"
echo "✅ 切り替え完了！"
echo "================================================"
echo ""
echo "🌐 サイトURL: https://sy-ryosuke.site"
echo ""
echo "📝 次のステップ:"
echo "   1. 設定ファイルを編集してください"
echo "   2. 写真をアップロードしてください"
echo "   3. サイトを再ビルドしてください"
echo ""
echo "詳細は SWITCH_INSTRUCTIONS.md をご覧ください。"
echo "================================================"


