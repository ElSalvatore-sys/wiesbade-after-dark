import { useState } from 'react';
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
} from 'lucide-react';
import { BookingModal } from '../components/BookingModal';
import type { Booking, BookingStatus } from '../types';

// Mock bookings data with more dates for calendar demo
const mockBookings: Booking[] = [
  {
    id: '1',
    venueId: '1',
    userId: '1',
    userName: 'Anna Schmidt',
    userPhone: '+49 170 1234567',
    userEmail: 'anna@example.com',
    date: '2024-12-15',
    time: '20:00',
    partySize: 4,
    tableNumber: 'VIP-1',
    status: 'confirmed',
    notes: 'Birthday celebration, need cake',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    venueId: '1',
    userId: '2',
    userName: 'Max Müller',
    userPhone: '+49 171 9876543',
    userEmail: 'max@example.com',
    date: '2024-12-15',
    time: '21:00',
    partySize: 6,
    tableNumber: 'T-5',
    status: 'pending',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    venueId: '1',
    userId: '3',
    userName: 'Sophie Weber',
    userPhone: '+49 172 5555555',
    userEmail: 'sophie@example.com',
    date: '2024-12-15',
    time: '19:30',
    partySize: 2,
    tableNumber: 'T-2',
    status: 'confirmed',
    notes: 'Anniversary dinner',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '4',
    venueId: '1',
    userId: '4',
    userName: 'Thomas Fischer',
    userPhone: '+49 173 4444444',
    userEmail: 'thomas@example.com',
    date: '2024-12-16',
    time: '22:00',
    partySize: 8,
    tableNumber: 'VIP-2',
    status: 'pending',
    notes: 'Corporate event',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '5',
    venueId: '1',
    userId: '5',
    userName: 'Lisa Braun',
    userPhone: '+49 174 3333333',
    userEmail: 'lisa@example.com',
    date: '2024-12-14',
    time: '20:30',
    partySize: 3,
    status: 'cancelled',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '6',
    venueId: '1',
    userId: '6',
    userName: 'Michael Koch',
    userPhone: '+49 175 2222222',
    userEmail: 'michael@example.com',
    date: '2024-12-20',
    time: '21:00',
    partySize: 5,
    tableNumber: 'T-8',
    status: 'confirmed',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '7',
    venueId: '1',
    userId: '7',
    userName: 'Julia Becker',
    userPhone: '+49 176 1111111',
    userEmail: 'julia@example.com',
    date: '2024-12-20',
    time: '19:00',
    partySize: 2,
    status: 'pending',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '8',
    venueId: '1',
    userId: '8',
    userName: 'David Hoffmann',
    userPhone: '+49 177 0000000',
    userEmail: 'david@example.com',
    date: '2024-12-21',
    time: '20:00',
    partySize: 4,
    tableNumber: 'VIP-3',
    status: 'confirmed',
    notes: 'VIP guest - champagne on arrival',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '9',
    venueId: '1',
    userId: '9',
    userName: 'Emma Schulz',
    userPhone: '+49 178 9999999',
    userEmail: 'emma@example.com',
    date: '2024-12-28',
    time: '22:00',
    partySize: 10,
    tableNumber: 'VIP-1',
    status: 'confirmed',
    notes: 'New Year preparation party',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '10',
    venueId: '1',
    userId: '10',
    userName: 'Felix Wagner',
    userPhone: '+49 179 8888888',
    userEmail: 'felix@example.com',
    date: '2024-12-20',
    time: '20:30',
    partySize: 4,
    tableNumber: 'T-3',
    status: 'confirmed',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

type FilterStatus = 'all' | BookingStatus;
type ViewMode = 'list' | 'calendar';

export function Bookings() {
  const [bookings, setBookings] = useState<Booking[]>(mockBookings);
  const [filter, setFilter] = useState<FilterStatus>('all');
  const [viewMode, setViewMode] = useState<ViewMode>('list');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState<string | null>(null);

  // Calendar state
  const [currentDate, setCurrentDate] = useState(new Date(2024, 11, 1)); // December 2024
  const [selectedCalendarDate, setSelectedCalendarDate] = useState<string | null>(null);

  const filteredBookings = bookings.filter((booking) => {
    const matchesFilter = filter === 'all' || booking.status === filter;
    const matchesSearch = booking.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
      booking.userPhone.includes(searchQuery) ||
      booking.userEmail.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCalendarDate = selectedCalendarDate ? booking.date === selectedCalendarDate : true;
    return matchesFilter && matchesSearch && matchesCalendarDate;
  });

  const handleStatusChange = (bookingId: string, newStatus: BookingStatus) => {
    setBookings(bookings.map((b) =>
      b.id === bookingId ? { ...b, status: newStatus } : b
    ));
    setMenuOpen(null);
  };

  const handleSaveBooking = (updatedBooking: Partial<Booking>) => {
    setBookings(bookings.map((b) =>
      b.id === updatedBooking.id ? { ...b, ...updatedBooking } : b
    ));
  };

  const openBookingDetails = (booking: Booking) => {
    setSelectedBooking(booking);
    setIsModalOpen(true);
  };

  const statusConfig: Record<BookingStatus, { label: string; color: string; bg: string }> = {
    pending: { label: 'Pending', color: 'text-warning', bg: 'bg-warning/20' },
    confirmed: { label: 'Confirmed', color: 'text-success', bg: 'bg-success/20' },
    cancelled: { label: 'Cancelled', color: 'text-error', bg: 'bg-error/20' },
    completed: { label: 'Completed', color: 'text-accent-cyan', bg: 'bg-accent-cyan/20' },
    no_show: { label: 'No Show', color: 'text-foreground-dim', bg: 'bg-foreground-dim/20' },
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    if (date.toDateString() === today.toDateString()) return 'Today';
    if (date.toDateString() === tomorrow.toDateString()) return 'Tomorrow';

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

    const dayName = date.toLocaleDateString('en-US', { weekday: 'short' });
    const monthDay = date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

    if (date.toDateString() === today.toDateString()) return `Today - ${monthDay}`;
    if (date.toDateString() === tomorrow.toDateString()) return `Tomorrow - ${monthDay}`;

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
  const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // Get bookings for selected date in calendar view
  const selectedDateBookings = selectedCalendarDate
    ? bookings.filter((b) => {
        const matchesDate = b.date === selectedCalendarDate;
        const matchesFilter = filter === 'all' || b.status === filter;
        const matchesSearch = b.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
          b.userPhone.includes(searchQuery) ||
          b.userEmail.toLowerCase().includes(searchQuery.toLowerCase());
        return matchesDate && matchesFilter && matchesSearch;
      })
    : [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Bookings</h1>
          <p className="text-foreground-secondary mt-1">
            Manage reservations and guest requests
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
            placeholder="Search by guest name, phone, or email..."
            className="input-field pl-11 w-full"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto no-scrollbar">
          {(['all', 'pending', 'confirmed', 'cancelled'] as const).map((status) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={cn(
                'px-4 py-2.5 rounded-xl text-sm font-medium capitalize whitespace-nowrap transition-all',
                filter === status
                  ? 'bg-gradient-primary text-white shadow-glow-sm'
                  : 'bg-card border border-border text-foreground-secondary hover:border-border-light'
              )}
            >
              {status === 'all' ? 'All' : status}
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
                  {currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}
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
                  Confirmed
                </div>
                <div className="flex items-center gap-1.5 text-[10px] text-foreground-muted">
                  <span className="w-2 h-2 rounded-full bg-warning" />
                  Pending
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
                        {selectedDateBookings.length} booking{selectedDateBookings.length !== 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedCalendarDate(null)}
                    className="text-xs text-foreground-muted hover:text-foreground px-3 py-1.5 rounded-lg hover:bg-white/5"
                  >
                    Clear
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
                        />
                      ))}
                  </div>
                ) : (
                  <div className="glass-card p-8 text-center">
                    <Users size={32} className="mx-auto text-foreground-dim mb-3" />
                    <p className="text-foreground-secondary">No bookings for this day</p>
                    <p className="text-sm text-foreground-muted mt-1">
                      {filter !== 'all' ? 'Try changing the filter' : 'This day is free'}
                    </p>
                  </div>
                )}
              </div>
            ) : (
              <div className="glass-card p-12 text-center h-full flex flex-col items-center justify-center min-h-[300px]">
                <div className="p-4 rounded-2xl bg-gradient-primary/10 mb-4">
                  <Calendar size={40} className="text-primary-400" />
                </div>
                <h3 className="text-lg font-semibold text-foreground">Select a date</h3>
                <p className="text-foreground-muted mt-1 max-w-xs">
                  Click on any day in the calendar to view its bookings
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
                    />
                  ))}
                </div>
              </div>
            ))
          ) : (
            <div className="text-center py-12">
              <Users size={48} className="mx-auto text-foreground-dim mb-4" />
              <h3 className="text-lg font-semibold text-foreground">No bookings found</h3>
              <p className="text-foreground-muted mt-1">
                {searchQuery ? 'Try a different search' : 'No bookings match this filter'}
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
  onStatusChange: (bookingId: string, newStatus: BookingStatus) => void;
  onOpenDetails: (booking: Booking) => void;
  menuOpen: string | null;
  setMenuOpen: (id: string | null) => void;
}

