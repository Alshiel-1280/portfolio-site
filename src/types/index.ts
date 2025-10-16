// 写真作品の型定義
export type Photo = {
  id: string;
  title: string;
  image: { url: string };
  description: string;
  category: string;
  date: string;
  camera?: string;
  lens?: string;
  settings?: string;
};

// アプリ開発作品の型定義
export type App = {
  id: string;
  title: string;
  thumbnail: { url: string };
  description: string;
  tech_stack: string;
  github_url?: string;
};

// microCMSのレスポンス型
export type MicroCMSListResponse<T> = {
  contents: T[];
  totalCount: number;
  offset: number;
  limit: number;
};

