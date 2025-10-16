# microCMS セットアップガイド

このドキュメントでは、ポートフォリオサイト用のmicroCMS設定方法を詳しく説明します。

## 1. microCMSアカウントの作成

1. [microCMS](https://microcms.io/)にアクセス
2. 「無料で始める」をクリック
3. メールアドレスとパスワードを入力して登録

## 2. サービスの作成

1. ダッシュボードで「サービスを作成」をクリック
2. サービス名を入力（例: `portfolio`）
3. サービスIDを設定（例: `portfolio-site`）
   - このIDが`MICROCMS_SERVICE_DOMAIN`になります
4. 「作成する」をクリック

## 3. API の作成

### 3-1. 写真作品API (`photos`)

1. 「API を作成」をクリック
2. 以下を入力：
   - **API 名**: 写真作品
   - **エンドポイント**: `photos`
   - **API の型**: リスト形式

3. 「作成」をクリック

4. フィールドを追加：

#### a. タイトル
- **フィールド ID**: `title`
- **表示名**: タイトル
- **種類**: テキストフィールド
- **必須項目**: ON

#### b. 画像
- **フィールド ID**: `image`
- **表示名**: 画像
- **種類**: 画像
- **必須項目**: ON

#### c. 説明
- **フィールド ID**: `description`
- **表示名**: 説明
- **種類**: テキストエリア
- **必須項目**: OFF

#### d. カテゴリー
- **フィールド ID**: `category`
- **表示名**: カテゴリー
- **種類**: テキストフィールド
- **必須項目**: OFF
- 例: 風景、ポートレート、スナップなど

#### e. 撮影日
- **フィールド ID**: `date`
- **表示名**: 撮影日
- **種類**: 日時
- **必須項目**: OFF

#### f. カメラ
- **フィールド ID**: `camera`
- **表示名**: カメラ
- **種類**: テキストフィールド
- **必須項目**: OFF
- 例: Canon EOS R5

#### g. レンズ
- **フィールド ID**: `lens`
- **表示名**: レンズ
- **種類**: テキストフィールド
- **必須項目**: OFF
- 例: RF 24-70mm F2.8 L IS USM

#### h. 設定
- **フィールド ID**: `settings`
- **表示名**: 設定
- **種類**: テキストフィールド
- **必須項目**: OFF
- 例: F2.8, 1/250s, ISO 400

### 3-2. アプリ開発API (`apps`)

1. 「API を作成」をクリック
2. 以下を入力：
   - **API 名**: アプリ開発
   - **エンドポイント**: `apps`
   - **API の型**: リスト形式

3. 「作成」をクリック

4. フィールドを追加：

#### a. タイトル
- **フィールド ID**: `title`
- **表示名**: アプリ名
- **種類**: テキストフィールド
- **必須項目**: ON

#### b. サムネイル
- **フィールド ID**: `thumbnail`
- **表示名**: サムネイル
- **種類**: 画像
- **必須項目**: ON

#### c. 説明
- **フィールド ID**: `description`
- **表示名**: 説明
- **種類**: テキストエリア
- **必須項目**: OFF

#### d. 技術スタック
- **フィールド ID**: `tech_stack`
- **表示名**: 技術スタック
- **種類**: テキストフィールド
- **必須項目**: OFF
- 例: React, TypeScript, Next.js（カンマ区切り）

#### e. GitHub リンク
- **フィールド ID**: `github_url`
- **表示名**: GitHub リンク
- **種類**: テキストフィールド
- **必須項目**: OFF

## 4. API キーの取得

1. サイドバーの「API キー」をクリック
2. 「API キーを追加」をクリック
3. 以下を設定：
   - **名前**: Portfolio Site
   - **権限**: GET（読み取り専用でOK）
4. 「作成」をクリック
5. 表示された API キーをコピー
   - このキーが`MICROCMS_API_KEY`になります

## 5. 環境変数の設定

プロジェクトの`.env.local`ファイルに以下を記載：

```env
MICROCMS_SERVICE_DOMAIN=your-service-id
MICROCMS_API_KEY=your-api-key
```

- `your-service-id`: 手順2で設定したサービスID
- `your-api-key`: 手順4で取得したAPIキー

## 6. テストデータの登録

### 写真データの例

1. `photos` APIの「コンテンツを追加」をクリック
2. 以下のような情報を入力：

**例1: 夕日の風景**
- タイトル: 夕日に染まる海
- 画像: （お好みの写真をアップロード）
- 説明: 静かな海岸に沈む夕日を撮影しました。オレンジ色の光が水面を照らし、幻想的な雰囲気を作り出しています。
- カテゴリー: 風景
- 撮影日: 2024-10-01
- カメラ: Canon EOS R5
- レンズ: RF 24-70mm F2.8 L IS USM
- 設定: F8, 1/125s, ISO 100

**例2: 街のスナップ**
- タイトル: 雨上がりの街角
- 画像: （お好みの写真をアップロード）
- 説明: 雨上がりの夜、濡れた路面に街の灯りが反射する様子を捉えました。
- カテゴリー: スナップ
- 撮影日: 2024-09-15
- カメラ: Sony α7 IV
- レンズ: FE 50mm F1.8
- 設定: F1.8, 1/60s, ISO 800

3〜4枚程度のテストデータを登録してください。

### アプリデータの例（ダミー）

1. `apps` APIの「コンテンツを追加」をクリック
2. 以下のような情報を入力：

**例1**
- アプリ名: タスク管理アプリ
- サムネイル: （ダミー画像をアップロード）
- 説明: シンプルで使いやすいタスク管理アプリケーション。ドラッグ&ドロップでタスクを整理できます。
- 技術スタック: React, TypeScript, Firebase
- GitHub リンク: https://github.com/username/task-app

**例2**
- アプリ名: 天気予報アプリ
- サムネイル: （ダミー画像をアップロード）
- 説明: リアルタイムの天気情報を表示するWebアプリケーション。
- 技術スタック: Next.js, Tailwind CSS, OpenWeather API
- GitHub リンク: https://github.com/username/weather-app

**例3**
- アプリ名: ポートフォリオサイト
- サムネイル: （ダミー画像をアップロード）
- 説明: 写真とアプリ開発のポートフォリオサイト（このサイト）
- 技術スタック: Next.js, TypeScript, microCMS, Tailwind CSS
- GitHub リンク: https://github.com/username/portfolio

## 7. 動作確認

1. 開発サーバーを起動：
```bash
npm run dev
```

2. ブラウザで `http://localhost:3000` を開く

3. 写真ページに登録した写真が表示されることを確認

4. `/apps` にアクセスしてアプリ一覧が表示されることを確認

## トラブルシューティング

### 「写真データが見つかりませんでした」と表示される

1. `.env.local` の設定が正しいか確認
2. microCMS で `photos` API が作成されているか確認
3. microCMS にコンテンツが登録されているか確認
4. 開発サーバーを再起動 (`Ctrl+C` → `npm run dev`)

### 画像が表示されない

1. Next.js の設定で microCMS のドメインを許可する必要があります
2. `next.config.ts` に以下を追加：

```typescript
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.microcms-assets.io',
      },
    ],
  },
};

export default nextConfig;
```

3. 開発サーバーを再起動

### API キーが無効と表示される

1. microCMS でAPIキーの権限を確認（GETが有効になっているか）
2. `.env.local` のAPIキーをコピペし直す
3. 開発サーバーを再起動

## 参考リンク

- [microCMS 公式ドキュメント](https://document.microcms.io/)
- [Next.js 公式ドキュメント](https://nextjs.org/docs)
- [microCMS JavaScript SDK](https://github.com/microcmsio/microcms-js-sdk)

