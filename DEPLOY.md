# デプロイガイド

VPSサーバーへのデプロイ手順を説明します。

## 前提条件

- VPSサーバー（Ubuntu 22.04 LTS）が準備済み
- Node.js、npm、PM2、Nginx、Gitがインストール済み
- ドメインを取得済み（任意）
- microCMSの設定が完了済み

## 1. GitHubにプッシュ

### 1-1. Gitリポジトリの初期化（まだの場合）

```bash
cd /Users/ryo1280/cursor/portfolio-site
git init
git add .
git commit -m "Initial commit: Portfolio site setup"
```

### 1-2. GitHubリポジトリの作成

1. [GitHub](https://github.com/)にログイン
2. 「New repository」をクリック
3. リポジトリ名を入力（例: `portfolio-site`）
4. Public または Private を選択
5. 「Create repository」をクリック

### 1-3. リモートリポジトリを追加してプッシュ

```bash
git remote add origin https://github.com/your-username/portfolio-site.git
git branch -M main
git push -u origin main
```

## 2. VPSサーバーでの作業

### 2-1. サーバーにSSH接続

```bash
ssh portfolio-admin@your-server-ip
```

### 2-2. プロジェクトディレクトリの作成

```bash
sudo mkdir -p /var/www
sudo chown $USER:$USER /var/www
cd /var/www
```

### 2-3. リポジトリのクローン

```bash
git clone https://github.com/your-username/portfolio-site.git
cd portfolio-site
```

### 2-4. 依存パッケージのインストール

```bash
npm install
```

### 2-5. 環境変数の設定

本番環境用の環境変数ファイルを作成：

```bash
nano .env.production
```

以下を記載して保存（Ctrl+O、Enter、Ctrl+X）：

```env
MICROCMS_SERVICE_DOMAIN=your-service-id
MICROCMS_API_KEY=your-api-key
```

### 2-6. ビルド

```bash
npm run build
```

### 2-7. PM2でアプリケーションを起動

```bash
pm2 start npm --name "portfolio" -- start
pm2 save
pm2 startup
```

`pm2 startup`で表示されたコマンドを実行してください。

### 2-8. 動作確認

```bash
curl http://localhost:3000
```

HTMLが返ってくればOKです。

## 3. Nginxの設定

### 3-1. 設定ファイルの作成

```bash
sudo nano /etc/nginx/sites-available/portfolio
```

以下の内容を貼り付け（ドメイン名を置き換える）：

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

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

ドメインがない場合は、`server_name`をサーバーのIPアドレスに変更：

```nginx
server_name 123.456.789.0;
```

### 3-2. 設定を有効化

```bash
sudo ln -s /etc/nginx/sites-available/portfolio /etc/nginx/sites-enabled/
```

### 3-3. 設定ファイルのテスト

```bash
sudo nginx -t
```

「test is successful」と表示されればOK。

### 3-4. Nginxを再起動

```bash
sudo systemctl restart nginx
```

### 3-5. 動作確認

ブラウザで `http://your-domain.com`（またはIPアドレス）にアクセスして、サイトが表示されることを確認。

## 4. HTTPS化（SSL証明書の導入）

ドメインを使用している場合のみ実施します。

### 4-1. Certbotのインストール

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
```

### 4-2. SSL証明書の取得

```bash
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

メールアドレスを入力し、利用規約に同意します。

### 4-3. 自動更新の確認

```bash
sudo certbot renew --dry-run
```

エラーがなければ、証明書の自動更新が正しく設定されています。

### 4-4. 動作確認

ブラウザで `https://your-domain.com` にアクセスして、鍵マークが表示されることを確認。

## 5. 更新作業（コードを変更した場合）

### 5-1. ローカルでの作業

```bash
# 変更をコミット
git add .
git commit -m "Update: Description of changes"
git push origin main
```

### 5-2. サーバーでの作業

```bash
# サーバーにSSH接続
ssh portfolio-admin@your-server-ip

# プロジェクトディレクトリに移動
cd /var/www/portfolio-site

# 最新のコードを取得
git pull origin main

# 依存パッケージを更新（package.jsonが変更された場合）
npm install

# ビルド
npm run build

# PM2でアプリケーションを再起動
pm2 restart portfolio
```

## 6. トラブルシューティング

### サイトが表示されない

```bash
# PM2のステータス確認
pm2 status

# ログを確認
pm2 logs portfolio

# Nginxのステータス確認
sudo systemctl status nginx

# Nginxのエラーログ確認
sudo tail -f /var/log/nginx/error.log
```

### PM2が起動しない

```bash
# PM2を停止して再起動
pm2 delete portfolio
pm2 start npm --name "portfolio" -- start
pm2 save
```

### 環境変数が読み込まれない

```bash
# .env.productionファイルの確認
cat /var/www/portfolio-site/.env.production

# 内容が正しくない場合は編集
nano /var/www/portfolio-site/.env.production

# 保存後、アプリを再起動
pm2 restart portfolio
```

### ポート3000が既に使用されている

```bash
# ポートを使用しているプロセスを確認
sudo lsof -i :3000

# プロセスを終了（PIDを確認後）
kill -9 PID
```

## 7. 便利なコマンド

```bash
# PM2のステータス確認
pm2 status

# ログをリアルタイムで表示
pm2 logs portfolio

# CPU・メモリ使用率の確認
pm2 monit

# アプリの再起動
pm2 restart portfolio

# アプリの停止
pm2 stop portfolio

# アプリの削除（PM2から削除）
pm2 delete portfolio

# Nginxの設定テスト
sudo nginx -t

# Nginxの再起動
sudo systemctl restart nginx

# Nginxのログ確認
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## 8. セキュリティ対策

### 8-1. ファイアウォールの確認

```bash
sudo ufw status
```

HTTP（80）、HTTPS（443）、SSH（22）が許可されていることを確認。

### 8-2. 定期的なアップデート

```bash
# システムの更新
sudo apt update
sudo apt upgrade -y

# Node.jsパッケージの更新
cd /var/www/portfolio-site
npm update
npm audit fix
```

### 8-3. バックアップ

定期的にデータベースやコードのバックアップを取ることをお勧めします。

```bash
# プロジェクトのバックアップ
tar -czf portfolio-backup-$(date +%Y%m%d).tar.gz /var/www/portfolio-site
```

## 9. パフォーマンス最適化

### 9-1. Nginx でのgzip圧縮

`/etc/nginx/nginx.conf` に以下を追加：

```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;
```

### 9-2. キャッシュの設定

Nginx設定に静的ファイルのキャッシュを追加：

```nginx
location /_next/static {
    proxy_cache_valid 60m;
    proxy_pass http://localhost:3000;
}
```

## 10. モニタリング

### 10-1. PM2 Plus（有料）

より詳細なモニタリングが必要な場合は、PM2 Plusの利用を検討してください。

- [PM2 Plus](https://pm2.io/)

### 10-2. ログの定期的な確認

```bash
# PM2のログローテーション設定
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

## まとめ

これで、VPSサーバーへのデプロイが完了しました！

定期的にコードを更新し、セキュリティアップデートを適用することで、安全かつ安定したサイト運用が可能です。

問題が発生した場合は、ログを確認してトラブルシューティングを行ってください。

