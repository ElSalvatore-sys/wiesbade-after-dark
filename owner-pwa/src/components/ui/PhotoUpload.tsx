/**
 * PhotoUpload Component
 * Handles image upload to Supabase Storage
 */

import React, { useState, useRef } from 'react';
import { Camera, Upload, X, Loader2 } from 'lucide-react';
import { supabase } from '../../lib/supabase';
import { cn } from '../../lib/utils';

interface PhotoUploadProps {
  currentPhotoUrl?: string | null;
  onUpload: (url: string) => void;
  onRemove?: () => void;
  bucket?: string;
  folder?: string;
  size?: 'sm' | 'md' | 'lg';
  shape?: 'circle' | 'square';
  label?: string;
  disabled?: boolean;
}

const sizeClasses = {
  sm: 'w-16 h-16',
  md: 'w-24 h-24',
  lg: 'w-32 h-32',
};

export const PhotoUpload: React.FC<PhotoUploadProps> = ({
  currentPhotoUrl,
  onUpload,
  onRemove,
  bucket = 'photos',
  folder = 'employees',
  size = 'md',
  shape = 'circle',
  label = 'Foto hochladen',
  disabled = false,
}) => {
  const [isUploading, setIsUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [preview, setPreview] = useState<string | null>(currentPhotoUrl || null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setError('Bitte wählen Sie eine Bilddatei aus');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      setError('Datei ist zu groß (max. 5MB)');
      return;
    }

    setError(null);
    setIsUploading(true);

    try {
      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => setPreview(e.target?.result as string);
      reader.readAsDataURL(file);

      // Generate unique filename
      const fileExt = file.name.split('.').pop();
      const fileName = `${folder}/${Date.now()}-${Math.random().toString(36).substr(2, 9)}.${fileExt}`;

      // Upload to Supabase Storage
      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false,
        });

      if (uploadError) {
        throw uploadError;
      }

      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from(bucket)
        .getPublicUrl(data.path);

      onUpload(publicUrl);
    } catch (err: any) {
      console.error('Upload error:', err);
      setError(err.message || 'Fehler beim Hochladen');
      setPreview(currentPhotoUrl || null);
    } finally {
      setIsUploading(false);
    }
  };

  const handleRemove = () => {
    setPreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
    onRemove?.();
  };

  const handleClick = () => {
    if (!disabled && !isUploading) {
      fileInputRef.current?.click();
    }
  };

  return (
    <div className="flex flex-col items-center gap-2">
      {/* Upload area */}
      <div
        onClick={handleClick}
        className={cn(
          'relative flex items-center justify-center border-2 border-dashed transition-all cursor-pointer',
          'hover:border-purple-500 hover:bg-purple-500/10',
          sizeClasses[size],
          shape === 'circle' ? 'rounded-full' : 'rounded-lg',
          preview ? 'border-transparent' : 'border-gray-600 bg-gray-800',
          disabled && 'opacity-50 cursor-not-allowed',
          isUploading && 'pointer-events-none'
        )}
      >
        {preview ? (
          <>
            <img
              src={preview}
              alt="Preview"
              className={cn(
                'w-full h-full object-cover',
                shape === 'circle' ? 'rounded-full' : 'rounded-lg'
              )}
            />
            {/* Overlay on hover */}
            <div className={cn(
              'absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity',
              shape === 'circle' ? 'rounded-full' : 'rounded-lg'
            )}>
              <Camera className="w-6 h-6 text-white" />
            </div>
            {/* Remove button */}
            {onRemove && !isUploading && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  handleRemove();
                }}
                className="absolute -top-1 -right-1 p-1 bg-red-500 rounded-full text-white hover:bg-red-600 transition-colors"
              >
                <X className="w-3 h-3" />
              </button>
            )}
          </>
        ) : isUploading ? (
          <Loader2 className="w-8 h-8 text-purple-400 animate-spin" />
        ) : (
          <div className="flex flex-col items-center gap-1 text-gray-400">
            <Upload className="w-6 h-6" />
            <span className="text-xs">Upload</span>
          </div>
        )}
      </div>

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/jpeg,image/png,image/webp,image/gif"
        onChange={handleFileSelect}
        className="hidden"
        disabled={disabled || isUploading}
      />

      {/* Label */}
      {label && !preview && (
        <span className="text-xs text-gray-500">{label}</span>
      )}

      {/* Error message */}
      {error && (
        <span className="text-xs text-red-400">{error}</span>
      )}

      {/* Upload status */}
      {isUploading && (
        <span className="text-xs text-purple-400">Wird hochgeladen...</span>
      )}
    </div>
  );
};

export default PhotoUpload;
