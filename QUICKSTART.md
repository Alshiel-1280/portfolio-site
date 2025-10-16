# クイックスタートガイド

このガイドでは、最短でポートフォリオサイトを動かすまでの手順を説明します。

## 🚀 5分で始める

### ステップ1: microCMSのセットアップ（5分）

1. [microCMS](https://microcms.io/)でアカウント作成
2. サービスを作成（サービスID: 例 `portfolio-site`）
3. 2つのAPIを作成：
   - `photos`（写真作品）- リスト形式
   - `apps`（アプリ開発）- リスト形式

**詳細な手順は [MICROCMS_SETUP.md](./MICROCMS_SETUP.md) を参照してください。**

### ステップ2: APIキーの取得

1. microCMSの「APIキー」メニューから新規作成
2. 権限: GET（読み取りのみ）
3. 発行されたAPIキーをコピー

### ステップ3: 環境変数の設定

プロジェクトルートの `.env.local` を編集：

```env
MICROCMS_SERVICE_DOMAIN=あなたのサービスID
MICROCMS_API_KEY=あなたのAPIキー
```

### ステップ4: テストデータの登録

microCMSの管理画面で、`photos` に2〜3件のテストデータを登録してください。

**最低限必要なフィールド:**
- タイトル（必須）
- 画像（必須）

**その他のフィールドはオプションです。**

### ステップ5: 開発サーバーを起動

```bash
npm run dev
```

ブラウザで [http://localhost:3000](http://localhost:3000) を開く。

## ✅ 動作確認

### 写真ページ（トップページ）

- 登録した写真が表示される
- 写真にマウスをホバーするとタイトルが表示される
- 写真をクリックするとモーダルで詳細が表示される

### アプリ開発ページ

- `/apps` にアクセス
- 「準備中」メッセージが表示される
- `apps` APIにデータを登録すれば表示される

## 📱 レスポンシブ確認

開発者ツール（F12）でデバイスモードを有効にし、以下を確認：

- **モバイル（< 640px）**: 1列表示
- **タブレット（640px〜1024px）**: 2列表示
- **デスクトップ（> 1024px）**: 3〜4列表示

## 🎨 カスタマイズ

### サイトタイトルの変更

`src/app/layout.tsx`:

```typescript
export const metadata: Metadata = {
  title: "あなたの名前 | Portfolio",
  description: "あなたの説明",
};
```

### ヘッダーロゴの変更

`src/components/Header.tsx`:

```typescript
<Link href="/" className="...">
  Your Name
</Link>
```

### カラーテーマの変更

`src/app/globals.css` や各コンポーネントのTailwindクラスを編集。

## 📦 本番ビルド

```bash
npm run build
npm start
```

## 🚀 デプロイ

VPSへのデプロイ手順は [DEPLOY.md](./DEPLOY.md) を参照してください。

## ❓ トラブルシューティング

### 「写真データが見つかりませんでした」と表示される

1. `.env.local` の設定が正しいか確認
2. microCMSにデータが登録されているか確認
3. 開発サーバーを再起動

### 画像が表示されない

- `next.config.ts` にmicroCMSのドメインが追加されているか確認（既に設定済み）
- 開発サーバーを再起動

### ビルドエラーが出る

```bash
# キャッシュをクリア
rm -rf .next
npm run build
```

## 📚 詳細ドキュメント

- [README.md](./README.md) - 全体概要と技術スタック
- [MICROCMS_SETUP.md](./MICROCMS_SETUP.md) - microCMSの詳細設定
- [DEPLOY.md](./DEPLOY.md) - VPSへのデプロイ手順

## 🆘 サポート

問題が解決しない場合は、以下を確認：

1. Node.jsのバージョン: `node -v`（推奨: v18以上）
2. npmのバージョン: `npm -v`
3. エラーログ: ターミナルのエラーメッセージ全文

---

**それでは、素敵なポートフォリオサイトを作成してください！🎉**

