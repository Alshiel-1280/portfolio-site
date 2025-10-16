'use client';

import Image from 'next/image';
import { App } from '@/types';
import { HiExternalLink } from 'react-icons/hi';

interface AppCardProps {
  app: App;
}

export default function AppCard({ app }: AppCardProps) {
  return (
    <div className="group relative bg-white rounded-lg shadow-md hover:shadow-xl transition-all duration-300 overflow-hidden">
      {/* Coming Soon バッジ */}
      <div className="absolute top-4 right-4 z-10 bg-yellow-500 text-white text-xs font-bold px-3 py-1 rounded-full shadow-lg">
        Coming Soon
      </div>

      {/* サムネイル */}
      <div className="relative w-full h-48 bg-gray-200">
        <Image
          src={app.thumbnail.url}
          alt={app.title}
          fill
          sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
          className="object-cover group-hover:scale-105 transition-transform duration-300"
        />
      </div>

      {/* コンテンツ */}
      <div className="p-6">
        <h3 className="text-xl font-bold text-gray-900 mb-2">
          {app.title}
        </h3>
        
        <p className="text-gray-600 text-sm mb-4 line-clamp-3">
          {app.description}
        </p>

        {/* 技術スタック */}
        {app.tech_stack && (
          <div className="mb-4">
            <div className="flex flex-wrap gap-2">
              {app.tech_stack.split(',').map((tech, index) => (
                <span
                  key={index}
                  className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded"
                >
                  {tech.trim()}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* GitHubリンク */}
        {app.github_url && (
          <a
            href={app.github_url}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center text-blue-600 hover:text-blue-800 text-sm font-medium transition-colors opacity-50 cursor-not-allowed"
            onClick={(e) => e.preventDefault()}
          >
            <HiExternalLink className="mr-1" />
            GitHub (準備中)
          </a>
        )}
      </div>
    </div>
  );
}

