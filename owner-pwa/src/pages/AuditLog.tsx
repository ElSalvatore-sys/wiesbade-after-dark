import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  History,
  Clock,
  User,
  Package,
  CheckSquare,
  Filter,
  ChevronDown,
  RefreshCw,
  AlertCircle,
} from 'lucide-react';
import { supabaseApi } from '../services/supabaseApi';
import { cn } from '../lib/utils';

interface AuditLogEntry {
  id: string;
  venue_id: string;
  user_id: string | null;
  user_name: string | null;
  action: string;
  entity_type: string;
  entity_id: string | null;
  details: Record<string, unknown> | null;
  created_at: string;
}

type EntityFilter = 'all' | 'shift' | 'task' | 'inventory';

const entityIcons: Record<string, typeof Clock> = {
  shift: Clock,
  task: CheckSquare,
  inventory: Package,
};

const actionLabels: Record<string, string> = {
  clock_in: 'Eingestempelt',
  clock_out: 'Ausgestempelt',
  task_pending: 'Aufgabe erstellt',
  task_in_progress: 'Aufgabe gestartet',
  task_completed: 'Aufgabe abgeschlossen',
  task_approved: 'Aufgabe genehmigt',
  task_rejected: 'Aufgabe abgelehnt',
  stock_added: 'Bestand erhöht',
  stock_removed: 'Bestand reduziert',
};

const entityLabels: Record<string, string> = {
  shift: 'Schicht',
  task: 'Aufgabe',
  inventory: 'Inventar',
};

