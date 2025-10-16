# Portfolio Site

写真とアプリ開発のポートフォリオサイト

## 技術スタック

- **フレームワーク**: Next.js 15 (App Router)
- **言語**: TypeScript
- **スタイリング**: Tailwind CSS v4
- **CMS**: microCMS
- **アニメーション**: Framer Motion
- **アイコン**: React Icons

## 環境構築

### 1. 依存パッケージのインストール

```bash
npm install
```

### 2. microCMSのセットアップ

1. [microCMS](https://microcms.io/)でアカウント作成
2. 新しいサービスを作成
3. 以下の2つのAPIを作成：

#### `photos` API (リスト形式)

| フィールドID | 表示名 | 種類 |
|------------|--------|------|
| title | タイトル | テキストフィールド |
| image | 画像 | 画像 |
| description | 説明 | テキストエリア |
| category | カテゴリー | テキストフィールド |
| date | 撮影日 | 日時 |
| camera | カメラ | テキストフィールド |
| lens | レンズ | テキストフィールド |
| settings | 設定 | テキストフィールド |

#### `apps` API (リスト形式)

| フィールドID | 表示名 | 種類 |
|------------|--------|------|
| title | アプリ名 | テキストフィールド |
| thumbnail | サムネイル | 画像 |
| description | 説明 | テキストエリア |
| tech_stack | 技術スタック | テキストフィールド |
| github_url | GitHubリンク | テキストフィールド |

### 3. 環境変数の設定

`.env.local`ファイルを編集して、microCMSの情報を設定：

```env
MICROCMS_SERVICE_DOMAIN=your-service-id
MICROCMS_API_KEY=your-api-key
```

- `MICROCMS_SERVICE_DOMAIN`: サービスIDを入力
- `MICROCMS_API_KEY`: APIキー（GETのみでOK）を入力

### 4. テストデータの登録

microCMSの管理画面で、`photos`と`apps`にいくつかテストデータを登録してください。

## 開発

開発サーバーの起動：

```bash
npm run dev
```

ブラウザで [http://localhost:3000](http://localhost:3000) を開く

## ビルド

本番用ビルド：

```bash
npm run build
npm start
```

## 機能

### 写真ページ（トップページ）

- グリッドレイアウトで写真を表示
- ホバー時にタイトルを表示
- クリックでモーダルを開き、詳細情報を表示
- レスポンシブ対応（モバイル: 1列、タブレット: 2列、PC: 3-4列）

### アプリ開発ページ

- ダミーデータ表示
- "Coming Soon"バッジ付き
- 将来の拡張を想定した構造

### その他

- スティッキーヘッダー
- モバイルメニュー（ハンバーガー）
- スムーズなアニメーション
- SEO最適化

## デプロイ

### VPSへのデプロイ手順

1. GitHubにリポジトリを作成してプッシュ

```bash
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

2. VPSサーバーにSSH接続

3. リポジトリをクローン

```bash
cd /var/www
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

4. 依存パッケージをインストール

```bash
npm install
```

5. 環境変数を設定

```bash
nano .env.production
# microCMSの情報を入力して保存
```

6. ビルド

```bash
npm run build
```

7. PM2で起動

```bash
pm2 start npm --name "portfolio" -- start
pm2 save
```

8. Nginxの設定

```bash
sudo nano /etc/nginx/sites-available/your-domain.com
```

設定内容：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

9. 設定を有効化

```bash
sudo ln -s /etc/nginx/sites-available/your-domain.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

10. HTTPS化

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

## ディレクトリ構造

```
portfolio-site/
├── src/
│   ├── app/
│   │   ├── layout.tsx          # 全体レイアウト
│   │   ├── page.tsx            # トップページ（写真一覧）
│   │   ├── apps/
│   │   │   └── page.tsx        # アプリ開発ページ
│   │   └── globals.css         # グローバルスタイル
│   ├── components/
│   │   ├── Header.tsx          # ヘッダーナビゲーション
│   │   ├── PhotoGrid.tsx       # 写真グリッド表示
│   │   ├── PhotoCard.tsx       # 写真カード
│   │   ├── PhotoModal.tsx      # 写真詳細モーダル
│   │   └── AppCard.tsx         # アプリカード
│   ├── lib/
│   │   └── microcms.ts         # microCMSクライアント
│   └── types/
│       └── index.ts            # 型定義
├── public/                     # 静的ファイル
├── .env.local                  # 環境変数（ローカル）
└── package.json
```

## 今後の拡張案

- [ ] 写真のカテゴリーフィルター機能
- [ ] アプリ開発セクションの本実装
- [ ] お問い合わせフォーム
- [ ] ブログ機能
- [ ] ダークモード
- [ ] Google Analytics
- [ ] OGP画像の最適化
- [ ] ページネーション

## ライセンス

MIT
