import { Metadata } from 'next';
import { client } from '@/lib/microcms';
import { Photo, MicroCMSListResponse } from '@/types';
import PhotoGrid from '@/components/PhotoGrid';

export const metadata: Metadata = {
  title: '写真作品 | Portfolio',
  description: '写真作品のポートフォリオギャラリー',
};

// ISR: 60秒ごとに再検証
export const revalidate = 60;

async function getPhotos(): Promise<Photo[]> {
  try {
    const data = await client.get<MicroCMSListResponse<Photo>>({
      endpoint: 'photos',
      queries: {
        limit: 100,
        orders: '-date', // 撮影日の新しい順
      },
    });
    return data.contents;
  } catch (error) {
    console.error('写真データの取得に失敗しました:', error);
    // エラー時は空配列を返す
    return [];
  }
}

export default async function Home() {
  const photos = await getPhotos();

  return (
    <div className="container mx-auto px-4 py-8">
      {/* ヘッダーセクション */}
      <section className="mb-12 text-center">
        <h1 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
          Photo Gallery
        </h1>
        <p className="text-lg text-gray-600 max-w-2xl mx-auto">
          カメラで切り取った瞬間の美しさをお楽しみください。<br />
          写真をクリックすると詳細情報が表示されます。
        </p>
      </section>

      {/* 写真グリッド */}
      {photos.length > 0 ? (
        <PhotoGrid photos={photos} />
      ) : (
        <div className="text-center py-20">
          <p className="text-gray-500 text-lg">
            写真データが見つかりませんでした。
          </p>
          <p className="text-gray-400 text-sm mt-2">
            microCMSで写真データを登録してください。
          </p>
        </div>
      )}
    </div>
  );
}
