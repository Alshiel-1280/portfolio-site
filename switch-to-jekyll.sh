#!/bin/bash

echo "============================================"
echo "Jekyll写真ポートフォリオサイトへの切り替え"
echo "============================================"

# エラーハンドリング
set -e

# NVM読み込み
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo ""
echo "このスクリプトにはsudo権限が必要です。"
echo "パスワードを入力してください。"
echo ""

# sudoパスワードをキャッシュ
sudo -v

# バックグラウンドでsudoセッションを維持
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

echo ""
echo "[1/9] 既存のNext.jsアプリケーションをバックアップ"
cd /var/www
if [ -d "portfolio-site-backup" ]; then
    sudo rm -rf portfolio-site-backup
fi
sudo cp -r portfolio-site portfolio-site-backup
echo "✓ バックアップ完了: /var/www/portfolio-site-backup"

echo ""
echo "[2/9] PM2で動作中のアプリケーションを停止"
pm2 stop portfolio || echo "既に停止しています"
pm2 delete portfolio || echo "PM2プロセスが見つかりません"
echo "✓ PM2プロセス停止完了"

echo ""
echo "[3/9] 既存のポートフォリオディレクトリを削除"
sudo rm -rf /var/www/portfolio-site
echo "✓ 削除完了"

echo ""
echo "[4/9] 新しいリポジトリをクローン"
cd /var/www
sudo git clone https://github.com/rampatra/photography.git photography-site
sudo chown -R portfolio-admin:portfolio-admin photography-site
cd photography-site
echo "✓ クローン完了"

echo ""
echo "[5/9] Ruby環境のセットアップ"
# Rubyがインストールされているか確認
if ! command -v ruby &> /dev/null; then
    echo "Rubyをインストール中..."
    sudo apt-get update
    sudo apt-get install -y ruby-full build-essential zlib1g-dev
fi

# Gemパスの設定
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"
echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc

# Bundlerのインストール
gem install bundler jekyll
echo "✓ Ruby環境セットアップ完了"

echo ""
echo "[6/9] Jekyll依存関係のインストール"
bundle install
echo "✓ 依存関係インストール完了"

echo ""
echo "[7/9] Jekyllサイトのビルド"
bundle exec jekyll build
echo "✓ ビルド完了: _site/"

echo ""
echo "[8/9] Nginx設定の更新"
sudo tee /etc/nginx/sites-available/default > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name sy-ryosuke.site www.sy-ryosuke.site;
    
    # HTTPからHTTPSへリダイレクト
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

    # SSL証明書（Certbotが自動で追加します）
    ssl_certificate /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sy-ryosuke.site/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # ドキュメントルート（Jekyllのビルド結果）
    root /var/www/photography-site/_site;
    index index.html;

    # セキュリティヘッダー
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # ログ設定
    access_log /var/log/nginx/portfolio_access.log;
    error_log /var/log/nginx/portfolio_error.log;

    location / {
        try_files $uri $uri/ =404;
    }

    # 静的ファイルのキャッシュ
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 隠しファイルへのアクセス拒否
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

echo "✓ Nginx設定更新完了"

echo ""
echo "[9/9] Nginxの設定をテストして再起動"
sudo nginx -t
sudo systemctl reload nginx
echo "✓ Nginx再起動完了"

echo ""
echo "============================================"
echo "✓ 切り替え完了！"
echo "============================================"
echo ""
echo "サイトURL: https://sy-ryosuke.site"
echo ""
echo "次のステップ:"
echo "1. リポジトリの _config.yml を編集して、あなたの情報に更新してください"
echo "2. images/fulls/ に写真を追加してください"
echo "3. images/thumbs/ にサムネイルを追加してください"
echo "4. 変更後は 'bundle exec jekyll build' でビルドしてください"
echo ""
echo "バックアップ場所: /var/www/portfolio-site-backup"
echo "============================================"

