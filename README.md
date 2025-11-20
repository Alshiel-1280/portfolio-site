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

詳細な手順は以下のドキュメントを参照してください：

- **[DEPLOY.md](./DEPLOY.md)** - VPSへの完全なデプロイ手順
- **[QUICK_FIX.md](./QUICK_FIX.md)** - SSL導入後の403エラー修正ガイド
- **[SSL_FIX_GUIDE.md](./SSL_FIX_GUIDE.md)** - SSL関連のトラブルシューティング

### クイックスタート

1. GitHubにリポジトリを作成してプッシュ
2. VPSサーバーでリポジトリをクローン
3. 依存パッケージをインストール
4. 環境変数を設定
5. ビルドしてPM2で起動
6. Nginxを設定
7. SSL証明書を導入

### SSL導入後に403エラーが出た場合

```bash
# サーバー上で実行
cd /var/www/portfolio-site
git pull origin main
chmod +x fix-ssl-403.sh
./fix-ssl-403.sh
```

詳細は [QUICK_FIX.md](./QUICK_FIX.md) を参照してください。

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
