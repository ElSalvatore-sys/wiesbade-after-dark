import { useState, useEffect } from 'react';
import { cn } from '../lib/utils';
import { X, Calendar, Clock, Users, Euro, Sparkles } from 'lucide-react';
import { AIImageGenerator } from './AIImageGenerator';
import { PhotoUpload } from './ui';
import type { Event } from '../types';

interface EventModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (event: Partial<Event>) => void;
  event?: Event | null;
}

const pointsMultipliers = [
  { value: 1, label: '1x Points' },
  { value: 1.5, label: '1.5x Points' },
  { value: 2, label: '2x Points' },
];

export function EventModal({ isOpen, onClose, onSave, event }: EventModalProps) {
  const [isAIGeneratorOpen, setIsAIGeneratorOpen] = useState(false);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    date: '',
    startTime: '',
    endTime: '',
    ticketPrice: '',
    maxCapacity: '',
    pointsMultiplier: 1,
    category: 'party' as Event['category'],
  });

  useEffect(() => {
    if (event) {
      setFormData({
        title: event.title,
        description: event.description,
        date: event.startDate.split('T')[0],
        startTime: event.startDate.split('T')[1]?.slice(0, 5) || '',
        endTime: event.endDate.split('T')[1]?.slice(0, 5) || '',
        ticketPrice: event.ticketPrice?.toString() || '',
        maxCapacity: event.maxCapacity?.toString() || '',
        pointsMultiplier: 1,
        category: event.category,
      });
      setImagePreview(event.imageUrl || null);
    } else {
      setFormData({
        title: '',
        description: '',
        date: '',
        startTime: '',
        endTime: '',
        ticketPrice: '',
        maxCapacity: '',
        pointsMultiplier: 1,
        category: 'party',
      });
      setImagePreview(null);
    }
  }, [event, isOpen]);

  const handleAIImageGenerated = (imageUrl: string) => {
    setImagePreview(imageUrl);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      title: formData.title,
      description: formData.description,
      startDate: `${formData.date}T${formData.startTime}`,
      endDate: `${formData.date}T${formData.endTime}`,
      ticketPrice: formData.ticketPrice ? parseFloat(formData.ticketPrice) : undefined,
      maxCapacity: formData.maxCapacity ? parseInt(formData.maxCapacity) : undefined,
      category: formData.category,
      imageUrl: imagePreview || undefined,
    });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative w-full max-w-lg glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
          {/* Header */}
          <div className="flex items-center justify-between p-5 border-b border-white/5">
            <h2 className="text-xl font-bold text-foreground">
              {event ? 'Edit Event' : 'Create Event'}
            </h2>
            <button
              onClick={onClose}
              className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
            >
              <X size={20} />
            </button>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-5 space-y-5">
            {/* Image Upload Area */}
            <div className="space-y-3">
              <label className="block text-sm font-medium text-foreground-secondary">
                Event Image
              </label>

              {/* Photo Upload Component */}
              <div className="flex justify-center">
                <PhotoUpload
                  currentPhotoUrl={imagePreview}
                  onUpload={(url) => setImagePreview(url)}
                  onRemove={() => setImagePreview(null)}
                  bucket="photos"
                  folder="events"
                  size="lg"
                  shape="square"
                  label="Event-Bild hochladen"
                />
              </div>

              {/* AI Generate Button */}
              <button
                type="button"
                onClick={() => setIsAIGeneratorOpen(true)}
                className="w-full flex items-center justify-center gap-2 py-3 rounded-xl bg-gradient-to-r from-accent-purple/20 to-accent-pink/20 border border-accent-purple/30 text-accent-purple hover:from-accent-purple/30 hover:to-accent-pink/30 transition-all"
              >
                <Sparkles size={18} />
                <span className="font-medium">Mit AI generieren</span>
              </button>
            </div>

            {/* Title */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Event Title *
              </label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                placeholder="e.g., DJ Night with Felix Jaehn"
                required
                className="input-field"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Description
              </label>
              <textarea
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                placeholder="Describe your event..."
                rows={3}
                className="input-field resize-none"
              />
            </div>

            {/* Date & Time */}
            <div className="grid grid-cols-3 gap-3">
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  <Calendar size={14} className="inline mr-1" />
                  Date *
                </label>
                <input
                  type="date"
                  value={formData.date}
                  onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                  required
                  className="input-field"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  <Clock size={14} className="inline mr-1" />
                  Start *
                </label>
                <input
                  type="time"
                  value={formData.startTime}
                  onChange={(e) => setFormData({ ...formData, startTime: e.target.value })}
                  required
                  className="input-field"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  <Clock size={14} className="inline mr-1" />
                  End *
                </label>
                <input
                  type="time"
                  value={formData.endTime}
                  onChange={(e) => setFormData({ ...formData, endTime: e.target.value })}
                  required
                  className="input-field"
                />
              </div>
            </div>

            {/* Price & Capacity */}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  <Euro size={14} className="inline mr-1" />
                  Ticket Price
                </label>
                <input
                  type="number"
                  step="0.01"
                  value={formData.ticketPrice}
                  onChange={(e) => setFormData({ ...formData, ticketPrice: e.target.value })}
                  placeholder="0.00"
                  className="input-field"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground-secondary mb-2">
                  <Users size={14} className="inline mr-1" />
                  Max Capacity
                </label>
                <input
                  type="number"
                  value={formData.maxCapacity}
                  onChange={(e) => setFormData({ ...formData, maxCapacity: e.target.value })}
                  placeholder="Unlimited"
                  className="input-field"
                />
              </div>
            </div>

            {/* Category */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                Category
              </label>
              <div className="flex flex-wrap gap-2">
                {(['music', 'party', 'special', 'private', 'promotion'] as const).map((cat) => (
                  <button
                    key={cat}
                    type="button"
                    onClick={() => setFormData({ ...formData, category: cat })}
                    className={cn(
                      'px-4 py-2 rounded-lg text-sm font-medium capitalize transition-all',
                      formData.category === cat
                        ? 'bg-gradient-primary text-white shadow-glow-sm'
                        : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                    )}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Points Multiplier */}
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-2">
                <Sparkles size={14} className="inline mr-1 text-accent-purple" />
                Points Multiplier
              </label>
              <div className="flex gap-2">
                {pointsMultipliers.map((mult) => (
                  <button
                    key={mult.value}
                    type="button"
                    onClick={() => setFormData({ ...formData, pointsMultiplier: mult.value })}
                    className={cn(
                      'flex-1 py-2 rounded-lg text-sm font-medium transition-all',
                      formData.pointsMultiplier === mult.value
                        ? 'bg-accent-purple/20 text-accent-purple border border-accent-purple/30'
                        : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                    )}
                  >
                    {mult.label}
                  </button>
                ))}
              </div>
            </div>
          </form>

          {/* Footer */}
          <div className="flex gap-3 p-5 border-t border-white/5">
            <button
              type="button"
              onClick={onClose}
              className="btn-secondary flex-1"
            >
              Cancel
            </button>
            <button
              type="submit"
              onClick={handleSubmit}
              className="btn-primary flex-1"
            >
              {event ? 'Save Changes' : 'Create Event'}
            </button>
          </div>
        </div>
      </div>

      {/* AI Image Generator Modal */}
      <AIImageGenerator
        isOpen={isAIGeneratorOpen}
        onClose={() => setIsAIGeneratorOpen(false)}
        onImageGenerated={handleAIImageGenerated}
      />
    </>
  );
}
