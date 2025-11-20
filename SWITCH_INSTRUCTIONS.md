# Jekyllポートフォリオサイトへの切り替え手順

## 実行コマンド

ターミナルで以下のコマンドを実行してください：

```bash
ssh portfolio-admin@133.18.115.106
```

ログイン後、以下を実行：

```bash
chmod +x ~/switch-to-jekyll.sh
bash ~/switch-to-jekyll.sh
```

パスワードを求められたら、サーバーのsudoパスワードを入力してください。

## 切り替え後の設定

スクリプト完了後、以下の設定をカスタマイズしてください：

### 1. 基本情報の更新

```bash
cd /var/www/photography-site
nano _config.yml
```

以下の項目を編集：
- `title`: サイトのタイトル
- `description`: サイトの説明
- `baseurl`: ""（空のまま）
- `url`: "https://sy-ryosuke.site"
- ソーシャルメディアリンク
- Google Analyticsの設定

### 2. 写真のアップロード

```bash
# ローカルマシンから写真をアップロード（例）
scp your-photo.jpg portfolio-admin@133.18.115.106:/tmp/

# サーバー上で移動
ssh portfolio-admin@133.18.115.106
sudo cp /tmp/your-photo.jpg /var/www/photography-site/images/fulls/
```

または、サーバー上で直接作業：

```bash
cd /var/www/photography-site/images/fulls/
# ここに写真をアップロード
```

### 3. サムネイルの生成

このリポジトリには自動サムネイル生成機能があります：

```bash
cd /var/www/photography-site
npm install
gulp resize
```

または手動でサムネイルを作成して `images/thumbs/` に配置。

### 4. サイトの再ビルド

写真を追加したら必ずビルド：

```bash
cd /var/www/photography-site
bundle exec jekyll build
```

### 5. 確認

ブラウザで https://sy-ryosuke.site にアクセスして確認してください。

## トラブルシューティング

### エラーが発生した場合

```bash
# Nginxログの確認
sudo tail -f /var/log/nginx/portfolio_error.log

# Jekyllビルドエラーの確認
cd /var/www/photography-site
bundle exec jekyll build --verbose
```

### バックアップから復元

問題が発生した場合は、バックアップから元に戻せます：

```bash
cd /var/www
sudo rm -rf photography-site
sudo cp -r portfolio-site-backup portfolio-site

# Nginxとアプリケーションを再起動
cd /var/www/portfolio-site
pm2 start npm --name portfolio -- start
sudo systemctl reload nginx
```

## 参考リンク

- [元のリポジトリ](https://github.com/rampatra/photography)
- [Jekyll公式ドキュメント](https://jekyllrb.com/)
- [デモサイト](https://photography.rampatra.com/)


