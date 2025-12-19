import { useState, useEffect, useCallback } from 'react';
import { cn } from '../lib/utils';
import {
  Plus,
  Calendar,
  Clock,
  Users,
  Euro,
  MoreVertical,
  Edit,
  Trash2,
  Eye,
  Loader2,
  AlertCircle,
  RefreshCw,
} from 'lucide-react';
import { EventModal } from '../components/EventModal';
import { api } from '../services/api';
import type { Event, EventCategory } from '../types';

// Transform backend event to frontend format
interface BackendEvent {
  id: string;
  venue_id: string;
  venue_name?: string;
  title: string;
  description?: string;
  event_type: string;
  image_url?: string;
  start_time: string;
  end_time: string;
  max_capacity?: number;
  current_rsvp_count: number;
  ticket_price: number;
  is_free: boolean;
  attendance_points: number;
  bonus_points_multiplier: number;
  status: string;
  is_featured: boolean;
  created_at: string;
  updated_at?: string;
}

const mapEventTypeToCategory = (eventType: string): EventCategory => {
  const typeMap: Record<string, EventCategory> = {
    'concert': 'music',
    'music': 'music',
    'dj': 'music',
    'party': 'party',
    'special_offer': 'promotion',
    'promotion': 'promotion',
    'special': 'special',
    'private': 'private',
  };
  return typeMap[eventType.toLowerCase()] || 'party';
};

const transformEvent = (backendEvent: BackendEvent): Event => ({
  id: backendEvent.id,
  venueId: backendEvent.venue_id,
  title: backendEvent.title,
  description: backendEvent.description || '',
  imageUrl: backendEvent.image_url,
  startDate: backendEvent.start_time,
  endDate: backendEvent.end_time,
  ticketPrice: backendEvent.ticket_price,
  maxCapacity: backendEvent.max_capacity,
  currentAttendees: backendEvent.current_rsvp_count,
  category: mapEventTypeToCategory(backendEvent.event_type),
  isActive: backendEvent.status !== 'cancelled',
  isFeatured: backendEvent.is_featured,
  createdAt: backendEvent.created_at,
  updatedAt: backendEvent.updated_at || backendEvent.created_at,
});

type EventStatus = 'all' | 'upcoming' | 'live' | 'past';

