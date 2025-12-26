import { useState, useEffect, useCallback } from 'react';
import { cn } from '../lib/utils';
import {
  Search,
  Calendar,
  List,
  Users,
  Clock,
  Check,
  X,
  MoreVertical,
  Phone,
  ChevronLeft,
  ChevronRight,
  CalendarDays,
  Loader2,
  AlertCircle,
} from 'lucide-react';
import { BookingModal } from '../components/BookingModal';
import { supabaseApi, sendBookingConfirmation } from '../services/supabaseApi';
import type { VenueBooking as DbBooking } from '../lib/supabase';
import type { Booking, BookingStatus } from '../types';
import { useRealtimeSubscription } from '../hooks/useRealtimeSubscription';

type FilterStatus = 'all' | BookingStatus;
type ViewMode = 'list' | 'calendar';

// Map database booking to UI booking
const mapDbToUi = (db: DbBooking): Booking => ({
  id: db.id,
  venueId: db.venue_id,
  userId: db.user_id || '',
  userName: db.user_name,
  userPhone: db.user_phone,
  userEmail: db.user_email || '',
  date: db.date,
  time: db.time,
  partySize: db.party_size,
  tableNumber: db.table_number || undefined,
  status: db.status as BookingStatus,
  notes: db.notes || undefined,
  createdAt: db.created_at,
  updatedAt: db.updated_at,
});

