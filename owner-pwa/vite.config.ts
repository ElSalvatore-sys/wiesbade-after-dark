import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    // Optimize chunk splitting
    rollupOptions: {
      output: {
        manualChunks: {
          // Vendor chunks
          'react-vendor': ['react', 'react-dom'],
          'lucide': ['lucide-react'],
          'scanner': ['html5-qrcode'],
        },
      },
    },
    // Increase chunk size warning limit (PWA assets add size)
    chunkSizeWarningLimit: 700,
    // Enable source maps for production debugging (optional)
    sourcemap: false,
    // Minification settings
    minify: 'esbuild',
    // Target modern browsers for smaller bundle
    target: 'es2020',
  },
  // PWA-related settings
  server: {
    // Enable HTTPS for testing push notifications locally (optional)
    // https: true,
  },
  // Preview server settings
  preview: {
    port: 4173,
  },
})
