'use client';

import { useEffect } from 'react';
import Image from 'next/image';
import { motion, AnimatePresence } from 'framer-motion';
import { HiX } from 'react-icons/hi';
import { Photo } from '@/types';

interface PhotoModalProps {
  photo: Photo;
  onClose: () => void;
}

export default function PhotoModal({ photo, onClose }: PhotoModalProps) {
  // ESCキーでモーダルを閉じる
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    window.addEventListener('keydown', handleEsc);
    // スクロールを無効化
    document.body.style.overflow = 'hidden';
    
    return () => {
      window.removeEventListener('keydown', handleEsc);
      document.body.style.overflow = 'unset';
    };
  }, [onClose]);

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-90 p-4"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          transition={{ duration: 0.3 }}
          className="relative max-w-6xl w-full max-h-[90vh] bg-white rounded-lg overflow-hidden"
          onClick={(e) => e.stopPropagation()}
        >
          {/* 閉じるボタン */}
          <button
            className="absolute top-4 right-4 z-10 text-gray-700 hover:text-gray-900 bg-white rounded-full p-2 shadow-lg transition-colors"
            onClick={onClose}
            aria-label="閉じる"
          >
            <HiX className="text-2xl" />
          </button>

          <div className="flex flex-col md:flex-row max-h-[90vh]">
            {/* 画像部分 */}
            <div className="relative w-full md:w-2/3 h-64 md:h-auto">
              <Image
                src={photo.image.url}
                alt={photo.title}
                fill
                sizes="(max-width: 768px) 100vw, 66vw"
                className="object-contain"
                priority
              />
            </div>

            {/* 情報部分 */}
            <div className="w-full md:w-1/3 p-6 overflow-y-auto">
              <h2 className="text-2xl font-bold text-gray-900 mb-4">
                {photo.title}
              </h2>

              {photo.category && (
                <div className="mb-4">
                  <span className="inline-block bg-blue-100 text-blue-800 text-sm px-3 py-1 rounded-full">
                    {photo.category}
                  </span>
                </div>
              )}

              {photo.description && (
                <div className="mb-6">
                  <p className="text-gray-700 leading-relaxed whitespace-pre-wrap">
                    {photo.description}
                  </p>
                </div>
              )}

              {/* カメラ情報 */}
              <div className="border-t pt-4 space-y-2">
                {photo.date && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600 font-medium">撮影日:</span>
                    <span className="text-gray-800">
                      {new Date(photo.date).toLocaleDateString('ja-JP')}
                    </span>
                  </div>
                )}
                {photo.camera && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600 font-medium">カメラ:</span>
                    <span className="text-gray-800">{photo.camera}</span>
                  </div>
                )}
                {photo.lens && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600 font-medium">レンズ:</span>
                    <span className="text-gray-800">{photo.lens}</span>
                  </div>
                )}
                {photo.settings && (
                  <div className="flex justify-between text-sm">
                    <span className="text-gray-600 font-medium">設定:</span>
                    <span className="text-gray-800">{photo.settings}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

