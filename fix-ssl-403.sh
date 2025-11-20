#!/bin/bash

# SSL導入後の403エラー修正スクリプト
# 使用方法: chmod +x fix-ssl-403.sh && ./fix-ssl-403.sh

set -e

echo "============================================"
echo "SSL導入後の403エラー修正スクリプト"
echo "============================================"
echo ""

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ドメイン名（必要に応じて変更）
DOMAIN="sy-ryosuke.site"
WWW_DOMAIN="www.sy-ryosuke.site"

echo -e "${YELLOW}[1/8] PM2ステータスの確認${NC}"
pm2 status

echo ""
echo -e "${YELLOW}[2/8] Next.jsアプリケーションの動作確認${NC}"
if curl -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✓ Next.jsアプリケーションは正常に動作しています${NC}"
else
    echo -e "${RED}✗ Next.jsアプリケーションが応答しません${NC}"
    echo "PM2を再起動します..."
    pm2 restart portfolio || pm2 start npm --name "portfolio" -- start
    pm2 save
    sleep 3
fi

echo ""
echo -e "${YELLOW}[3/8] 現在のNginx設定のバックアップ${NC}"
sudo cp /etc/nginx/sites-available/portfolio /etc/nginx/sites-available/portfolio.backup.$(date +%Y%m%d_%H%M%S)
echo -e "${GREEN}✓ バックアップ完了${NC}"

echo ""
echo -e "${YELLOW}[4/8] SSL証明書の存在確認${NC}"
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo -e "${GREEN}✓ SSL証明書が見つかりました${NC}"
    SSL_CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
    SSL_KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"
else
    echo -e "${RED}✗ SSL証明書が見つかりません${NC}"
    echo "手動でCertbotを実行してください: sudo certbot --nginx -d $DOMAIN -d $WWW_DOMAIN"
    exit 1
fi

echo ""
echo -e "${YELLOW}[5/8] Nginx設定ファイルの作成${NC}"

# 一時ファイルに新しい設定を書き込む
cat > /tmp/portfolio-nginx-config << 'EOF'
# HTTPからHTTPSへのリダイレクト
server {
    listen 80;
    listen [::]:80;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

    # Let's Encrypt用のacme-challenge
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # その他すべてのリクエストをHTTPSにリダイレクト
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS設定
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

    # SSL証明書の設定
    ssl_certificate /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sy-ryosuke.site/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Next.jsアプリケーションへのプロキシ設定
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # タイムアウト設定
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 静的ファイルのキャッシュ設定
    location /_next/static {
        proxy_cache_valid 60m;
        proxy_pass http://localhost:3000;
    }

    # セキュリティヘッダー
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# 設定ファイルを配置
sudo cp /tmp/portfolio-nginx-config /etc/nginx/sites-available/portfolio
echo -e "${GREEN}✓ Nginx設定ファイルを更新しました${NC}"

echo ""
echo -e "${YELLOW}[6/8] Nginx設定のテスト${NC}"
if sudo nginx -t; then
    echo -e "${GREEN}✓ Nginx設定は正常です${NC}"
else
    echo -e "${RED}✗ Nginx設定にエラーがあります${NC}"
    echo "バックアップから復元します..."
    sudo cp /etc/nginx/sites-available/portfolio.backup.$(date +%Y%m%d)* /etc/nginx/sites-available/portfolio
    exit 1
fi

echo ""
echo -e "${YELLOW}[7/8] Nginxの再起動${NC}"
sudo systemctl restart nginx
echo -e "${GREEN}✓ Nginxを再起動しました${NC}"

echo ""
echo -e "${YELLOW}[8/8] 動作確認${NC}"

# HTTPリダイレクトの確認
echo "HTTP → HTTPSリダイレクトの確認..."
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN)
if [ "$HTTP_RESPONSE" = "301" ] || [ "$HTTP_RESPONSE" = "302" ]; then
    echo -e "${GREEN}✓ HTTPリダイレクトは正常です (Status: $HTTP_RESPONSE)${NC}"
else
    echo -e "${YELLOW}⚠ HTTPリダイレクトの応答: $HTTP_RESPONSE${NC}"
fi

# HTTPS接続の確認
echo "HTTPS接続の確認..."
HTTPS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
if [ "$HTTPS_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ HTTPSアクセスは正常です (Status: $HTTPS_RESPONSE)${NC}"
else
    echo -e "${RED}✗ HTTPSアクセスに問題があります (Status: $HTTPS_RESPONSE)${NC}"
    echo "詳細を確認します..."
    curl -I https://$DOMAIN
fi

echo ""
echo "============================================"
echo -e "${GREEN}修正完了！${NC}"
echo "============================================"
echo ""
echo "ブラウザで以下のURLにアクセスして確認してください："
echo "https://$DOMAIN"
echo ""
echo "問題が解決しない場合は、以下のコマンドでログを確認してください："
echo "  sudo tail -f /var/log/nginx/error.log"
echo "  pm2 logs portfolio"
echo ""

