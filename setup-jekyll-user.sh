#!/bin/bash

echo "============================================"
echo "Jekyll環境構築（ユーザー権限での操作）"
echo "============================================"

set -e

# Gemパスの設定
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

# .bashrcに追加（既に存在する場合はスキップ）
if ! grep -q 'GEM_HOME' ~/.bashrc; then
    echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
    echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
fi

echo ""
echo "[1/4] Bundler と Jekyll のインストール"
gem install bundler jekyll --no-document
echo "✓ インストール完了"

echo ""
echo "[2/4] プロジェクトディレクトリへ移動"
cd /var/www/photography-site
echo "✓ ディレクトリ: $(pwd)"

echo ""
echo "[3/4] Bundle install（依存関係のインストール）"
bundle install
echo "✓ 依存関係インストール完了"

echo ""
echo "[4/4] Jekyllサイトのビルド"
bundle exec jekyll build
echo "✓ ビルド完了"

echo ""
echo "============================================"
echo "✓ セットアップ完了！"
echo "============================================"
echo ""
echo "サイトURL: https://sy-ryosuke.site"
echo ""
echo "次のステップ:"
echo "1. _config.ymlを編集: cd /var/www/photography-site && nano _config.yml"
echo "2. 写真を追加: images/fulls/ と images/thumbs/"
echo "3. 再ビルド: bundle exec jekyll build"
echo ""
echo "設定ファイル編集例:"
echo "  title: あなたのサイト名"
echo "  description: サイトの説明"
echo "  url: https://sy-ryosuke.site"
echo "  baseurl: \"\" # 空のまま"
echo "============================================"


