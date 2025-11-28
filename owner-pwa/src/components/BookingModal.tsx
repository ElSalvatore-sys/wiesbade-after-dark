import { useState, useEffect } from 'react';
import { cn } from '../lib/utils';
import { X, User, Phone, Mail, Calendar, Clock, Users, MessageSquare, Send } from 'lucide-react';
import type { Booking, BookingStatus } from '../types';

interface BookingModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (booking: Partial<Booking>) => void;
  booking: Booking | null;
}

const statusOptions: { value: BookingStatus; label: string; color: string }[] = [
  { value: 'pending', label: 'Pending', color: 'bg-warning/20 text-warning' },
  { value: 'confirmed', label: 'Confirmed', color: 'bg-success/20 text-success' },
  { value: 'cancelled', label: 'Cancelled', color: 'bg-error/20 text-error' },
  { value: 'completed', label: 'Completed', color: 'bg-accent-cyan/20 text-accent-cyan' },
  { value: 'no_show', label: 'No Show', color: 'bg-foreground-dim/20 text-foreground-dim' },
];

export function BookingModal({ isOpen, onClose, onSave, booking }: BookingModalProps) {
  const [status, setStatus] = useState<BookingStatus>('pending');
  const [notes, setNotes] = useState('');

  useEffect(() => {
    if (booking) {
      setStatus(booking.status);
      setNotes(booking.notes || '');
    }
  }, [booking, isOpen]);

  const handleSave = () => {
    if (booking) {
      onSave({ ...booking, status, notes });
    }
    onClose();
  };

  if (!isOpen || !booking) return null;

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('de-DE', {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-md glass-card p-0 animate-scale-in max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/5">
          <h2 className="text-xl font-bold text-foreground">Booking Details</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-5 space-y-5">
          {/* Guest Info */}
          <div className="space-y-3">
            <h3 className="text-sm font-medium text-foreground-secondary uppercase tracking-wider">
              Guest Information
            </h3>
            <div className="space-y-2">
              <div className="flex items-center gap-3 p-3 rounded-xl bg-card">
                <User size={18} className="text-foreground-muted" />
                <div>
                  <p className="text-sm text-foreground-muted">Name</p>
                  <p className="font-medium text-foreground">{booking.userName}</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 rounded-xl bg-card">
                <Phone size={18} className="text-foreground-muted" />
                <div>
                  <p className="text-sm text-foreground-muted">Phone</p>
                  <p className="font-medium text-foreground">{booking.userPhone}</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 rounded-xl bg-card">
                <Mail size={18} className="text-foreground-muted" />
                <div>
                  <p className="text-sm text-foreground-muted">Email</p>
                  <p className="font-medium text-foreground">{booking.userEmail}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Booking Info */}
          <div className="space-y-3">
            <h3 className="text-sm font-medium text-foreground-secondary uppercase tracking-wider">
              Reservation Details
            </h3>
            <div className="grid grid-cols-2 gap-2">
              <div className="p-3 rounded-xl bg-card">
                <div className="flex items-center gap-2 text-foreground-muted mb-1">
                  <Calendar size={14} />
                  <span className="text-xs">Date</span>
                </div>
                <p className="font-medium text-foreground text-sm">
                  {formatDate(booking.date)}
                </p>
              </div>
              <div className="p-3 rounded-xl bg-card">
                <div className="flex items-center gap-2 text-foreground-muted mb-1">
                  <Clock size={14} />
                  <span className="text-xs">Time</span>
                </div>
                <p className="font-medium text-foreground text-sm">{booking.time}</p>
              </div>
              <div className="p-3 rounded-xl bg-card">
                <div className="flex items-center gap-2 text-foreground-muted mb-1">
                  <Users size={14} />
                  <span className="text-xs">Party Size</span>
                </div>
                <p className="font-medium text-foreground text-sm">
                  {booking.partySize} guests
                </p>
              </div>
              <div className="p-3 rounded-xl bg-card">
                <div className="flex items-center gap-2 text-foreground-muted mb-1">
                  <span className="text-xs">Table</span>
                </div>
                <p className="font-medium text-foreground text-sm">
                  {booking.tableNumber || 'Not assigned'}
                </p>
              </div>
            </div>
          </div>

          {/* Status */}
          <div className="space-y-3">
            <h3 className="text-sm font-medium text-foreground-secondary uppercase tracking-wider">
              Status
            </h3>
            <div className="flex flex-wrap gap-2">
              {statusOptions.map((option) => (
                <button
                  key={option.value}
                  onClick={() => setStatus(option.value)}
                  className={cn(
                    'px-3 py-1.5 rounded-lg text-sm font-medium transition-all',
                    status === option.value
                      ? `${option.color} ring-2 ring-offset-2 ring-offset-background`
                      : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
                  )}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>

          {/* Notes */}
          <div className="space-y-3">
            <h3 className="text-sm font-medium text-foreground-secondary uppercase tracking-wider">
              <MessageSquare size={14} className="inline mr-1" />
              Notes & Special Requests
            </h3>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Add notes about this booking..."
              rows={3}
              className="input-field resize-none"
            />
          </div>

          {/* Contact Guest */}
          <button className="w-full btn-secondary flex items-center justify-center gap-2">
            <Send size={16} />
            Contact Guest
          </button>
        </div>

        {/* Footer */}
        <div className="flex gap-3 p-5 border-t border-white/5">
          <button onClick={onClose} className="btn-secondary flex-1">
            Cancel
          </button>
          <button onClick={handleSave} className="btn-primary flex-1">
            Save Changes
          </button>
        </div>
      </div>
    </div>
  );
}
