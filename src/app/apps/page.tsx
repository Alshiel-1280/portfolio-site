import { Metadata } from 'next';
import { client } from '@/lib/microcms';
import { App, MicroCMSListResponse } from '@/types';
import AppCard from '@/components/AppCard';

export const metadata: Metadata = {
  title: 'アプリ開発 | Portfolio',
  description: 'アプリ開発作品のポートフォリオ',
};

// ISR: 60秒ごとに再検証
export const revalidate = 60;

async function getApps(): Promise<App[]> {
  try {
    const data = await client.get<MicroCMSListResponse<App>>({
      endpoint: 'apps',
      queries: {
        limit: 100,
      },
    });
    return data.contents;
  } catch (error) {
    console.error('アプリデータの取得に失敗しました:', error);
    // エラー時は空配列を返す
    return [];
  }
}

export default async function AppsPage() {
  const apps = await getApps();

  return (
    <div className="container mx-auto px-4 py-8">
      {/* ヘッダーセクション */}
      <section className="mb-12 text-center">
        <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
          App Development
        </h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          開発したアプリケーションの一覧です。<br />
          現在準備中のため、もうしばらくお待ちください。
        </p>
        <div className="mt-6 inline-block bg-yellow-100 text-yellow-800 px-6 py-3 rounded-lg">
          <p className="font-medium">🚧 このセクションは現在構築中です</p>
        </div>
      </section>

      {/* アプリグリッド */}
      {apps.length > 0 ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {apps.map((app) => (
            <AppCard key={app.id} app={app} />
          ))}
        </div>
      ) : (
        <div className="text-center py-20">
          <p className="text-gray-500 text-lg">
            アプリデータが見つかりませんでした。
          </p>
          <p className="text-gray-400 text-sm mt-2">
            microCMSでダミーデータを登録してください。
          </p>
        </div>
      )}
    </div>
  );
}

