#!/bin/bash

echo "============================================"
echo "Jekyll環境構築（sudo権限必要な操作）"
echo "============================================"

set -e

echo ""
echo "[1/6] 既存ディレクトリのバックアップ"
cd /var/www
if [ -d "portfolio-site-backup" ]; then
    rm -rf portfolio-site-backup
fi
cp -r portfolio-site portfolio-site-backup
echo "✓ バックアップ完了"

echo ""
echo "[2/6] 既存ディレクトリの削除"
rm -rf /var/www/portfolio-site
echo "✓ 削除完了"

echo ""
echo "[3/6] 新しいリポジトリのクローン"
cd /var/www
git clone https://github.com/rampatra/photography.git photography-site
chown -R portfolio-admin:portfolio-admin photography-site
echo "✓ クローン完了"

echo ""
echo "[4/6] Rubyとビルドツールのインストール"
apt-get update
apt-get install -y ruby-full build-essential zlib1g-dev
echo "✓ インストール完了"

echo ""
echo "[5/6] Nginx設定の更新"
tee /etc/nginx/sites-available/default > /dev/null <<'NGINX_CONFIG'
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

    # SSL証明書
    ssl_certificate /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sy-ryosuke.site/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # ドキュメントルート
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
        try_files \$uri \$uri/ =404;
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
NGINX_CONFIG
echo "✓ Nginx設定更新完了"

echo ""
echo "[6/6] Nginxの設定テストと再起動"
nginx -t
systemctl reload nginx
echo "✓ Nginx再起動完了"

echo ""
echo "============================================"
echo "✓ sudo権限が必要な操作が完了しました"
echo "============================================"


