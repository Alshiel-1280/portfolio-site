# SSL導入後の403エラー - 問題解決サマリー

## 📊 診断結果

### 現在の状態
- **サイトURL**: https://sy-ryosuke.site/
- **エラーコード**: 403 Forbidden
- **Webサーバー**: nginx/1.18.0 (Ubuntu)

### 問題の原因

SSL証明書を導入するために実行した `sudo certbot --nginx` コマンドが、Nginx設定ファイルを自動的に変更しました。

その際、**Next.jsアプリケーションへのプロキシ設定が失われたか、不適切に設定された**ため、NginxがNext.jsアプリにリクエストを転送できず、403エラーを返しています。

### 技術的な詳細

#### 期待される動作
1. ユーザーがHTTPSでアクセス
2. NginxがSSL/TLS接続を処理
3. Nginxが `localhost:3000` で動作しているNext.jsアプリにリクエストをプロキシ
4. Next.jsが応答を返す
5. Nginxがユーザーに応答を返す

#### 現在の動作（推測）
1. ユーザーがHTTPSでアクセス
2. NginxがSSL/TLS接続を処理
3. **プロキシ設定が失われているため、Nginxが直接レスポンスを返そうとする**
4. **提供すべき静的コンテンツが存在しないため、403 Forbiddenを返す**

---

## 🔧 解決方法

以下の3つの方法から選択できます。

### 方法1: 自動修正スクリプト（最速・推奨）⚡

**所要時間**: 5分

```bash
# ローカルマシンで
cd /Users/ryo1280/cursor/portfolio-site
scp fix-ssl-403.sh portfolio-admin@サーバーIP:/home/portfolio-admin/

# サーバーで
ssh portfolio-admin@サーバーIP
chmod +x ~/fix-ssl-403.sh
./fix-ssl-403.sh
```

### 方法2: 手動修正（詳細な理解が必要な場合）

**所要時間**: 15分

詳細は [実行手順.md](./実行手順.md) を参照。

### 方法3: Gitからプルして修正

**所要時間**: 10分

```bash
# まずローカルで変更をプッシュ
cd /Users/ryo1280/cursor/portfolio-site
git add .
git commit -m "Add SSL fix scripts and documentation"
git push origin main

# サーバーで
ssh portfolio-admin@サーバーIP
cd /var/www/portfolio-site
git pull origin main
chmod +x fix-ssl-403.sh
./fix-ssl-403.sh
```

---

## 📁 作成されたファイル

本問題の解決のために、以下のファイルを作成しました：

### 1. 実行スクリプト

| ファイル | 説明 |
|---------|------|
| `fix-ssl-403.sh` | SSL導入後の403エラーを自動修正するスクリプト |
| `diagnose.sh` | サーバーの状態を総合的に診断するスクリプト |

### 2. ドキュメント

| ファイル | 説明 |
|---------|------|
| `実行手順.md` | 今すぐ実行すべき手順（最も重要） |
| `QUICK_FIX.md` | クイック修正ガイド（5分で解決） |
| `SSL_FIX_GUIDE.md` | 詳細なトラブルシューティングガイド |
| `SSL_403_ERROR_SUMMARY.md` | このファイル（問題の全体像） |

### 3. 更新されたドキュメント

| ファイル | 変更内容 |
|---------|----------|
| `DEPLOY.md` | SSL導入時の注意事項を追加 |
| `README.md` | SSL問題のリンクを追加 |

---

## 🎯 正しいNginx設定

修正後のNginx設定は以下のようになります：

### 重要なポイント

```nginx
# HTTPS設定ブロック内
server {
    listen 443 ssl http2;
    server_name sy-ryosuke.site www.sy-ryosuke.site;
    
    # SSL証明書の設定
    ssl_certificate /etc/letsencrypt/live/sy-ryosuke.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sy-ryosuke.site/privkey.pem;
    
    # ★最重要★ Next.jsへのプロキシ設定
    location / {
        proxy_pass http://localhost:3000;  # ← これが失われている
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

**`proxy_pass http://localhost:3000;` が最も重要な設定です。**

---

## ✅ 修正完了後の確認項目

### サーバー側での確認

```bash
# 1. PM2でアプリが動作中
pm2 status
# 期待: portfolio が online

# 2. Next.jsがlocalhostで応答
curl http://localhost:3000
# 期待: HTMLが返る

# 3. Nginx設定が正常
sudo nginx -t
# 期待: test is successful

# 4. HTTPSでアクセス可能
curl -I https://sy-ryosuke.site
# 期待: HTTP/2 200
```

### ブラウザでの確認

- [ ] https://sy-ryosuke.site にアクセスできる
- [ ] 写真一覧ページが表示される
- [ ] SSL証明書の鍵マークが表示される
- [ ] コンソールにエラーがない

---

## 🔄 今後の予防策

### SSL証明書を更新する際

Certbotを実行する前に、**必ず設定をバックアップ**してください：

```bash
sudo cp /etc/nginx/sites-available/portfolio /etc/nginx/sites-available/portfolio.backup.$(date +%Y%m%d)
```

### SSL証明書の自動更新時の注意

Let's Encryptの証明書は90日ごとに更新されます。

自動更新時にも設定が変更される可能性があるため、以下を定期的に確認：

```bash
# 証明書の有効期限確認
sudo certbot certificates

# 自動更新のテスト（実際には更新しない）
sudo certbot renew --dry-run
```

---

## 📞 次にすべきこと

### 1. すぐに実行（最優先）

```bash
# サーバーにSSH接続して修正スクリプトを実行
ssh portfolio-admin@サーバーIP
cd /var/www/portfolio-site
git pull origin main
chmod +x fix-ssl-403.sh
./fix-ssl-403.sh
```

### 2. 動作確認

ブラウザで https://sy-ryosuke.site にアクセス

### 3. 問題が解決しない場合

```bash
# 診断スクリプトを実行
./diagnose.sh

# または個別にログを確認
sudo tail -100 /var/log/nginx/error.log
pm2 logs portfolio --lines 50
```

---

## 📚 参考リンク

### プロジェクト内ドキュメント

- [実行手順.md](./実行手順.md) - **最初に読むべき**
- [QUICK_FIX.md](./QUICK_FIX.md) - クイック修正ガイド
- [SSL_FIX_GUIDE.md](./SSL_FIX_GUIDE.md) - 詳細ガイド
- [DEPLOY.md](./DEPLOY.md) - デプロイ全体の手順

### 外部リンク

- [Nginx公式ドキュメント](https://nginx.org/en/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [Certbot](https://certbot.eff.org/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)

---

## 💡 まとめ

### 問題
SSL導入後、Nginxのプロキシ設定が失われ403エラーが発生

### 原因
Certbotの自動設定により、Next.jsへのリクエスト転送設定が消失

### 解決方法
Nginx設定ファイルにプロキシ設定を再追加

### 所要時間
自動スクリプト使用で5分、手動で15分

### 重要ファイル
- `fix-ssl-403.sh` (自動修正)
- `実行手順.md` (手順書)

---

**最終更新**: 2025年10月16日
**ステータス**: 修正スクリプトと手順書作成完了、サーバー側での実行待ち