function BookingCard({
  booking,
  statusConfig,
  onStatusChange,
  onOpenDetails,
  menuOpen,
  setMenuOpen,
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
                {booking.partySize}
              </span>
              {booking.tableNumber && (
                <span>Table {booking.tableNumber}</span>
              )}
            </div>
          </div>
        </div>

        <div className="flex items-center gap-1" onClick={(e) => e.stopPropagation()}>
          {booking.status === 'pending' && (
            <>
              <button
                onClick={() => onStatusChange(booking.id, 'confirmed')}
                className="p-2 rounded-lg text-success hover:bg-success/10 transition-colors"
                title="Confirm"
              >
                <Check size={18} />
              </button>
              <button
                onClick={() => onStatusChange(booking.id, 'cancelled')}
                className="p-2 rounded-lg text-error hover:bg-error/10 transition-colors"
                title="Cancel"
              >
                <X size={18} />
              </button>
            </>
          )}
          <a
            href={`tel:${booking.userPhone}`}
            className="p-2 rounded-lg text-foreground-muted hover:text-foreground hover:bg-white/5 transition-colors"
            title="Call"
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
                      className={cn(
                        'w-full flex items-center gap-2 px-3 py-2 text-sm transition-colors',
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
          Note: {booking.notes}
        </p>
      )}
    </div>
  );
}
