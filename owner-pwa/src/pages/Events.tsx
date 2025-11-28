import { useState } from 'react';
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
} from 'lucide-react';
import { EventModal } from '../components/EventModal';
import type { Event } from '../types';

// Mock events data
const mockEvents: Event[] = [
  {
    id: '1',
    venueId: '1',
    title: 'DJ Night with Felix Jaehn',
    description: 'An amazing night with one of the best DJs',
    imageUrl: undefined,
    startDate: '2024-12-15T22:00:00',
    endDate: '2024-12-16T04:00:00',
    ticketPrice: 25,
    maxCapacity: 200,
    currentAttendees: 145,
    category: 'music',
    isActive: true,
    isFeatured: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    venueId: '1',
    title: 'New Year\'s Eve Party 2025',
    description: 'The biggest party of the year',
    imageUrl: undefined,
    startDate: '2024-12-31T21:00:00',
    endDate: '2025-01-01T06:00:00',
    ticketPrice: 50,
    maxCapacity: 300,
    currentAttendees: 278,
    category: 'special',
    isActive: true,
    isFeatured: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    venueId: '1',
    title: 'Ladies Night',
    description: 'Free entry and drink specials for ladies',
    imageUrl: undefined,
    startDate: '2024-12-20T20:00:00',
    endDate: '2024-12-21T02:00:00',
    ticketPrice: 0,
    maxCapacity: 150,
    currentAttendees: 45,
    category: 'promotion',
    isActive: true,
    isFeatured: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

type EventStatus = 'all' | 'upcoming' | 'live' | 'past';

export function Events() {
  const [events] = useState<Event[]>(mockEvents);
  const [filter, setFilter] = useState<EventStatus>('all');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState<Event | null>(null);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

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

  const handleSaveEvent = (eventData: Partial<Event>) => {
    console.log('Saving event:', eventData);
    // In production, this would call the API
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

      {/* Events Grid */}
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
                          <button className="w-full flex items-center gap-2 px-3 py-2 text-sm text-error hover:bg-error/10">
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

      {filteredEvents.length === 0 && (
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
