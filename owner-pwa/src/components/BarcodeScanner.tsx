import { useEffect, useRef, useState } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import { X, Loader2 } from 'lucide-react';

interface BarcodeScannerProps {
  isOpen: boolean;
  onClose: () => void;
  onScan: (barcode: string) => void;
}

export function BarcodeScanner({ isOpen, onClose, onScan }: BarcodeScannerProps) {
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const scannerRef = useRef<Html5Qrcode | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen && !scannerRef.current) {
      initScanner();
    }

    return () => {
      stopScanner();
    };
  }, [isOpen]);

  const initScanner = async () => {
    try {
      setError(null);
      setIsScanning(true);

      const scanner = new Html5Qrcode('barcode-reader');
      scannerRef.current = scanner;

      await scanner.start(
        { facingMode: 'environment' },
        {
          fps: 10,
          qrbox: { width: 280, height: 150 },
          aspectRatio: 1.777,
        },
        (decodedText) => {
          // Success callback
          onScan(decodedText);
          stopScanner();
          onClose();
        },
        () => {
          // Error callback (ignore scan errors)
        }
      );
    } catch (err) {
      console.error('Scanner error:', err);
      setError('Camera access denied or not available');
      setIsScanning(false);
    }
  };

  const stopScanner = async () => {
    if (scannerRef.current) {
      try {
        await scannerRef.current.stop();
        scannerRef.current.clear();
      } catch (err) {
        console.error('Stop scanner error:', err);
      }
      scannerRef.current = null;
    }
    setIsScanning(false);
  };

  const handleClose = () => {
    stopScanner();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between p-4 bg-gradient-to-b from-black/80 to-transparent">
        <h2 className="text-lg font-semibold text-white">Scan Barcode</h2>
        <button
          onClick={handleClose}
          className="p-2 rounded-full bg-white/10 text-white hover:bg-white/20 transition-colors"
        >
          <X size={24} />
        </button>
      </div>

      {/* Scanner container */}
      <div className="absolute inset-0 flex items-center justify-center" ref={containerRef}>
        <div id="barcode-reader" className="w-full h-full" />

        {/* Scanning overlay */}
        <div className="absolute inset-0 pointer-events-none">
          {/* Dark overlay with cutout */}
          <div className="absolute inset-0 bg-black/50" />

          {/* Scanning frame */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-40">
            {/* Clear area */}
            <div className="absolute inset-0 bg-transparent" style={{
              boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.5)'
            }} />

            {/* Corner markers */}
            <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-accent-purple rounded-tl-lg" />
            <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-accent-purple rounded-tr-lg" />
            <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-accent-purple rounded-bl-lg" />
            <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-accent-purple rounded-br-lg" />

            {/* Scanning line animation */}
            {isScanning && (
              <div className="absolute left-2 right-2 h-0.5 bg-gradient-to-r from-transparent via-accent-purple to-transparent animate-pulse"
                style={{
                  top: '50%',
                  animation: 'scan 2s ease-in-out infinite'
                }}
              />
            )}
          </div>
        </div>
      </div>

      {/* Bottom info */}
      <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/80 to-transparent">
        {error ? (
          <div className="text-center">
            <p className="text-error mb-4">{error}</p>
            <button
              onClick={initScanner}
              className="btn-primary"
            >
              Try Again
            </button>
          </div>
        ) : (
          <div className="text-center">
            {isScanning ? (
              <p className="text-white/80">
                Position barcode within the frame
              </p>
            ) : (
              <div className="flex items-center justify-center gap-2 text-white/60">
                <Loader2 size={20} className="animate-spin" />
                <span>Initializing camera...</span>
              </div>
            )}
          </div>
        )}

        {/* Manual entry hint */}
        <p className="text-center text-white/40 text-sm mt-4">
          Can't scan? Enter barcode manually in the add item form
        </p>
      </div>

      {/* Custom styles for scanner */}
      <style>{`
        #barcode-reader {
          border: none !important;
        }
        #barcode-reader video {
          object-fit: cover !important;
          width: 100% !important;
          height: 100% !important;
        }
        #barcode-reader__scan_region {
          display: none !important;
        }
        #barcode-reader__dashboard {
          display: none !important;
        }
        @keyframes scan {
          0%, 100% { transform: translateY(-40px); opacity: 0.5; }
          50% { transform: translateY(40px); opacity: 1; }
        }
      `}</style>
    </div>
  );
}