export function Bookings() {
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [filter, setFilter] = useState<FilterStatus>('all');
  const [viewMode, setViewMode] = useState<ViewMode>('list');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  // Calendar state - use current month
  const [currentDate, setCurrentDate] = useState(new Date());
  const [selectedCalendarDate, setSelectedCalendarDate] = useState<string | null>(null);

  // Fetch bookings from Supabase
  const fetchBookings = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const { data, error } = await supabaseApi.getBookings();
      if (error) throw error;
      setBookings((data || []).map(mapDbToUi));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Laden der Reservierungen');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  // Realtime subscription for live updates
  useRealtimeSubscription({
    subscriptions: [
      { table: 'bookings', event: '*' },
    ],
    onDataChange: fetchBookings,
    enabled: !loading,
    debounceMs: 500,
  });

  const filteredBookings = bookings.filter((booking) => {
    const matchesFilter = filter === 'all' || booking.status === filter;
    const matchesSearch = booking.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      booking.userPhone.includes(searchQuery) ||
      (booking.userEmail && booking.userEmail.toLowerCase().includes(searchQuery.toLowerCase()));
    const matchesCalendarDate = selectedCalendarDate ? booking.date === selectedCalendarDate : true;
    return matchesFilter && matchesSearch && matchesCalendarDate;
  });

  const handleStatusChange = async (bookingId: string, newStatus: BookingStatus) => {
    setSaving(true);
    try {
      const { error } = await supabaseApi.updateBooking(bookingId, { status: newStatus });
      if (error) throw error;

      // Send confirmation/rejection email based on status
      if (newStatus === 'confirmed') {
        const emailResult = await sendBookingConfirmation(bookingId, 'accepted');
        if (!emailResult.success) {
          console.warn('Confirmation email failed:', emailResult.error);
        }
      } else if (newStatus === 'cancelled') {
        const emailResult = await sendBookingConfirmation(bookingId, 'rejected');
        if (!emailResult.success) {
          console.warn('Rejection email failed:', emailResult.error);
        }
      }

      setBookings(bookings.map((b) =>
        b.id === bookingId ? { ...b, status: newStatus } : b
      ));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Aktualisieren des Status');
    } finally {
      setSaving(false);
      setMenuOpen(null);
    }
  };

  const handleSaveBooking = async (updatedBooking: Partial<Booking>) => {
    setSaving(true);
    try {
      if (updatedBooking.id) {
        const { error } = await supabaseApi.updateBooking(updatedBooking.id, {
          user_name: updatedBooking.userName,
          user_phone: updatedBooking.userPhone,
          user_email: updatedBooking.userEmail || null,
          date: updatedBooking.date,
          time: updatedBooking.time,
          party_size: updatedBooking.partySize,
          table_number: updatedBooking.tableNumber || null,
          status: updatedBooking.status,
          notes: updatedBooking.notes || null,
        });
        if (error) throw error;
        await fetchBookings();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Fehler beim Speichern der Reservierung');
    } finally {
      setSaving(false);
    }
  };

  const openBookingDetails = (booking: Booking) => {
    setSelectedBooking(booking);
    setIsModalOpen(true);
  };

  const statusConfig: Record<BookingStatus, { label: string; color: string; bg: string }> = {
    pending: { label: 'Ausstehend', color: 'text-warning', bg: 'bg-warning/20' },
    confirmed: { label: 'Bestätigt', color: 'text-success', bg: 'bg-success/20' },
    cancelled: { label: 'Storniert', color: 'text-error', bg: 'bg-error/20' },
    completed: { label: 'Abgeschlossen', color: 'text-accent-cyan', bg: 'bg-accent-cyan/20' },
    no_show: { label: 'Nicht erschienen', color: 'text-foreground-dim', bg: 'bg-foreground-dim/20' },
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    if (date.toDateString() === today.toDateString()) return 'Heute';
    if (date.toDateString() === tomorrow.toDateString()) return 'Morgen';

    return date.toLocaleDateString('de-DE', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
    });
  };

  const formatSelectedDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const dayName = date.toLocaleDateString('de-DE', { weekday: 'short' });
    const monthDay = date.toLocaleDateString('de-DE', { month: 'short', day: 'numeric' });

    if (date.toDateString() === today.toDateString()) return `Heute - ${monthDay}`;
    if (date.toDateString() === tomorrow.toDateString()) return `Morgen - ${monthDay}`;

    return `${dayName}, ${monthDay}`;
  };

  // Group bookings by date for list view
  const groupedBookings = filteredBookings.reduce((groups, booking) => {
    const date = booking.date;
    if (!groups[date]) groups[date] = [];
    groups[date].push(booking);
    return groups;
  }, {} as Record<string, Booking[]>);

  const sortedDates = Object.keys(groupedBookings).sort();

  // Calendar helpers
  const getDaysInMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
  };

  const getFirstDayOfMonth = (date: Date) => {
    const day = new Date(date.getFullYear(), date.getMonth(), 1).getDay();
    return day === 0 ? 6 : day - 1;
  };

  const getBookingsForDate = (day: number) => {
    const dateStr = `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    return bookings.filter((b) => b.date === dateStr);
  };

  const formatDateStr = (day: number) => {
    return `${currentDate.getFullYear()}-${String(currentDate.getMonth() + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  };

  const goToPreviousMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const goToNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const handleDayClick = (day: number) => {
    const dateStr = formatDateStr(day);
    setSelectedCalendarDate(dateStr);
  };

  const daysInMonth = getDaysInMonth(currentDate);
  const firstDayOfMonth = getFirstDayOfMonth(currentDate);
  const weekDays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  // Get bookings for selected date in calendar view
  const selectedDateBookings = selectedCalendarDate
    ? bookings.filter((b) => {
        const matchesDate = b.date === selectedCalendarDate;
        const matchesFilter = filter === 'all' || b.status === filter;
        const matchesSearch = b.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
          b.userPhone.includes(searchQuery) ||
          (b.userEmail && b.userEmail.toLowerCase().includes(searchQuery.toLowerCase()));
        return matchesDate && matchesFilter && matchesSearch;
      })
    : [];

  // Loading state
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <Loader2 size={40} className="animate-spin text-primary-400 mx-auto mb-4" />
          <p className="text-foreground-secondary">Reservierungen werden geladen...</p>
        </div>
      </div>
    );
  }

  // Error state
  if (error && bookings.length === 0) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <AlertCircle size={40} className="text-error mx-auto mb-4" />
          <p className="text-foreground-secondary">{error}</p>
          <button
            onClick={fetchBookings}
            className="mt-4 px-4 py-2 rounded-lg bg-primary-500 text-white hover:bg-primary-600"
          >
            Erneut versuchen
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Error Toast */}
      {error && (
        <div className="flex items-center gap-2 p-3 rounded-lg bg-error/10 border border-error/20 text-error">
          <AlertCircle size={18} />
          <span className="text-sm">{error}</span>
          <button onClick={() => setError(null)} className="ml-auto">
            <X size={16} />
          </button>
        </div>
      )}

      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Reservierungen</h1>
          <p className="text-foreground-secondary mt-1">
            Tischreservierungen und Gästeanfragen verwalten
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => {
              setViewMode('list');
              setSelectedCalendarDate(null);
            }}
            className={cn(
              'p-2.5 rounded-xl transition-colors',
              viewMode === 'list'
                ? 'bg-gradient-primary text-white shadow-glow-sm'
                : 'bg-card border border-border text-foreground-secondary hover:text-foreground'
            )}
          >
            <List size={18} />
          </button>
          <button
            onClick={() => setViewMode('calendar')}
            className={cn(
              'p-2.5 rounded-xl transition-colors',
              viewMode === 'calendar'
                ? 'bg-gradient-primary text-white shadow-glow-sm'
                : 'bg-card border border-border text-foreground-secondary hover:text-foreground'
            )}
          >
            <Calendar size={18} />
          </button>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-foreground-dim" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Suche nach Name, Telefon oder E-Mail..."
            className="input-field pl-11 w-full"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto no-scrollbar">
          {(['all', 'pending', 'confirmed', 'cancelled'] as const).map((status) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={cn(
                'px-4 py-2.5 rounded-xl text-sm font-medium whitespace-nowrap transition-all',
                filter === status
                  ? 'bg-gradient-primary text-white shadow-glow-sm'
                  : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
              )}
            >
              {status === 'all' ? 'Alle' : statusConfig[status].label}
            </button>
          ))}
        </div>
      </div>

      {/* Calendar View - Split Layout */}
      {viewMode === 'calendar' && (
        <div className="flex flex-col lg:flex-row gap-4">
          {/* Left: Compact Calendar */}
          <div className="lg:w-[320px] shrink-0">
            <div className="glass-card p-4 sticky top-20">
              {/* Month Navigation */}
              <div className="flex items-center justify-between mb-4">
                <button
                  onClick={goToPreviousMonth}
                  className="p-1.5 rounded-lg hover:bg-white/5 text-foreground-secondary hover:text-foreground transition-colors"
                >
                  <ChevronLeft size={18} />
                </button>
                <h3 className="text-sm font-semibold text-foreground">
                  {currentDate.toLocaleDateString('de-DE', { month: 'long', year: 'numeric' })}
                </h3>
                <button
                  onClick={goToNextMonth}
                  className="p-1.5 rounded-lg hover:bg-white/5 text-foreground-secondary hover:text-foreground transition-colors"
                >
                  <ChevronRight size={18} />
                </button>
              </div>

              {/* Week Day Headers */}
              <div className="grid grid-cols-7 gap-1 mb-1">
                {weekDays.map((day, i) => (
                  <div
                    key={i}
                    className="text-center text-[10px] font-medium text-foreground-dim py-1"
                  >
                    {day}
                  </div>
                ))}
              </div>

              {/* Calendar Days - Compact Grid */}
              <div className="grid grid-cols-7 gap-1">
                {Array.from({ length: firstDayOfMonth }).map((_, index) => (
                  <div key={`empty-${index}`} className="w-10 h-10" />
                ))}

                {Array.from({ length: daysInMonth }).map((_, index) => {
                  const day = index + 1;
                  const dayBookings = getBookingsForDate(day);
                  const confirmedCount = dayBookings.filter((b) => b.status === 'confirmed').length;
                  const pendingCount = dayBookings.filter((b) => b.status === 'pending').length;
                  const isSelected = selectedCalendarDate === formatDateStr(day);
                  const isToday = new Date().toDateString() === new Date(currentDate.getFullYear(), currentDate.getMonth(), day).toDateString();

                  return (
                    <button
                      key={day}
                      onClick={() => handleDayClick(day)}
                      className={cn(
                        'w-10 h-10 rounded-lg flex flex-col items-center justify-center transition-all relative',
                        isSelected
                          ? 'bg-gradient-primary text-white shadow-glow-sm'
                          : isToday
                          ? 'bg-accent-purple/20 text-accent-purple ring-1 ring-accent-purple/30'
                          : 'hover:bg-white/5 text-foreground-secondary hover:text-foreground'
                      )}
                    >
                      <span className={cn(
                        'text-xs font-medium',
                        isSelected ? 'text-white' : ''
                      )}>
                        {day}
                      </span>

                      {/* Booking Indicator Dots */}
                      {dayBookings.length > 0 && (
                        <div className="flex gap-0.5 mt-0.5">
                          {confirmedCount > 0 && (
                            <span className={cn(
                              'w-1.5 h-1.5 rounded-full',
                              isSelected ? 'bg-white/70' : 'bg-success'
                            )} />
                          )}
                          {confirmedCount > 1 && (
                            <span className={cn(
                              'w-1.5 h-1.5 rounded-full',
                              isSelected ? 'bg-white/70' : 'bg-success'
                            )} />
                          )}
                          {pendingCount > 0 && (
                            <span className={cn(
                              'w-1.5 h-1.5 rounded-full',
                              isSelected ? 'bg-white/50' : 'bg-warning'
                            )} />
                          )}
                        </div>
                      )}
                    </button>
                  );
                })}
              </div>

              {/* Legend */}
              <div className="flex items-center justify-center gap-4 mt-4 pt-3 border-t border-white/5">
                <div className="flex items-center gap-1.5 text-[10px] text-foreground-muted">
                  <span className="w-2 h-2 rounded-full bg-success" />
                  Bestätigt
                </div>
                <div className="flex items-center gap-1.5 text-[10px] text-foreground-muted">
                  <span className="w-2 h-2 rounded-full bg-warning" />
                  Ausstehend
                </div>
              </div>
            </div>
          </div>

          {/* Right: Bookings List for Selected Day */}
          <div className="flex-1 min-w-0">
            {selectedCalendarDate ? (
              <div className="space-y-4">
                {/* Selected Date Header */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="p-2.5 rounded-xl bg-gradient-primary/20 text-primary-400">
                      <CalendarDays size={20} />
                    </div>
                    <div>
                      <h3 className="text-lg font-semibold text-foreground">
                        {formatSelectedDate(selectedCalendarDate)}
                      </h3>
                      <p className="text-sm text-foreground-muted">
                        {selectedDateBookings.length} Reservierung{selectedDateBookings.length !== 1 ? 'en' : ''}
                      </p>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedCalendarDate(null)}
                    className="text-xs text-foreground-muted hover:text-foreground px-3 py-1.5 rounded-lg hover:bg-white/5"
                  >
                    Zurücksetzen
                  </button>
                </div>

                {/* Bookings for Selected Date */}
                {selectedDateBookings.length > 0 ? (
                  <div className="space-y-2 max-h-[calc(100vh-320px)] overflow-y-auto no-scrollbar">
                    {selectedDateBookings
                      .sort((a, b) => a.time.localeCompare(b.time))
                      .map((booking) => (
                        <BookingCard
                          key={booking.id}
                          booking={booking}
                          statusConfig={statusConfig}
                          onStatusChange={handleStatusChange}
                          onOpenDetails={openBookingDetails}
                          menuOpen={menuOpen}
                          setMenuOpen={setMenuOpen}
                          saving={saving}
                        />
                      ))}
                  </div>
                ) : (
                  <div className="glass-card p-8 text-center">
                    <Users size={32} className="mx-auto text-foreground-dim mb-3" />
                    <p className="text-foreground-secondary">Keine Reservierungen für diesen Tag</p>
                    <p className="text-sm text-foreground-muted mt-1">
                      {filter !== 'all' ? 'Versuchen Sie einen anderen Filter' : 'Dieser Tag ist frei'}
                    </p>
                  </div>
                )}
              </div>
            ) : (
              <div className="glass-card p-12 text-center h-full flex flex-col items-center justify-center min-h-[300px]">
                <div className="p-4 rounded-2xl bg-gradient-primary/10 mb-4">
                  <Calendar size={40} className="text-primary-400" />
                </div>
                <h3 className="text-lg font-semibold text-foreground">Datum auswählen</h3>
                <p className="text-foreground-muted mt-1 max-w-xs">
                  Klicken Sie auf einen Tag im Kalender, um die Reservierungen anzuzeigen
                </p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* List View */}
      {viewMode === 'list' && (
        <div className="space-y-6">
          {sortedDates.length > 0 ? (
            sortedDates.map((date) => (
              <div key={date}>
                <h3 className="text-sm font-medium text-foreground-secondary mb-3 flex items-center gap-2">
                  <Calendar size={14} />
                  {formatDate(date)}
                  <span className="px-2 py-0.5 rounded-full text-xs bg-card">
                    {groupedBookings[date].length}
                  </span>
                </h3>
                <div className="space-y-2">
                  {groupedBookings[date].map((booking) => (
                    <BookingCard
                      key={booking.id}
                      booking={booking}
                      statusConfig={statusConfig}
                      onStatusChange={handleStatusChange}
                      onOpenDetails={openBookingDetails}
                      menuOpen={menuOpen}
                      setMenuOpen={setMenuOpen}
                      saving={saving}
                    />
                  ))}
                </div>
              </div>
            ))
          ) : (
            <div className="text-center py-12">
              <Users size={48} className="mx-auto text-foreground-dim mb-4" />
              <h3 className="text-lg font-semibold text-foreground">Keine Reservierungen gefunden</h3>
              <p className="text-foreground-muted mt-1">
                {searchQuery ? 'Versuchen Sie eine andere Suche' : 'Keine Reservierungen entsprechen diesem Filter'}
              </p>
            </div>
          )}
        </div>
      )}

      {/* Booking Modal */}
      <BookingModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveBooking}
        booking={selectedBooking}
      />
    </div>
  );
}

