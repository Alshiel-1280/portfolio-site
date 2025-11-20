#!/bin/bash

# サイト診断スクリプト
# 使用方法: chmod +x diagnose.sh && ./diagnose.sh

echo "============================================"
echo "ポートフォリオサイト診断スクリプト"
echo "============================================"
echo ""

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOMAIN="sy-ryosuke.site"

# ヘルパー関数
print_section() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_fail() {
    echo -e "${RED}✗ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# 1. PM2ステータス
print_section "1. PM2アプリケーション ステータス"
pm2 status

# 2. Next.jsアプリケーションの確認
print_section "2. Next.jsアプリケーション（localhost:3000）"
if curl -s http://localhost:3000 > /dev/null; then
    print_pass "Next.jsアプリケーションは正常に動作しています"
    echo "レスポンスヘッダー:"
    curl -sI http://localhost:3000 | head -5
else
    print_fail "Next.jsアプリケーションが応答しません"
fi

# 3. ポート確認
print_section "3. ポート3000の使用状況"
sudo lsof -i :3000 || echo "ポート3000を使用しているプロセスはありません"

# 4. Nginxステータス
print_section "4. Nginx サービス ステータス"
sudo systemctl status nginx --no-pager | head -10

# 5. Nginx設定ファイル
print_section "5. Nginx設定ファイル"
echo "設定ファイルパス: /etc/nginx/sites-available/portfolio"
echo ""
echo "設定内容:"
sudo cat /etc/nginx/sites-available/portfolio

# 6. Nginx設定テスト
print_section "6. Nginx設定の文法チェック"
if sudo nginx -t 2>&1; then
    print_pass "Nginx設定は正常です"
else
    print_fail "Nginx設定にエラーがあります"
fi

# 7. SSL証明書の確認
print_section "7. SSL証明書"
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    print_pass "SSL証明書が見つかりました"
    echo ""
    echo "証明書の詳細:"
    sudo openssl x509 -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem -noout -dates
    echo ""
    echo "すべての証明書:"
    sudo certbot certificates
else
    print_fail "SSL証明書が見つかりません"
fi

# 8. ファイアウォール設定
print_section "8. ファイアウォール設定"
sudo ufw status

# 9. Nginxエラーログ（最新20行）
print_section "9. Nginx エラーログ（最新20行）"
sudo tail -20 /var/log/nginx/error.log

# 10. Nginxアクセスログ（最新10行）
print_section "10. Nginx アクセスログ（最新10行）"
sudo tail -10 /var/log/nginx/access.log

# 11. PM2ログ
print_section "11. PM2ログ（最新20行）"
pm2 logs portfolio --lines 20 --nostream

# 12. HTTP接続テスト
print_section "12. HTTP接続テスト"
echo "HTTPリクエスト (http://$DOMAIN):"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN)
echo "ステータスコード: $HTTP_CODE"
if [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
    print_pass "HTTPからHTTPSへ正しくリダイレクトされています"
elif [ "$HTTP_CODE" = "200" ]; then
    print_warn "HTTPで直接アクセスできています（HTTPSリダイレクトが設定されていない可能性）"
else
    print_fail "予期しないステータスコード: $HTTP_CODE"
fi

# 13. HTTPS接続テスト
print_section "13. HTTPS接続テスト"
echo "HTTPSリクエスト (https://$DOMAIN):"
HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
echo "ステータスコード: $HTTPS_CODE"
if [ "$HTTPS_CODE" = "200" ]; then
    print_pass "HTTPSアクセスは正常です"
    echo ""
    echo "レスポンスヘッダー:"
    curl -sI https://$DOMAIN | head -10
elif [ "$HTTPS_CODE" = "403" ]; then
    print_fail "403 Forbiddenエラーが発生しています"
elif [ "$HTTPS_CODE" = "502" ]; then
    print_fail "502 Bad Gatewayエラー（Next.jsアプリが起動していない可能性）"
else
    print_fail "予期しないステータスコード: $HTTPS_CODE"
fi

# 14. SSL証明書の検証
print_section "14. SSL証明書の検証"
echo "SSL証明書の詳細を取得中..."
echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates

# 15. ディスク容量
print_section "15. ディスク容量"
df -h | grep -E '^Filesystem|/$'

# 16. メモリ使用量
print_section "16. メモリ使用量"
free -m

# 17. プロジェクトディレクトリの確認
print_section "17. プロジェクトディレクトリ"
echo "パス: /var/www/portfolio-site"
ls -la /var/www/portfolio-site | head -20

# 18. 環境変数ファイルの確認
print_section "18. 環境変数ファイル"
if [ -f "/var/www/portfolio-site/.env.production" ]; then
    print_pass ".env.productionファイルが存在します"
    echo "変数名のみ表示（値は非表示）:"
    grep -o '^[^=]*' /var/www/portfolio-site/.env.production || echo "ファイルが空です"
else
    print_warn ".env.productionファイルが見つかりません"
fi

# まとめ
print_section "診断結果サマリー"

echo ""
echo -e "${YELLOW}主要な確認ポイント:${NC}"
echo ""

# PM2チェック
if pm2 status | grep -q "online"; then
    print_pass "PM2: アプリケーションは起動しています"
else
    print_fail "PM2: アプリケーションが停止しています"
fi

# Next.jsチェック
if curl -s http://localhost:3000 > /dev/null; then
    print_pass "Next.js: ローカルで正常に動作しています"
else
    print_fail "Next.js: ローカルで応答がありません"
fi

# Nginxチェック
if sudo nginx -t 2>&1 > /dev/null; then
    print_pass "Nginx: 設定ファイルは正常です"
else
    print_fail "Nginx: 設定ファイルにエラーがあります"
fi

# SSL証明書チェック
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    print_pass "SSL: 証明書が存在します"
else
    print_fail "SSL: 証明書が見つかりません"
fi

# HTTPSアクセスチェック
FINAL_HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
if [ "$FINAL_HTTPS_CODE" = "200" ]; then
    print_pass "HTTPS: サイトは正常にアクセスできます ($FINAL_HTTPS_CODE)"
elif [ "$FINAL_HTTPS_CODE" = "403" ]; then
    print_fail "HTTPS: 403 Forbiddenエラーが発生しています"
    echo ""
    echo -e "${YELLOW}推奨される対処法:${NC}"
    echo "  1. fix-ssl-403.shスクリプトを実行してNginx設定を修正"
    echo "  2. PM2を再起動: pm2 restart portfolio"
    echo "  3. Nginxログを確認: sudo tail -f /var/log/nginx/error.log"
elif [ "$FINAL_HTTPS_CODE" = "502" ]; then
    print_fail "HTTPS: 502 Bad Gatewayエラー"
    echo ""
    echo -e "${YELLOW}推奨される対処法:${NC}"
    echo "  1. PM2を再起動: pm2 restart portfolio"
    echo "  2. ポート3000を確認: sudo lsof -i :3000"
else
    print_fail "HTTPS: エラー ($FINAL_HTTPS_CODE)"
fi

echo ""
echo "============================================"
echo -e "${GREEN}診断完了${NC}"
echo "============================================"
echo ""

