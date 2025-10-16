'use client';

import Image from 'next/image';
import { Photo } from '@/types';

interface PhotoCardProps {
  photo: Photo;
  onClick: () => void;
}

export default function PhotoCard({ photo, onClick }: PhotoCardProps) {
  return (
    <div
      className="group relative aspect-square cursor-pointer overflow-hidden rounded-lg shadow-md hover:shadow-xl transition-shadow duration-300"
      onClick={onClick}
    >
      {/* 画像 */}
      <Image
        src={photo.image.url}
        alt={photo.title}
        fill
        sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
        className="object-cover transition-transform duration-300 group-hover:scale-110"
      />

      {/* ホバー時のオーバーレイとタイトル */}
      <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-60 transition-all duration-300 flex items-center justify-center">
        <h3 className="text-white text-xl font-bold opacity-0 group-hover:opacity-100 transition-opacity duration-300 px-4 text-center">
          {photo.title}
        </h3>
      </div>
    </div>
  );
}

