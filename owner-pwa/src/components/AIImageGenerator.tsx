import { useState } from 'react';
import { X, Sparkles, Loader2, Wand2 } from 'lucide-react';
import { cn } from '../lib/utils';

interface AIImageGeneratorProps {
  isOpen: boolean;
  onClose: () => void;
  onImageGenerated: (imageUrl: string) => void;
}

type StylePreset = 'nightclub' | 'restaurant' | 'elegant' | 'neon' | 'vintage';

const stylePresets: { value: StylePreset; label: string; unsplashQuery: string }[] = [
  { value: 'nightclub', label: 'Nightclub', unsplashQuery: 'nightclub-party-crowd' },
  { value: 'restaurant', label: 'Restaurant', unsplashQuery: 'restaurant-dining-ambiance' },
  { value: 'elegant', label: 'Elegant', unsplashQuery: 'elegant-luxury-event' },
  { value: 'neon', label: 'Neon', unsplashQuery: 'neon-lights-club' },
  { value: 'vintage', label: 'Vintage', unsplashQuery: 'vintage-bar-retro' },
];

// Unsplash image IDs for each style (using specific high-quality images)
const styleImages: Record<StylePreset, string[]> = {
  nightclub: [
    'https://images.unsplash.com/photo-1545128485-c400e7702796?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1571266028243-d220c6a34d73?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=450&fit=crop',
  ],
  restaurant: [
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&h=450&fit=crop',
  ],
  elegant: [
    'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&h=450&fit=crop',
  ],
  neon: [
    'https://images.unsplash.com/photo-1557683316-973673baf926?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800&h=450&fit=crop',
  ],
  vintage: [
    'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1525268323446-0505b6fe7778?w=800&h=450&fit=crop',
    'https://images.unsplash.com/photo-1543007630-9710e4a00a20?w=800&h=450&fit=crop',
  ],
};

export function AIImageGenerator({ isOpen, onClose, onImageGenerated }: AIImageGeneratorProps) {
  const [prompt, setPrompt] = useState('');
  const [selectedStyle, setSelectedStyle] = useState<StylePreset>('nightclub');
  const [isGenerating, setIsGenerating] = useState(false);
  const [generatedImage, setGeneratedImage] = useState<string | null>(null);

  const handleGenerate = async () => {
    setIsGenerating(true);
    setGeneratedImage(null);

    // Simulate AI generation delay
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // Pick a random image from the selected style
    const images = styleImages[selectedStyle];
    const randomImage = images[Math.floor(Math.random() * images.length)];

    setGeneratedImage(randomImage);
    setIsGenerating(false);
  };

  const handleUseImage = () => {
    if (generatedImage) {
      onImageGenerated(generatedImage);
      handleClose();
    }
  };

  const handleClose = () => {
    setPrompt('');
    setGeneratedImage(null);
    setIsGenerating(false);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/70 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-lg glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <div className="flex items-center gap-2">
            <div className="p-2 rounded-lg bg-gradient-primary">
              <Sparkles size={18} className="text-white" />
            </div>
            <h2 className="text-xl font-bold text-foreground">AI Image Generator</h2>
          </div>
          <button
            onClick={handleClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-5">
          {/* Preview Area */}
          <div className="relative aspect-video rounded-xl bg-card border border-border overflow-hidden">
            {isGenerating ? (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3">
                <div className="relative">
                  <Loader2 size={40} className="text-primary-400 animate-spin" />
                  <Sparkles size={16} className="absolute -top-1 -right-1 text-accent-pink animate-pulse" />
                </div>
                <p className="text-sm text-foreground-muted">Generating your image...</p>
                <p className="text-xs text-foreground-dim">This may take a moment</p>
              </div>
            ) : generatedImage ? (
              <img
                src={generatedImage}
                alt="Generated"
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-2">
                <Wand2 size={32} className="text-foreground-dim" />
                <p className="text-sm text-foreground-muted">Your generated image will appear here</p>
              </div>
            )}
          </div>

          {/* Prompt Input */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Describe your event image
            </label>
            <textarea
              value={prompt}
              onChange={(e) => setPrompt(e.target.value)}
              placeholder="e.g., Friday night DJ party with neon lights and dancing crowd"
              rows={3}
              className="input-field resize-none"
            />
          </div>

          {/* Style Presets */}
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-2">
              Style Preset
            </label>
            <div className="flex flex-wrap gap-2">
              {stylePresets.map((style) => (
                <button
                  key={style.value}
                  type="button"
                  onClick={() => setSelectedStyle(style.value)}
                  className={cn(
                    'px-4 py-2 rounded-lg text-sm font-medium transition-all',
                    selectedStyle === style.value
                      ? 'bg-gradient-primary text-white shadow-glow-sm'
                      : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                  )}
                >
                  {style.label}
                </button>
              ))}
            </div>
          </div>

          {/* Info Note */}
          <div className="p-3 rounded-lg bg-accent-purple/10 border border-accent-purple/20">
            <p className="text-xs text-accent-purple">
              <Sparkles size={12} className="inline mr-1" />
              Currently using placeholder images. Connect to DALL-E or Midjourney API for real AI generation.
            </p>
          </div>
        </div>

        {/* Footer */}
        <div className="flex gap-3 p-5 border-t border-white/5">
          <button
            type="button"
            onClick={handleClose}
            className="btn-secondary flex-1"
          >
            Cancel
          </button>
          {generatedImage ? (
            <button
              type="button"
              onClick={handleUseImage}
              className="btn-primary flex-1"
            >
              Use This Image
            </button>
          ) : (
            <button
              type="button"
              onClick={handleGenerate}
              disabled={isGenerating}
              className="btn-primary flex-1 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isGenerating ? (
                <>
                  <Loader2 size={18} className="animate-spin mr-2" />
                  Generating...
                </>
              ) : (
                <>
                  <Sparkles size={18} className="mr-2" />
                  Generate Image
                </>
              )}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