// Booking Card Component
interface BookingCardProps {
  booking: Booking;
  statusConfig: Record<BookingStatus, { label: string; color: string; bg: string }>;
  onStatusChange: (bookingId: string, newStatus: BookingStatus) => Promise<void>;
  onOpenDetails: (booking: Booking) => void;
  menuOpen: string | null;
  setMenuOpen: (id: string | null) => void;
  saving: boolean;
}

function BookingCard({
  booking,
  statusConfig,
  onStatusChange,
  onOpenDetails,
  menuOpen,
  setMenuOpen,
  saving,
}: BookingCardProps) {
  return (
    <div
      className="glass-card p-4 hover:shadow-card-hover transition-all duration-300 cursor-pointer"
      onClick={() => onOpenDetails(booking)}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="w-10 h-10 rounded-xl bg-gradient-primary flex items-center justify-center text-white font-semibold shadow-glow-sm">
            {booking.userName.charAt(0)}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <p className="font-semibold text-foreground">
                {booking.userName}
              </p>
              <span className={cn(
                'badge',
                statusConfig[booking.status].bg,
                statusConfig[booking.status].color
              )}>
                {statusConfig[booking.status].label}
              </span>
            </div>
            <div className="flex items-center gap-3 mt-1 text-sm text-foreground-muted">
              <span className="flex items-center gap-1">
                <Clock size={12} />
                {booking.time}
              </span>
              <span className="flex items-center gap-1">
                <Users size={12} />
                {booking.partySize} Gäste
              </span>
              {booking.tableNumber && (
                <span>Tisch {booking.tableNumber}</span>
              )}
            </div>
          </div>
        </div>

        <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          {booking.status === 'pending' && (
            <>
              <button
                onClick={() => onStatusChange(booking.id, 'confirmed')}
                disabled={saving}
                className="p-2 rounded-lg text-success hover:bg-success/10 transition-colors disabled:opacity-50"
                title="Bestätigen"
              >
                <Check size={18} />
              </button>
              <button
                onClick={() => onStatusChange(booking.id, 'cancelled')}
                disabled={saving}
                className="p-2 rounded-lg text-error hover:bg-error/10 transition-colors disabled:opacity-50"
                title="Stornieren"
              >
                <X size={18} />
              </button>
            </>
          )}
          <a
            href={`tel:${booking.userPhone}`}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
            title="Anrufen"
          >
            <Phone size={18} />
          </a>
          <div className="relative">
            <button
              onClick={() => setMenuOpen(menuOpen === booking.id ? null : booking.id)}
              className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
            >
              <MoreVertical size={18} />
            </button>
            {menuOpen === booking.id && (
              <>
                <div
                  className="fixed inset-0 z-10"
                  onClick={() => setMenuOpen(null)}
                />
                <div className="absolute right-0 top-full mt-1 w-40 glass-card py-1 z-20 animate-fade-in">
                  {(['pending', 'confirmed', 'completed', 'no_show', 'cancelled'] as const).map((status) => (
                    <button
                      key={status}
                      onClick={() => onStatusChange(booking.id, status)}
                      disabled={saving}
                      className={cn(
                        'w-full flex items-center gap-2 px-3 py-2 text-sm transition-colors disabled:opacity-50',
                        booking.status === status
                          ? 'bg-white/5 text-foreground'
                          : 'text-foreground-secondary hover:bg-white/5 hover:text-foreground'
                      )}
                    >
                      <span className={cn(
                        'w-2 h-2 rounded-full',
                        statusConfig[status].bg.replace('/20', '')
                      )} />
                      {statusConfig[status].label}
                    </button>
                  ))}
                </div>
              </>
            )}
          </div>
        </div>
      </div>

      {booking.notes && (
        <p className="mt-3 text-sm text-foreground-muted pl-14 line-clamp-1">
          Notiz: {booking.notes}
        </p>
      )}
    </div>
  );
}
