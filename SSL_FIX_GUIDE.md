# SSL導入後の403エラー修正ガイド

## 問題の概要

SSL証明書を導入した後、サイトが403 Forbiddenエラーを表示しています。
これはCertbotがNginxの設定を自動的に変更した際に、プロキシ設定が失われたか、
不適切に設定された可能性があります。

## 診断手順

### 1. サーバーにSSH接続

```bash
ssh portfolio-admin@your-server-ip
```

### 2. PM2のステータス確認

Next.jsアプリが正常に起動しているか確認：

```bash
pm2 status
pm2 logs portfolio --lines 50
```

**期待される結果**: `portfolio`が`online`状態であること

### 3. Nginx設定ファイルの確認

Certbotによってどのように変更されたかを確認：

```bash
sudo cat /etc/nginx/sites-available/portfolio
```

### 4. Nginxエラーログの確認

```bash
sudo tail -n 100 /var/log/nginx/error.log
```

## 修正方法

### 方法1: Nginx設定ファイルの修正（推奨）

#### ステップ1: バックアップ作成

```bash
sudo cp /etc/nginx/sites-available/portfolio /etc/nginx/sites-available/portfolio.backup
```

#### ステップ2: 設定ファイルを編集

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

#### ステップ3: 正しい設定に置き換え

以下の内容に置き換えてください（ドメイン名を適宜変更）：

```nginx
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

    # SSL証明書の設定（Certbotが自動的に設定）
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
```

#### ステップ4: 設定ファイルのテスト

```bash
sudo nginx -t
```

**期待される結果**: `test is successful` と表示される

#### ステップ5: Nginxを再起動

```bash
sudo systemctl restart nginx
```

#### ステップ6: 動作確認

```bash
# ローカルでNext.jsアプリが応答するか確認
curl http://localhost:3000

# HTTPSで正しくプロキシされるか確認
curl -I https://sy-ryosuke.site
```

### 方法2: SSL証明書パスの確認

証明書のパスが間違っている場合：

```bash
# 証明書ファイルの存在確認
sudo ls -la /etc/letsencrypt/live/sy-ryosuke.site/

# 証明書の有効性確認
sudo openssl x509 -in /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem -noout -dates
```

### 方法3: PM2アプリケーションの再起動

アプリケーションが停止している場合：

```bash
# 現在のステータス確認
pm2 status

# 停止している場合は再起動
pm2 restart portfolio

# それでもダメなら完全に再起動
pm2 delete portfolio
cd /var/www/portfolio-site
pm2 start npm --name "portfolio" -- start
pm2 save
```

### 方法4: ポート3000の確認

他のプロセスがポート3000を使用している可能性：

```bash
# ポート3000を使用しているプロセスを確認
sudo lsof -i :3000

# Next.jsアプリケーション以外のプロセスがあれば終了
sudo kill -9 <PID>

# PM2を再起動
pm2 restart portfolio
```

## トラブルシューティング

### 問題: Nginxが起動しない

```bash
# 詳細なエラーログを確認
sudo journalctl -u nginx -n 50

# 構文エラーの確認
sudo nginx -t
```

### 問題: SSL証明書が見つからない

```bash
# Certbotで証明書を再取得
sudo certbot --nginx -d sy-ryosuke.site -d www.sy-ryosuke.site --force-renewal
```

### 問題: 502 Bad Gateway エラーが出る

これはNext.jsアプリが起動していないことを意味します：

```bash
pm2 logs portfolio
pm2 restart portfolio
```

### 問題: 依然として403エラーが出る

ファイルパーミッションの問題の可能性：

```bash
# プロジェクトディレクトリの所有者確認
ls -la /var/www/portfolio-site

# 必要に応じて所有者を変更
sudo chown -R $USER:$USER /var/www/portfolio-site

# 再ビルド
cd /var/www/portfolio-site
npm run build
pm2 restart portfolio
```

## 最終確認チェックリスト

- [ ] `pm2 status` でアプリが `online` になっている
- [ ] `curl http://localhost:3000` でHTMLが返ってくる
- [ ] `sudo nginx -t` でエラーがない
- [ ] `sudo systemctl status nginx` でNginxが起動している
- [ ] SSL証明書が `/etc/letsencrypt/live/sy-ryosuke.site/` に存在する
- [ ] Nginx設定にプロキシ設定（`proxy_pass http://localhost:3000`）がある
- [ ] ブラウザで `https://sy-ryosuke.site` にアクセスできる

## 緊急対応: HTTP接続に戻す

どうしても解決しない場合は、一時的にHTTPS接続を無効化：

```bash
# SSL設定を無効化
sudo nano /etc/nginx/sites-available/portfolio
```

以下の最小限の設定に戻す：

```nginx
server {
    listen 80;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

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
    }
}
```

```bash
sudo nginx -t
sudo systemctl restart nginx
```

## 参考コマンド集

```bash
# Nginxログのリアルタイム監視
sudo tail -f /var/log/nginx/error.log

# PM2ログのリアルタイム監視
pm2 logs portfolio

# システム全体のリソース確認
htop

# ディスク容量確認
df -h

# メモリ使用量確認
free -m
```

## 次のステップ

1. 上記の手順を実行
2. 問題が解決したら、ブラウザで `https://sy-ryosuke.site` にアクセス
3. 正常に表示されることを確認
4. SSL証明書の有効期限を確認（自動更新設定も確認）

```bash
# 証明書の有効期限確認
sudo certbot certificates

# 自動更新のテスト
sudo certbot renew --dry-run
```

