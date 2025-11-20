# 403エラー クイック修正ガイド

## 🚨 問題

SSL証明書を導入した後、`https://sy-ryosuke.site` にアクセスすると **403 Forbidden** エラーが表示される。

## 🔍 原因

Certbotが自動的にNginx設定を変更した際に、**Next.jsアプリへのプロキシ設定が失われた**可能性が高いです。

## ⚡ 最速の解決方法（5分で完了）

### ステップ1: サーバーにSSH接続

```bash
ssh portfolio-admin@your-server-ip
```

### ステップ2: 診断スクリプトをダウンロード

```bash
cd /var/www/portfolio-site
git pull origin main
```

ローカルから直接アップロードする場合：

```bash
# ローカルマシンで実行
cd /Users/ryo1280/cursor/portfolio-site
scp diagnose.sh fix-ssl-403.sh portfolio-admin@your-server-ip:/home/portfolio-admin/
```

### ステップ3: スクリプトに実行権限を付与

```bash
# サーバー上で実行
chmod +x ~/diagnose.sh
chmod +x ~/fix-ssl-403.sh
```

### ステップ4: 診断を実行（任意）

```bash
./diagnose.sh
```

このコマンドで、問題の詳細を確認できます。

### ステップ5: 自動修正スクリプトを実行

```bash
./fix-ssl-403.sh
```

このスクリプトが以下を自動的に実行します：
1. ✅ PM2とNext.jsアプリの動作確認
2. ✅ 現在の設定をバックアップ
3. ✅ 正しいNginx設定を適用
4. ✅ Nginxを再起動
5. ✅ HTTPSアクセスのテスト

### ステップ6: ブラウザで確認

https://sy-ryosuke.site にアクセスして、サイトが正常に表示されることを確認。

---

## 🛠 手動での修正方法

自動スクリプトが使えない場合は、以下の手順で手動修正してください。

### 1. バックアップを作成

```bash
sudo cp /etc/nginx/sites-available/portfolio /etc/nginx/sites-available/portfolio.backup
```

### 2. Nginx設定ファイルを編集

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

### 3. 以下の内容に置き換え

```nginx
# HTTPからHTTPSへのリダイレクト
server {
    listen 80;
    listen [::]:80;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS設定
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name sy-ryosuke.site www.sy-ryosuke.site;

    # SSL証明書
    ssl_certificate /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sy-ryosuke.site/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Next.jsへのプロキシ（ここが重要！）
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

### 4. 保存して終了

- `Ctrl + O` → Enter（保存）
- `Ctrl + X`（終了）

### 5. 設定をテスト

```bash
sudo nginx -t
```

「test is successful」と表示されればOK。

### 6. Nginxを再起動

```bash
sudo systemctl restart nginx
```

### 7. 動作確認

```bash
curl -I https://sy-ryosuke.site
```

ステータスコード200が返ってくればOK。

---

## 🔧 追加のトラブルシューティング

### 問題: 502 Bad Gateway エラーが出る

Next.jsアプリが起動していない可能性があります。

```bash
# PM2のステータス確認
pm2 status

# アプリを再起動
pm2 restart portfolio

# それでもダメなら
pm2 delete portfolio
cd /var/www/portfolio-site
pm2 start npm --name "portfolio" -- start
pm2 save
```

### 問題: ポート3000が使えない

```bash
# ポートを使用しているプロセスを確認
sudo lsof -i :3000

# 不要なプロセスを終了
sudo kill -9 <PID>

# PM2を再起動
pm2 restart portfolio
```

### 問題: SSL証明書が見つからない

```bash
# 証明書の再取得
sudo certbot --nginx -d sy-ryosuke.site -d www.sy-ryosuke.site
```

---

## 📊 確認コマンド集

```bash
# Nginxの状態
sudo systemctl status nginx

# Nginxのエラーログ
sudo tail -f /var/log/nginx/error.log

# PM2の状態
pm2 status
pm2 logs portfolio

# Next.jsアプリの動作確認
curl http://localhost:3000

# HTTPS接続の確認
curl -I https://sy-ryosuke.site
```

---

## ✅ 修正完了後のチェックリスト

- [ ] `pm2 status` でアプリが `online` になっている
- [ ] `curl http://localhost:3000` でHTMLが返ってくる
- [ ] `sudo nginx -t` でエラーがない
- [ ] `curl -I https://sy-ryosuke.site` でステータス200が返る
- [ ] ブラウザで `https://sy-ryosuke.site` にアクセスできる
- [ ] SSL証明書の鍵マークが表示される

---

## 📞 サポート

問題が解決しない場合は、以下の情報を収集してください：

```bash
# 診断情報の収集
./diagnose.sh > diagnostic-report.txt

# または手動で
pm2 logs portfolio > pm2-logs.txt
sudo cat /var/log/nginx/error.log > nginx-error.txt
sudo nginx -t > nginx-test.txt 2>&1
```

これらのファイルを確認して、エラーメッセージを特定してください。

