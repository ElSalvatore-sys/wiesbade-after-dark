import { useEffect, useRef, useState } from 'react';
import { Html5Qrcode, Html5QrcodeSupportedFormats } from 'html5-qrcode';
import { X, Loader2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface BarcodeScannerProps {
  isOpen: boolean;
  onClose: () => void;
  onScan: (barcode: string) => void;
}

export function BarcodeScanner({ isOpen, onClose, onScan }: BarcodeScannerProps) {
  const [isScanning, setIsScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [scanSuccess, setScanSuccess] = useState(false);
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
      setIsScanning(false);
      setScanSuccess(false);

      // Create scanner with supported formats configuration
      const scanner = new Html5Qrcode('barcode-reader', {
        formatsToSupport: [
          Html5QrcodeSupportedFormats.EAN_13,
          Html5QrcodeSupportedFormats.EAN_8,
          Html5QrcodeSupportedFormats.UPC_A,
          Html5QrcodeSupportedFormats.UPC_E,
          Html5QrcodeSupportedFormats.CODE_128,
          Html5QrcodeSupportedFormats.CODE_39,
          Html5QrcodeSupportedFormats.QR_CODE,
        ],
        verbose: false,
      });
      scannerRef.current = scanner;

      // Start scanning with camera configuration
      await scanner.start(
        { facingMode: 'environment' },
        {
          fps: 10,
          qrbox: { width: 280, height: 150 },
          aspectRatio: 1.777,
        },
        (decodedText) => {
          // Success callback
          setScanSuccess(true);

          // Vibrate on success (if supported)
          if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
          }

          // Small delay to show success animation
          setTimeout(() => {
            onScan(decodedText);
            stopScanner();
            onClose();
          }, 500);
        },
        () => {
          // Error callback (ignore scan errors - these are continuous scanning errors)
        }
      );

      setIsScanning(true);
    } catch (err) {
      console.error('Scanner error:', err);
      const errorMessage = err instanceof Error ? err.message : 'Unknown error';

      if (errorMessage.includes('Permission') || errorMessage.includes('NotAllowedError')) {
        setError('Kamerazugriff verweigert. Bitte erlauben Sie den Kamerazugriff in den Browser-Einstellungen.');
      } else if (errorMessage.includes('NotFoundError') || errorMessage.includes('No camera')) {
        setError('Keine Kamera gefunden. Bitte stellen Sie sicher, dass Ihr Gerät eine Kamera hat.');
      } else {
        setError('Kamera konnte nicht gestartet werden. Bitte versuchen Sie es erneut.');
      }

      setIsScanning(false);
    }
  };

  const stopScanner = async () => {
    if (scannerRef.current) {
      try {
        if (scannerRef.current.isScanning) {
          await scannerRef.current.stop();
        }
        scannerRef.current.clear();
      } catch (err) {
        console.error('Stop scanner error:', err);
      }
      scannerRef.current = null;
    }
    setIsScanning(false);
    setScanSuccess(false);
  };

  const handleClose = () => {
    stopScanner();
    onClose();
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 bg-black"
      >
        {/* Header */}
        <motion.div
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between p-4 bg-gradient-to-b from-black/80 to-transparent"
        >
          <h2 className="text-lg font-semibold text-white">Barcode Scannen</h2>
          <button
            onClick={handleClose}
            className="p-2 rounded-full bg-white/10 text-white hover:bg-white/20 transition-colors"
          >
            <X size={24} />
          </button>
        </motion.div>

        {/* Scanner container */}
        <div className="absolute inset-0 flex items-center justify-center" ref={containerRef}>
          <div id="barcode-reader" className="w-full h-full" />

          {/* Scanning overlay */}
          <div className="absolute inset-0 pointer-events-none">
            {/* Dark overlay with cutout */}
            <div className="absolute inset-0 bg-black/50" />

            {/* Scanning frame */}
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.2 }}
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 h-40"
            >
              {/* Clear area */}
              <div className="absolute inset-0 bg-transparent" style={{
                boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.5)'
              }} />

              {/* Corner markers with animation */}
              <motion.div
                animate={scanSuccess ? { borderColor: '#10b981', scale: 1.1 } : {}}
                transition={{ duration: 0.3 }}
                className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-accent-purple rounded-tl-lg"
              />
              <motion.div
                animate={scanSuccess ? { borderColor: '#10b981', scale: 1.1 } : {}}
                transition={{ duration: 0.3 }}
                className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-accent-purple rounded-tr-lg"
              />
              <motion.div
                animate={scanSuccess ? { borderColor: '#10b981', scale: 1.1 } : {}}
                transition={{ duration: 0.3 }}
                className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-accent-purple rounded-bl-lg"
              />
              <motion.div
                animate={scanSuccess ? { borderColor: '#10b981', scale: 1.1 } : {}}
                transition={{ duration: 0.3 }}
                className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-accent-purple rounded-br-lg"
              />

              {/* Scanning line animation */}
              {isScanning && !scanSuccess && (
                <motion.div
                  animate={{
                    y: ['-40px', '40px', '-40px'],
                    opacity: [0.5, 1, 0.5],
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    ease: 'easeInOut',
                  }}
                  className="absolute left-2 right-2 h-0.5 bg-gradient-to-r from-transparent via-accent-purple to-transparent"
                />
              )}

              {/* Success overlay */}
              {scanSuccess && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="absolute inset-0 flex items-center justify-center bg-green-500/20 rounded-lg"
                >
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 200 }}
                    className="text-green-500 text-4xl"
                  >
                    ✓
                  </motion.div>
                </motion.div>
              )}
            </motion.div>
          </div>
        </div>

        {/* Bottom info */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.15 }}
          className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/80 to-transparent"
        >
          {error ? (
            <div className="text-center">
              <p className="text-error mb-4">{error}</p>
              <button
                onClick={initScanner}
                className="btn-primary"
              >
                Erneut Versuchen
              </button>
            </div>
          ) : (
            <div className="text-center">
              {isScanning ? (
                scanSuccess ? (
                  <motion.p
                    initial={{ scale: 0.9 }}
                    animate={{ scale: 1 }}
                    className="text-green-500 font-semibold"
                  >
                    Barcode erfolgreich gescannt!
                  </motion.p>
                ) : (
                  <div className="space-y-2">
                    <p className="text-white/80 font-medium">
                      Barcode im Rahmen positionieren
                    </p>
                    <p className="text-white/50 text-sm">
                      Unterstützt: EAN-13, UPC-A, CODE-128, QR-Code
                    </p>
                  </div>
                )
              ) : (
                <div className="flex items-center justify-center gap-2 text-white/60">
                  <Loader2 size={20} className="animate-spin" />
                  <span>Kamera wird initialisiert...</span>
                </div>
              )}
            </div>
          )}

          {/* Manual entry hint */}
          {!scanSuccess && (
            <p className="text-center text-white/40 text-sm mt-4">
              Scannen nicht möglich? Barcode manuell im Formular eingeben
            </p>
          )}
        </motion.div>

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
          #barcode-reader__dashboard_section {
            display: none !important;
          }
          #barcode-reader__header_message {
            display: none !important;
          }
        `}</style>
      </motion.div>
    </AnimatePresence>
  );
}
