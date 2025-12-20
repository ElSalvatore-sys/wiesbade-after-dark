import { useRef, useState, useCallback } from 'react';
import { Camera, Upload, X, Check, RotateCcw } from 'lucide-react';
import { cn } from '../lib/utils';

interface PhotoUploadProps {
  onPhotoCapture: (photoUrl: string) => void;
  currentPhoto?: string;
  label?: string;
  required?: boolean;
  className?: string;
}

/**
 * PhotoUpload component for capturing task completion proof
 * Supports camera capture (mobile-first) and file upload
 */
export function PhotoUpload({
  onPhotoCapture,
  currentPhoto,
  label = 'Photo Proof',
  required = false,
  className,
}: PhotoUploadProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const [preview, setPreview] = useState<string | null>(currentPhoto || null);
  const [showCamera, setShowCamera] = useState(false);
  const [stream, setStream] = useState<MediaStream | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Handle file selection from gallery
  const handleFileSelect = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setError('Please select an image file');
      return;
    }

    // Validate file size (max 5MB)
    if (file.size > 5 * 1024 * 1024) {
      setError('Image must be less than 5MB');
      return;
    }

    setIsLoading(true);
    setError(null);

    const reader = new FileReader();
    reader.onloadend = () => {
      const result = reader.result as string;
      // Compress image if needed
      compressImage(result, 1200, 0.8).then((compressed) => {
        setPreview(compressed);
        onPhotoCapture(compressed);
        setIsLoading(false);
      });
    };
    reader.onerror = () => {
      setError('Failed to read file');
      setIsLoading(false);
    };
    reader.readAsDataURL(file);
  }, [onPhotoCapture]);

  // Compress image to reduce size
  const compressImage = (dataUrl: string, maxWidth: number, quality: number): Promise<string> => {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let { width, height } = img;

        if (width > maxWidth) {
          height = (height * maxWidth) / width;
          width = maxWidth;
        }

        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext('2d');
        ctx?.drawImage(img, 0, 0, width, height);

        resolve(canvas.toDataURL('image/jpeg', quality));
      };
      img.src = dataUrl;
    });
  };

  // Start camera stream
  const startCamera = async () => {
    try {
      setIsLoading(true);
      setError(null);

      const mediaStream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: 'environment', // Prefer back camera on mobile
          width: { ideal: 1280 },
          height: { ideal: 720 }
        }
      });

      setStream(mediaStream);
      setShowCamera(true);

      // Wait for video element to be ready
      setTimeout(() => {
        if (videoRef.current) {
          videoRef.current.srcObject = mediaStream;
          videoRef.current.play();
        }
        setIsLoading(false);
      }, 100);
    } catch (err) {
      console.error('Camera error:', err);
      setError('Camera access denied. Use file upload instead.');
      setIsLoading(false);
      // Fallback to file input
      fileInputRef.current?.click();
    }
  };

  // Capture photo from video stream
  const capturePhoto = () => {
    if (!videoRef.current || !canvasRef.current) return;

    const video = videoRef.current;
    const canvas = canvasRef.current;

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;

    const ctx = canvas.getContext('2d');
    ctx?.drawImage(video, 0, 0);

    const photoUrl = canvas.toDataURL('image/jpeg', 0.8);
    setPreview(photoUrl);
    onPhotoCapture(photoUrl);

    stopCamera();
  };

  // Stop camera stream
  const stopCamera = () => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    setShowCamera(false);
  };

  // Clear current photo
  const clearPhoto = () => {
    setPreview(null);
    onPhotoCapture('');
    setError(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  // Retake photo
  const retakePhoto = () => {
    clearPhoto();
    startCamera();
  };

  return (
    <div className={cn('space-y-3', className)}>
      {/* Label */}
      <label className="block text-sm font-medium text-foreground-muted">
        {label}
        {required && <span className="text-error ml-1">*</span>}
      </label>

      {/* Error message */}
      {error && (
        <div className="p-3 bg-error/10 border border-error/30 rounded-lg text-sm text-error">
          {error}
        </div>
      )}

      {/* Camera View */}
      {showCamera && (
        <div className="relative rounded-xl overflow-hidden bg-black">
          <video
            ref={videoRef}
            autoPlay
            playsInline
            muted
            className="w-full h-64 object-cover"
          />
          <canvas ref={canvasRef} className="hidden" />

          {/* Camera Controls */}
          <div className="absolute bottom-4 left-0 right-0 flex justify-center gap-4">
            <button
              onClick={stopCamera}
              className="p-3 bg-white/20 backdrop-blur-sm rounded-full text-white hover:bg-white/30 transition-all"
            >
              <X size={24} />
            </button>
            <button
              onClick={capturePhoto}
              className="p-4 bg-white rounded-full text-black hover:bg-gray-200 transition-all shadow-lg"
            >
              <Camera size={28} />
            </button>
          </div>
        </div>
      )}

      {/* Preview */}
      {preview && !showCamera && (
        <div className="relative">
          <img
            src={preview}
            alt="Photo proof"
            className="w-full h-48 object-cover rounded-xl border border-border"
          />

          {/* Photo Actions */}
          <div className="absolute top-2 right-2 flex gap-2">
            <button
              onClick={retakePhoto}
              className="p-2 bg-black/60 backdrop-blur-sm rounded-lg text-white hover:bg-black/80 transition-all"
              title="Retake"
            >
              <RotateCcw size={18} />
            </button>
            <button
              onClick={clearPhoto}
              className="p-2 bg-error/80 backdrop-blur-sm rounded-lg text-white hover:bg-error transition-all"
              title="Remove"
            >
              <X size={18} />
            </button>
          </div>

          {/* Success indicator */}
          <div className="absolute bottom-2 left-2 flex items-center gap-1.5 px-2 py-1 bg-success/90 backdrop-blur-sm rounded-lg text-white text-sm">
            <Check size={14} />
            <span>Photo attached</span>
          </div>
        </div>
      )}

      {/* Upload Buttons */}
      {!preview && !showCamera && (
        <div className="flex gap-3">
          {/* Camera Button */}
          <button
            onClick={startCamera}
            disabled={isLoading}
            className={cn(
              'flex-1 flex flex-col items-center justify-center gap-2 p-6',
              'border-2 border-dashed border-border rounded-xl',
              'hover:border-primary-500 hover:bg-primary-500/5 transition-all',
              'disabled:opacity-50 disabled:cursor-not-allowed'
            )}
          >
            <div className="p-3 bg-primary-500/20 rounded-full">
              <Camera className="w-6 h-6 text-primary-400" />
            </div>
            <span className="text-foreground-muted text-sm">
              {isLoading ? 'Opening camera...' : 'Take Photo'}
            </span>
          </button>

          {/* Upload Button */}
          <button
            onClick={() => fileInputRef.current?.click()}
            disabled={isLoading}
            className={cn(
              'flex-1 flex flex-col items-center justify-center gap-2 p-6',
              'border-2 border-dashed border-border rounded-xl',
              'hover:border-primary-500 hover:bg-primary-500/5 transition-all',
              'disabled:opacity-50 disabled:cursor-not-allowed'
            )}
          >
            <div className="p-3 bg-accent-cyan/20 rounded-full">
              <Upload className="w-6 h-6 text-accent-cyan" />
            </div>
            <span className="text-foreground-muted text-sm">
              Upload Image
            </span>
          </button>
        </div>
      )}

      {/* Hidden file input */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        onChange={handleFileSelect}
        className="hidden"
      />
    </div>
  );
}

export default PhotoUpload;