export function Events() {
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<EventStatus>('all');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  // Fetch events from API
  const fetchEvents = useCallback(async () => {
    setLoading(true);
    setError(null);

    const result = await api.getVenueEvents({ include_past: true, limit: 100 });

    if (result.error) {
      setError(result.error);
      setEvents([]);
    } else if (result.data) {
      const transformedEvents = (result.data.events as BackendEvent[]).map(transformEvent);
      setEvents(transformedEvents);
    }

    setLoading(false);
  }, []);

  useEffect(() => {
    fetchEvents();
  }, [fetchEvents]);

  const getEventStatus = (event: Event): 'upcoming' | 'live' | 'past' => {
    const now = new Date();
    const start = new Date(event.startDate);
    const end = new Date(event.endDate);

    if (now < start) return 'upcoming';
    if (now >= start && now <= end) return 'live';
    return 'past';
  };

  const filteredEvents = events.filter((event) => {
    if (filter === 'all') return true;
    return getEventStatus(event) === filter;
  });

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('de-DE', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
    });
  };

  const formatTime = (dateStr: string) => {
    return new Date(dateStr).toLocaleTimeString('de-DE', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const handleCreateEvent = () => {
    setSelectedEvent(null);
    setIsModalOpen(true);
  };

  const handleEditEvent = (event: Event) => {
    setSelectedEvent(event);
    setIsModalOpen(true);
    setMenuOpen(null);
  };

  const handleDeleteEvent = async (eventId: string) => {
    if (!confirm('Are you sure you want to delete this event?')) return;

    const result = await api.deleteEvent(eventId);
    if (result.error) {
      alert(`Failed to delete event: ${result.error}`);
    } else {
      // Refresh events list
      fetchEvents();
    }
    setMenuOpen(null);
  };

  const mapCategoryToEventType = (category: string): string => {
    const categoryMap: Record<string, string> = {
      'music': 'concert',
      'party': 'party',
      'special': 'special',
      'private': 'private',
      'promotion': 'special_offer',
    };
    return categoryMap[category] || 'party';
  };

  const handleSaveEvent = async (eventData: Partial<Event>) => {
    if (selectedEvent) {
      // Update existing event
      const result = await api.updateEvent(selectedEvent.id, {
        title: eventData.title,
        description: eventData.description,
        event_type: eventData.category ? mapCategoryToEventType(eventData.category) : undefined,
        image_url: eventData.imageUrl,
        start_time: eventData.startDate,
        end_time: eventData.endDate,
        max_capacity: eventData.maxCapacity,
        ticket_price: eventData.ticketPrice,
        is_free: eventData.ticketPrice === 0 || eventData.ticketPrice === undefined,
        is_featured: eventData.isFeatured,
      });

      if (result.error) {
        alert(`Failed to update event: ${result.error}`);
        return;
      }
    } else {
      // Create new event
      const result = await api.createEvent({
        title: eventData.title || 'Untitled Event',
        description: eventData.description,
        event_type: eventData.category ? mapCategoryToEventType(eventData.category) : 'party',
        image_url: eventData.imageUrl,
        start_time: eventData.startDate || new Date().toISOString(),
        end_time: eventData.endDate || new Date().toISOString(),
        max_capacity: eventData.maxCapacity,
        ticket_price: eventData.ticketPrice || 0,
        is_free: !eventData.ticketPrice || eventData.ticketPrice === 0,
        is_featured: eventData.isFeatured || false,
      });

      if (result.error) {
        alert(`Failed to create event: ${result.error}`);
        return;
      }
    }

    // Refresh events list and close modal
    setIsModalOpen(false);
    fetchEvents();
  };

  const statusColors = {
    upcoming: 'bg-accent-cyan/20 text-accent-cyan border-accent-cyan/30',
    live: 'bg-success/20 text-success border-success/30',
    past: 'bg-foreground-dim/20 text-foreground-dim border-foreground-dim/30',
  };

  const categoryColors = {
    music: 'bg-accent-purple/20 text-accent-purple',
    party: 'bg-accent-pink/20 text-accent-pink',
    special: 'bg-warning/20 text-warning',
    private: 'bg-info/20 text-info',
    promotion: 'bg-success/20 text-success',
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Events</h1>
          <p className="text-foreground-secondary mt-1">
            Manage your venue's events and promotions
          </p>
        </div>
        <button onClick={handleCreateEvent} className="btn-primary flex items-center gap-2">
          <Plus size={20} />
          Create Event
        </button>
      </div>

      {/* Filters */}
      <div className="flex gap-2 overflow-x-auto no-scrollbar pb-2">
        {(['all', 'upcoming', 'live', 'past'] as const).map((status) => (
          <button
            key={status}
            onClick={() => setFilter(status)}
            className={cn(
              'px-4 py-2 rounded-xl text-sm font-medium capitalize whitespace-nowrap transition-all',
              filter === status
                ? 'bg-gradient-primary text-white shadow-glow-sm'
                : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
            )}
          >
            {status === 'all' ? 'All Events' : status}
            {status !== 'all' && (
              <span className="ml-2 px-1.5 py-0.5 rounded-full text-xs bg-white/10">
                {events.filter((e) => getEventStatus(e) === status).length}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Loading State */}
      {loading && (
        <div className="flex items-center justify-center py-12">
          <Loader2 className="w-8 h-8 animate-spin text-accent-purple" />
        </div>
      )}

      {/* Error State */}
      {error && !loading && (
        <div className="glass-card p-6 text-center">
          <AlertCircle className="w-12 h-12 mx-auto mb-4 text-error" />
          <h3 className="text-lg font-semibold text-foreground mb-2">Failed to load events</h3>
          <p className="text-foreground-muted mb-4">{error}</p>
          <button
            onClick={fetchEvents}
            className="btn-primary inline-flex items-center gap-2"
          >
            <RefreshCw size={16} />
            Try Again
          </button>
        </div>
      )}

      {/* Events Grid */}
      {!loading && !error && (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredEvents.map((event) => {
          const status = getEventStatus(event);
          const capacityPercent = event.maxCapacity
            ? (event.currentAttendees / event.maxCapacity) * 100
            : 0;

          return (
            <div
              key={event.id}
              className="group relative glass-card p-0 overflow-hidden hover:shadow-card-hover transition-all duration-300"
            >
              {/* Image placeholder */}
              <div className="relative aspect-video bg-gradient-to-br from-accent-purple/20 to-accent-pink/20">
                <div className="absolute inset-0 flex items-center justify-center">
                  <Calendar size={40} className="text-foreground-dim" />
                </div>
                {/* Status badge */}
                <div className="absolute top-3 left-3">
                  <span className={cn('badge border', statusColors[status])}>
                    {status === 'live' && (
                      <span className="w-2 h-2 rounded-full bg-success mr-1.5 animate-pulse" />
                    )}
                    {status.charAt(0).toUpperCase() + status.slice(1)}
                  </span>
                </div>
                {/* Category badge */}
                <div className="absolute top-3 right-3">
                  <span className={cn('badge capitalize', categoryColors[event.category])}>
                    {event.category}
                  </span>
                </div>
              </div>

              {/* Content */}
              <div className="p-4 space-y-3">
                <div>
                  <h3 className="font-semibold text-foreground line-clamp-1">
                    {event.title}
                  </h3>
                  <p className="text-sm text-foreground-muted line-clamp-2 mt-1">
                    {event.description}
                  </p>
                </div>

                {/* Details */}
                <div className="flex flex-wrap gap-3 text-sm text-foreground-secondary">
                  <div className="flex items-center gap-1.5">
                    <Calendar size={14} />
                    {formatDate(event.startDate)}
                  </div>
                  <div className="flex items-center gap-1.5">
                    <Clock size={14} />
                    {formatTime(event.startDate)}
                  </div>
                  {event.ticketPrice !== undefined && event.ticketPrice > 0 && (
                    <div className="flex items-center gap-1.5">
                      <Euro size={14} />
                      {event.ticketPrice}
                    </div>
                  )}
                </div>

                {/* Capacity bar */}
                {event.maxCapacity && (
                  <div>
                    <div className="flex items-center justify-between text-xs mb-1.5">
                      <span className="text-foreground-muted flex items-center gap-1">
                        <Users size={12} />
                        {event.currentAttendees} / {event.maxCapacity}
                      </span>
                      <span className={cn(
                        capacityPercent >= 90 ? 'text-error' :
                        capacityPercent >= 70 ? 'text-warning' : 'text-success'
                      )}>
                        {capacityPercent.toFixed(0)}%
                      </span>
                    </div>
                    <div className="h-1.5 bg-card rounded-full overflow-hidden">
                      <div
                        className={cn(
                          'h-full rounded-full transition-all duration-500',
                          capacityPercent >= 90 ? 'bg-error' :
                          capacityPercent >= 70 ? 'bg-warning' : 'bg-gradient-primary'
                        )}
                        style={{ width: `${Math.min(capacityPercent, 100)}%` }}
                      />
                    </div>
                  </div>
                )}

                {/* Actions */}
                <div className="flex items-center justify-between pt-2 border-t border-white/5">
                  <button className="btn-ghost text-sm flex items-center gap-1.5">
                    <Eye size={14} />
                    Preview
                  </button>
                  <div className="relative">
                    <button
                      onClick={() => setMenuOpen(menuOpen === event.id ? null : event.id)}
                      className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
                    >
                      <MoreVertical size={16} />
                    </button>
                    {menuOpen === event.id && (
                      <>
                        <div
                          className="fixed inset-0 z-10"
                          onClick={() => setMenuOpen(null)}
                        />
                        <div className="absolute right-0 bottom-full mb-2 w-36 glass-card py-1 z-20 animate-fade-in">
                          <button
                            onClick={() => handleEditEvent(event)}
                            className="w-full flex items-center gap-2 px-3 py-2 text-sm text-foreground-secondary hover:text-foreground hover:bg-white/5"
                          >
                            <Edit size={14} />
                            Edit
                          </button>
                          <button
                            onClick={() => handleDeleteEvent(event.id)}
                            className="w-full flex items-center gap-2 px-3 py-2 text-sm text-error hover:bg-error/10"
                          >
                            <Trash2 size={14} />
                            Delete
                          </button>
                        </div>
                      </>
                    )}
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
      )}

      {!loading && !error && filteredEvents.length === 0 && (
        <div className="text-center py-12">
          <Calendar size={48} className="mx-auto text-foreground-dim mb-4" />
          <h3 className="text-lg font-semibold text-foreground">No events found</h3>
          <p className="text-foreground-muted mt-1">
            {filter === 'all' ? 'Create your first event' : `No ${filter} events`}
          </p>
        </div>
      )}

      {/* Event Modal */}
      <EventModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveEvent}
        event={selectedEvent}
      />
    </div>
  );
}
