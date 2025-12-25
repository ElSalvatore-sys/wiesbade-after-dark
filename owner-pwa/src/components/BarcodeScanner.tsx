/**
 * BarcodeScanner Component
 * Robust implementation using html5-qrcode
 * Supports: EAN-13, EAN-8, UPC-A, UPC-E, Code-128, Code-39, QR
 */

import React, { useEffect, useRef, useState, useCallback } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import { X, Camera, Keyboard, AlertCircle, CheckCircle } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

interface BarcodeScannerProps {
  isOpen: boolean;
  onClose: () => void;
  onScan: (barcode: string) => void;
}

export const BarcodeScanner: React.FC<BarcodeScannerProps> = ({
  isOpen,
  onClose,
  onScan,
}) => {
  const [status, setStatus] = useState<'loading' | 'scanning' | 'success' | 'error'>('loading');
  const [errorMessage, setErrorMessage] = useState<string>('');
  const [scannedCode, setScannedCode] = useState<string>('');
  const [manualInput, setManualInput] = useState('');
  const [showManual, setShowManual] = useState(false);

  const scannerRef = useRef<Html5Qrcode | null>(null);
  const containerIdRef = useRef(`scanner-${Date.now()}`);

  const stopScanner = useCallback(async () => {
    if (scannerRef.current) {
      try {
        const state = scannerRef.current.getState();
        if (state === 2) { // SCANNING
          await scannerRef.current.stop();
        }
        scannerRef.current.clear();
      } catch (err) {
        console.log('Stop scanner error (safe to ignore):', err);
      }
      scannerRef.current = null;
    }
  }, []);

  const startScanner = useCallback(async () => {
    setStatus('loading');
    setErrorMessage('');

    // Wait for container to be in DOM
    await new Promise(resolve => setTimeout(resolve, 100));

    const container = document.getElementById(containerIdRef.current);
    if (!container) {
      setStatus('error');
      setErrorMessage('Scanner-Container nicht gefunden');
      return;
    }

    try {
      // Create scanner instance
      scannerRef.current = new Html5Qrcode(containerIdRef.current, {
        verbose: false,
      });

      // Get cameras
      const cameras = await Html5Qrcode.getCameras();

      if (!cameras || cameras.length === 0) {
        throw new Error('Keine Kamera gefunden');
      }

      // Prefer back camera
      const backCamera = cameras.find(c =>
        c.label.toLowerCase().includes('back') ||
        c.label.toLowerCase().includes('rear') ||
        c.label.toLowerCase().includes('environment')
      ) || cameras[cameras.length - 1]; // Last camera is usually back on mobile

      // Start scanning
      await scannerRef.current.start(
        backCamera.id,
        {
          fps: 10,
          qrbox: { width: 280, height: 150 },
        },
        (decodedText) => {
          // Success!
          console.log('Barcode scanned:', decodedText);
          setScannedCode(decodedText);
          setStatus('success');

          // Vibrate on success
          if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
          }

          // Stop scanner and return result after short delay
          setTimeout(() => {
            stopScanner();
            onScan(decodedText);
            onClose();
          }, 1000);
        },
        () => {
          // Error callback - ignore, just means no barcode in view
        }
      );

      setStatus('scanning');

    } catch (err: any) {
      console.error('Scanner error:', err);
      setStatus('error');

      if (err.message?.includes('Permission denied') || err.name === 'NotAllowedError') {
        setErrorMessage('Kamera-Zugriff verweigert. Bitte erlauben Sie den Zugriff in den Browser-Einstellungen.');
      } else if (err.message?.includes('Keine Kamera')) {
        setErrorMessage('Keine Kamera gefunden. Bitte stellen Sie sicher, dass Ihr Gerät eine Kamera hat.');
      } else if (err.message?.includes('NotReadableError') || err.message?.includes('in use')) {
        setErrorMessage('Kamera wird bereits verwendet. Bitte schließen Sie andere Apps, die die Kamera nutzen.');
      } else {
        setErrorMessage(err.message || 'Kamera konnte nicht gestartet werden');
      }
    }
  }, [onScan, onClose, stopScanner]);

  useEffect(() => {
    if (isOpen) {
      startScanner();
    }

    return () => {
      stopScanner();
    };
  }, [isOpen, startScanner, stopScanner]);

  const handleManualSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (manualInput.trim()) {
      stopScanner();
      onScan(manualInput.trim());
      onClose();
    }
  };

  const handleClose = () => {
    stopScanner();
    onClose();
  };

  const handleRetry = () => {
    setShowManual(false);
    startScanner();
  };

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 bg-black flex flex-col"
      >
        {/* Header */}
        <div className="flex items-center justify-between p-4 bg-black/80">
          <h2 className="text-white font-semibold text-lg">
            {showManual ? 'Manuelle Eingabe' : 'Barcode scannen'}
          </h2>
          <button
            onClick={handleClose}
            className="p-2 bg-white/20 rounded-full hover:bg-white/30 transition-colors"
          >
            <X className="w-6 h-6 text-white" />
          </button>
        </div>

        {/* Main content */}
        <div className="flex-1 relative">
          {showManual ? (
            // Manual input form
            <div className="absolute inset-0 flex items-center justify-center p-6">
              <form onSubmit={handleManualSubmit} className="w-full max-w-sm space-y-4">
                <div>
                  <label className="block text-white text-sm mb-2">
                    Barcode-Nummer eingeben:
                  </label>
                  <input
                    type="text"
                    value={manualInput}
                    onChange={(e) => setManualInput(e.target.value)}
                    placeholder="z.B. 4012345678901"
                    autoFocus
                    className="w-full px-4 py-3 bg-gray-800 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500"
                  />
                </div>
                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={() => setShowManual(false)}
                    className="flex-1 px-4 py-3 bg-gray-700 text-white rounded-lg hover:bg-gray-600"
                  >
                    Zurück zum Scanner
                  </button>
                  <button
                    type="submit"
                    disabled={!manualInput.trim()}
                    className="flex-1 px-4 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50"
                  >
                    Bestätigen
                  </button>
                </div>
              </form>
            </div>
          ) : (
            <>
              {/* Scanner container */}
              <div
                id={containerIdRef.current}
                className="w-full h-full"
              />

              {/* Overlay states */}
              {status === 'loading' && (
                <div className="absolute inset-0 flex items-center justify-center bg-black/80">
                  <div className="text-center text-white">
                    <Camera className="w-12 h-12 mx-auto mb-4 animate-pulse" />
                    <p>Kamera wird gestartet...</p>
                  </div>
                </div>
              )}

              {status === 'success' && (
                <div className="absolute inset-0 flex items-center justify-center bg-black/80">
                  <motion.div
                    initial={{ scale: 0.8, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    className="text-center text-white"
                  >
                    <CheckCircle className="w-16 h-16 mx-auto mb-4 text-green-400" />
                    <p className="text-xl font-semibold mb-2">Erfolgreich!</p>
                    <p className="text-gray-300 font-mono">{scannedCode}</p>
                  </motion.div>
                </div>
              )}

              {status === 'error' && (
                <div className="absolute inset-0 flex items-center justify-center bg-black/90 p-6">
                  <div className="text-center text-white max-w-sm">
                    <AlertCircle className="w-12 h-12 mx-auto mb-4 text-red-400" />
                    <p className="mb-6 text-gray-300">{errorMessage}</p>
                    <div className="flex flex-col gap-3">
                      <button
                        onClick={handleRetry}
                        className="px-6 py-3 bg-purple-600 rounded-lg hover:bg-purple-700"
                      >
                        Erneut versuchen
                      </button>
                      <button
                        onClick={() => setShowManual(true)}
                        className="px-6 py-3 bg-gray-700 rounded-lg hover:bg-gray-600"
                      >
                        Manuell eingeben
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* Scanning frame overlay */}
              {status === 'scanning' && (
                <div className="absolute inset-0 pointer-events-none flex items-center justify-center">
                  <div className="relative w-72 h-40">
                    {/* Corner markers */}
                    <div className="absolute top-0 left-0 w-8 h-8 border-t-4 border-l-4 border-purple-500 rounded-tl-lg" />
                    <div className="absolute top-0 right-0 w-8 h-8 border-t-4 border-r-4 border-purple-500 rounded-tr-lg" />
                    <div className="absolute bottom-0 left-0 w-8 h-8 border-b-4 border-l-4 border-purple-500 rounded-bl-lg" />
                    <div className="absolute bottom-0 right-0 w-8 h-8 border-b-4 border-r-4 border-purple-500 rounded-br-lg" />

                    {/* Scanning line */}
                    <motion.div
                      className="absolute left-4 right-4 h-0.5 bg-purple-500"
                      animate={{ top: ['10%', '90%', '10%'] }}
                      transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
                    />
                  </div>
                </div>
              )}
            </>
          )}
        </div>

        {/* Footer */}
        {!showManual && status === 'scanning' && (
          <div className="p-6 bg-black/80">
            <p className="text-center text-gray-300 text-sm mb-4">
              Halten Sie den Barcode in den Rahmen
            </p>
            <button
              onClick={() => setShowManual(true)}
              className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-gray-800 text-white rounded-lg hover:bg-gray-700"
            >
              <Keyboard className="w-5 h-5" />
              Manuell eingeben
            </button>
          </div>
        )}
      </motion.div>
    </AnimatePresence>
  );
};

export default BarcodeScanner;