export default function AuditLog() {
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<EntityFilter>('all');
  const [showFilterMenu, setShowFilterMenu] = useState(false);

  const loadLogs = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await supabaseApi.getAuditLogs(filter === 'all' ? undefined : filter);
      setLogs(data);
    } catch (err) {
      console.error('Error loading audit logs:', err);
      setError('Fehler beim Laden der Protokolle');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadLogs();
  }, [filter]);

  const formatTime = (dateStr: string) => {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Gerade eben';
    if (diffMins < 60) return `vor ${diffMins} Min.`;
    if (diffHours < 24) return `vor ${diffHours} Std.`;
    if (diffDays < 7) return `vor ${diffDays} Tagen`;

    return date.toLocaleDateString('de-DE', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getActionColor = (action: string) => {
    if (action.includes('clock_in') || action.includes('added') || action.includes('approved')) {
      return 'text-green-400';
    }
    if (action.includes('clock_out') || action.includes('completed')) {
      return 'text-blue-400';
    }
    if (action.includes('removed') || action.includes('rejected')) {
      return 'text-red-400';
    }
    return 'text-purple-400';
  };

  const renderDetails = (log: AuditLogEntry) => {
    if (!log.details) return null;

    const details = log.details;

    if (log.entity_type === 'shift') {
      if (details.actual_hours) {
        return (
          <span className="text-zinc-500 text-xs">
            {Number(details.actual_hours).toFixed(1)} Stunden gearbeitet
          </span>
        );
      }
    }

    if (log.entity_type === 'task' && details.title) {
      return (
        <span className="text-zinc-500 text-xs truncate max-w-[200px]">
          "{String(details.title)}"
        </span>
      );
    }

    if (log.entity_type === 'inventory') {
      const change = (details.new_storage as number) - (details.old_storage as number) +
                     (details.new_bar as number) - (details.old_bar as number);
      return (
        <span className="text-zinc-500 text-xs">
          {String(details.product)}: {change > 0 ? '+' : ''}{change} Einheiten
        </span>
      );
    }

    return null;
  };

  const filterOptions: { value: EntityFilter; label: string }[] = [
    { value: 'all', label: 'Alle Aktivitäten' },
    { value: 'shift', label: 'Nur Schichten' },
    { value: 'task', label: 'Nur Aufgaben' },
    { value: 'inventory', label: 'Nur Inventar' },
  ];

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-purple-500/20 rounded-xl flex items-center justify-center">
            <History className="w-5 h-5 text-purple-400" />
          </div>
          <div>
            <h1 className="text-xl font-semibold text-white">Aktivitätsprotokoll</h1>
            <p className="text-sm text-zinc-400">
              {logs.length} Einträge
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Filter Dropdown */}
          <div className="relative">
            <button
              onClick={() => setShowFilterMenu(!showFilterMenu)}
              className="flex items-center gap-2 px-3 py-2 bg-zinc-800 hover:bg-zinc-700 rounded-lg text-sm text-zinc-300 transition-colors"
            >
              <Filter className="w-4 h-4" />
              {filterOptions.find(f => f.value === filter)?.label}
              <ChevronDown className={cn("w-4 h-4 transition-transform", showFilterMenu && "rotate-180")} />
            </button>

            {showFilterMenu && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="absolute right-0 mt-2 w-48 bg-zinc-800 rounded-lg shadow-lg border border-zinc-700 py-1 z-10"
              >
                {filterOptions.map(option => (
                  <button
                    key={option.value}
                    onClick={() => {
                      setFilter(option.value);
                      setShowFilterMenu(false);
                    }}
                    className={cn(
                      "w-full px-4 py-2 text-left text-sm hover:bg-zinc-700 transition-colors",
                      filter === option.value ? "text-purple-400" : "text-zinc-300"
                    )}
                  >
                    {option.label}
                  </button>
                ))}
              </motion.div>
            )}
          </div>

          {/* Refresh Button */}
          <button
            onClick={loadLogs}
            disabled={loading}
            className="p-2 bg-zinc-800 hover:bg-zinc-700 rounded-lg text-zinc-300 transition-colors disabled:opacity-50"
          >
            <RefreshCw className={cn("w-4 h-4", loading && "animate-spin")} />
          </button>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="flex items-center gap-3 p-4 bg-red-500/10 border border-red-500/30 rounded-xl">
          <AlertCircle className="w-5 h-5 text-red-400" />
          <span className="text-red-400">{error}</span>
        </div>
      )}

      {/* Log List */}
      <div className="space-y-2">
        {loading && logs.length === 0 ? (
          <div className="flex items-center justify-center py-12">
            <RefreshCw className="w-6 h-6 text-purple-400 animate-spin" />
          </div>
        ) : logs.length === 0 ? (
          <div className="text-center py-12">
            <History className="w-12 h-12 text-zinc-600 mx-auto mb-3" />
            <p className="text-zinc-400">Keine Aktivitäten gefunden</p>
            <p className="text-sm text-zinc-500 mt-1">
              Aktivitäten werden automatisch protokolliert
            </p>
          </div>
        ) : (
          logs.map((log, index) => {
            const Icon = entityIcons[log.entity_type] || History;
            const actionLabel = actionLabels[log.action] || log.action;
            const entityLabel = entityLabels[log.entity_type] || log.entity_type;

            return (
              <motion.div
                key={log.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.03 }}
                className="flex items-start gap-4 p-4 bg-zinc-900/50 rounded-xl border border-zinc-800 hover:border-zinc-700 transition-colors"
              >
                {/* Icon */}
                <div className={cn(
                  "w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0",
                  log.entity_type === 'shift' && "bg-blue-500/20",
                  log.entity_type === 'task' && "bg-green-500/20",
                  log.entity_type === 'inventory' && "bg-amber-500/20"
                )}>
                  <Icon className={cn(
                    "w-5 h-5",
                    log.entity_type === 'shift' && "text-blue-400",
                    log.entity_type === 'task' && "text-green-400",
                    log.entity_type === 'inventory' && "text-amber-400"
                  )} />
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 flex-wrap">
                    <span className={cn("font-medium", getActionColor(log.action))}>
                      {actionLabel}
                    </span>
                    <span className="text-zinc-500">•</span>
                    <span className="text-zinc-400 text-sm">{entityLabel}</span>
                  </div>

                  <div className="flex items-center gap-2 mt-1">
                    {log.user_name && (
                      <div className="flex items-center gap-1 text-zinc-400 text-sm">
                        <User className="w-3 h-3" />
                        {log.user_name}
                      </div>
                    )}
                    {renderDetails(log)}
                  </div>
                </div>

                {/* Time */}
                <div className="text-xs text-zinc-500 flex-shrink-0">
                  {formatTime(log.created_at)}
                </div>
              </motion.div>
            );
          })
        )}
      </div>
    </div>
  );
}
