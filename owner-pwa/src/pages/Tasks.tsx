import { useState } from 'react';
import { cn } from '../lib/utils';
import {
  CheckCircle2,
  Circle,
  Clock,
  Plus,
  X,
  AlertTriangle,
  User,
  Calendar,
  Check,
  XCircle,
  Image,
} from 'lucide-react';
import type { Task, TaskStatus, TaskCategory, TaskPriority } from '../types';
import { TASK_CATEGORIES, TASK_PRIORITIES, TASK_STATUSES } from '../types';

// Mock tasks
const mockTasks: Task[] = [
  {
    id: '1',
    title: 'Clean bar area',
    description: 'Wipe down counters, clean glass washer, organize bottles',
    category: 'cleaning',
    priority: 'high',
    status: 'pending',
    assignedTo: '3', // Tom
    assignedBy: '2', // Sarah
    dueDate: '2024-11-29',
    dueTime: '22:00',
    createdAt: '2024-11-29T14:00:00Z',
    updatedAt: '2024-11-29T14:00:00Z',
  },
  {
    id: '2',
    title: 'Restock beer fridge',
    description: 'Check inventory levels and restock from storage',
    category: 'inventory',
    priority: 'medium',
    status: 'in_progress',
    assignedTo: '4', // Lisa
    assignedBy: '2',
    dueDate: '2024-11-29',
    dueTime: '18:00',
    createdAt: '2024-11-29T10:00:00Z',
    updatedAt: '2024-11-29T16:00:00Z',
  },
  {
    id: '3',
    title: 'Prepare cocktail garnishes',
    description: 'Cut limes, lemons, oranges. Prep mint and herbs.',
    category: 'bar',
    priority: 'urgent',
    status: 'completed',
    assignedTo: '3',
    assignedBy: '2',
    dueDate: '2024-11-29',
    dueTime: '17:00',
    completedAt: '2024-11-29T16:45:00Z',
    completedPhoto: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=400',
    createdAt: '2024-11-29T08:00:00Z',
    updatedAt: '2024-11-29T16:45:00Z',
  },
  {
    id: '4',
    title: 'End of night closing checklist',
    description: 'All closing duties: count cash, clean, lock up',
    category: 'closing',
    priority: 'high',
    status: 'pending',
    assignedTo: '2',
    assignedBy: '1',
    dueDate: '2024-11-30',
    dueTime: '03:00',
    createdAt: '2024-11-29T12:00:00Z',
    updatedAt: '2024-11-29T12:00:00Z',
  },
  {
    id: '5',
    title: 'Deep clean bathrooms',
    description: 'Full bathroom cleaning including floors, mirrors, restocking',
    category: 'cleaning',
    priority: 'medium',
    status: 'approved',
    assignedTo: '5',
    assignedBy: '2',
    dueDate: '2024-11-28',
    completedAt: '2024-11-28T15:00:00Z',
    completedPhoto: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
    approvedAt: '2024-11-28T16:00:00Z',
    approvedBy: '2',
    createdAt: '2024-11-28T08:00:00Z',
    updatedAt: '2024-11-28T16:00:00Z',
  },
];

// Mock employee names for display
const employeeNames: Record<string, string> = {
  '1': 'Max M.',
  '2': 'Sarah S.',
  '3': 'Tom W.',
  '4': 'Lisa F.',
  '5': 'Hans B.',
};

export function Tasks() {
  const [tasks, setTasks] = useState<Task[]>(mockTasks);
  const [statusFilter, setStatusFilter] = useState<TaskStatus | 'all'>('all');
  const [categoryFilter, setCategoryFilter] = useState<TaskCategory | 'all'>('all');
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);

  const filteredTasks = tasks.filter((task) => {
    const matchesStatus = statusFilter === 'all' || task.status === statusFilter;
    const matchesCategory = categoryFilter === 'all' || task.category === categoryFilter;
    return matchesStatus && matchesCategory;
  });

  const updateTaskStatus = (taskId: string, newStatus: TaskStatus) => {
    setTasks((prev) =>
      prev.map((t) =>
        t.id === taskId
          ? {
              ...t,
              status: newStatus,
              updatedAt: new Date().toISOString(),
              ...(newStatus === 'completed' && { completedAt: new Date().toISOString() }),
              ...(newStatus === 'approved' && {
                approvedAt: new Date().toISOString(),
                approvedBy: '1',
              }),
            }
          : t
      )
    );
  };

  const stats = {
    pending: tasks.filter((t) => t.status === 'pending').length,
    inProgress: tasks.filter((t) => t.status === 'in_progress').length,
    completed: tasks.filter((t) => t.status === 'completed').length,
    approved: tasks.filter((t) => t.status === 'approved').length,
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Tasks</h1>
          <p className="text-foreground-secondary">
            {stats.pending + stats.inProgress} active tasks
          </p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="btn-primary flex items-center gap-2"
        >
          <Plus size={20} />
          Add Task
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-4 gap-4">
        <StatCard label="Pending" value={stats.pending} color="gray" />
        <StatCard label="In Progress" value={stats.inProgress} color="blue" />
        <StatCard label="Completed" value={stats.completed} color="green" />
        <StatCard label="Approved" value={stats.approved} color="purple" />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-3">
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value as TaskStatus | 'all')}
          className="px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground text-sm"
        >
          <option value="all">All Status</option>
          {TASK_STATUSES.map((s) => (
            <option key={s.value} value={s.value}>
              {s.label}
            </option>
          ))}
        </select>

        <select
          value={categoryFilter}
          onChange={(e) => setCategoryFilter(e.target.value as TaskCategory | 'all')}
          className="px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground text-sm"
        >
          <option value="all">All Categories</option>
          {TASK_CATEGORIES.map((c) => (
            <option key={c.value} value={c.value}>
              {c.icon} {c.label}
            </option>
          ))}
        </select>
      </div>

      {/* Task List */}
      <div className="space-y-3">
        {filteredTasks.length === 0 ? (
          <div className="text-center py-12 text-foreground-secondary">
            <CheckCircle2 size={48} className="mx-auto mb-4 opacity-50" />
            <p>No tasks found</p>
          </div>
        ) : (
          filteredTasks.map((task) => (
            <TaskCard
              key={task.id}
              task={task}
              employeeName={employeeNames[task.assignedTo]}
              onStatusChange={(status) => updateTaskStatus(task.id, status)}
              onClick={() => setSelectedTask(task)}
            />
          ))
        )}
      </div>

      {/* Add Task Modal */}
      {showAddModal && (
        <AddTaskModal
          onClose={() => setShowAddModal(false)}
          onSave={(task) => {
            setTasks((prev) => [
              ...prev,
              { ...task, id: Date.now().toString() },
            ]);
            setShowAddModal(false);
          }}
          employeeNames={employeeNames}
        />
      )}

      {/* Task Detail Modal */}
      {selectedTask && (
        <TaskDetailModal
          task={selectedTask}
          employeeName={employeeNames[selectedTask.assignedTo]}
          onClose={() => setSelectedTask(null)}
          onApprove={() => {
            updateTaskStatus(selectedTask.id, 'approved');
            setSelectedTask(null);
          }}
          onReject={() => {
            updateTaskStatus(selectedTask.id, 'rejected');
            setSelectedTask(null);
          }}
        />
      )}
    </div>
  );
}

function StatCard({
  label,
  value,
  color,
}: {
  label: string;
  value: number;
  color: 'gray' | 'blue' | 'green' | 'purple';
}) {
  const colors = {
    gray: 'bg-foreground-secondary/10 text-foreground-secondary',
    blue: 'bg-accent-cyan/10 text-accent-cyan',
    green: 'bg-success/10 text-success',
    purple: 'bg-accent-purple/10 text-accent-purple',
  };

  return (
    <div
      className={cn(
        'p-4 rounded-xl text-center',
        colors[color]
      )}
    >
      <p className="text-2xl font-bold">{value}</p>
      <p className="text-sm opacity-80">{label}</p>
    </div>
  );
}

interface TaskCardProps {
  task: Task;
  employeeName: string;
  onStatusChange: (status: TaskStatus) => void;
  onClick: () => void;
}

function TaskCard({ task, employeeName, onStatusChange, onClick }: TaskCardProps) {
  const category = TASK_CATEGORIES.find((c) => c.value === task.category);
  const priority = TASK_PRIORITIES.find((p) => p.value === task.priority);
  const status = TASK_STATUSES.find((s) => s.value === task.status);

  const isOverdue =
    task.dueDate &&
    task.status !== 'completed' &&
    task.status !== 'approved' &&
    new Date(`${task.dueDate}T${task.dueTime || '23:59'}`) < new Date();

  return (
    <div
      onClick={onClick}
      className={cn(
        'p-4 bg-background-elevated border rounded-xl cursor-pointer transition-all hover:border-primary/50',
        isOverdue ? 'border-error/50' : 'border-border'
      )}
    >
      <div className="flex items-start gap-3">
        {/* Status Toggle */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            if (task.status === 'pending') onStatusChange('in_progress');
            else if (task.status === 'in_progress') onStatusChange('completed');
          }}
          className={cn(
            'mt-0.5 flex-shrink-0',
            task.status === 'completed' || task.status === 'approved'
              ? 'text-success'
              : task.status === 'in_progress'
              ? 'text-accent-cyan'
              : 'text-foreground-secondary'
          )}
        >
          {task.status === 'completed' || task.status === 'approved' ? (
            <CheckCircle2 size={22} />
          ) : task.status === 'in_progress' ? (
            <Clock size={22} />
          ) : (
            <Circle size={22} />
          )}
        </button>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <h3
              className={cn(
                'font-medium',
                task.status === 'completed' || task.status === 'approved'
                  ? 'text-foreground-secondary line-through'
                  : 'text-foreground'
              )}
            >
              {task.title}
            </h3>
            {isOverdue && (
              <span className="flex items-center gap-1 px-1.5 py-0.5 text-xs bg-error/20 text-error rounded">
                <AlertTriangle size={12} />
                Overdue
              </span>
            )}
          </div>

          {task.description && (
            <p className="text-sm text-foreground-secondary mt-1 line-clamp-1">
              {task.description}
            </p>
          )}

          <div className="flex items-center gap-3 mt-2 flex-wrap">
            {/* Category */}
            <span
              className="flex items-center gap-1 text-xs px-2 py-0.5 rounded-full"
              style={{ backgroundColor: `${category?.color}20`, color: category?.color }}
            >
              {category?.icon} {category?.label}
            </span>

            {/* Priority */}
            <span
              className="text-xs px-2 py-0.5 rounded-full"
              style={{ backgroundColor: `${priority?.color}20`, color: priority?.color }}
            >
              {priority?.label}
            </span>

            {/* Assigned To */}
            <span className="flex items-center gap-1 text-xs text-foreground-secondary">
              <User size={12} />
              {employeeName}
            </span>

            {/* Due */}
            {task.dueDate && (
              <span className="flex items-center gap-1 text-xs text-foreground-secondary">
                <Calendar size={12} />
                {task.dueTime || ''}
              </span>
            )}

            {/* Photo indicator */}
            {task.completedPhoto && (
              <span className="flex items-center gap-1 text-xs text-success">
                <Image size={12} />
                Photo
              </span>
            )}
          </div>
        </div>

        {/* Status Badge */}
        <span
          className="text-xs px-2 py-1 rounded-full flex-shrink-0"
          style={{ backgroundColor: `${status?.color}20`, color: status?.color }}
        >
          {status?.label}
        </span>
      </div>
    </div>
  );
}

interface AddTaskModalProps {
  onClose: () => void;
  onSave: (task: Task) => void;
  employeeNames: Record<string, string>;
}

function AddTaskModal({ onClose, onSave, employeeNames }: AddTaskModalProps) {
  const [form, setForm] = useState<Partial<Task>>({
    title: '',
    description: '',
    category: 'general',
    priority: 'medium',
    status: 'pending',
    assignedTo: '3',
    assignedBy: '1',
    dueDate: new Date().toISOString().split('T')[0],
    dueTime: '18:00',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave({
      ...form,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    } as Task);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-background-card border border-border rounded-2xl w-full max-w-md p-6 animate-scale-up max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg hover:bg-background-elevated text-foreground-secondary"
        >
          <X size={20} />
        </button>

        <h2 className="text-xl font-bold text-foreground mb-6">Add Task</h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Title
            </label>
            <input
              type="text"
              value={form.title || ''}
              onChange={(e) => setForm({ ...form, title: e.target.value })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              placeholder="What needs to be done?"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Description
            </label>
            <textarea
              value={form.description || ''}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              rows={3}
              placeholder="Additional details..."
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                Category
              </label>
              <select
                value={form.category}
                onChange={(e) => setForm({ ...form, category: e.target.value as TaskCategory })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              >
                {TASK_CATEGORIES.map((c) => (
                  <option key={c.value} value={c.value}>
                    {c.icon} {c.label}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                Priority
              </label>
              <select
                value={form.priority}
                onChange={(e) => setForm({ ...form, priority: e.target.value as TaskPriority })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              >
                {TASK_PRIORITIES.map((p) => (
                  <option key={p.value} value={p.value}>
                    {p.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-foreground-secondary mb-1">
              Assign To
            </label>
            <select
              value={form.assignedTo}
              onChange={(e) => setForm({ ...form, assignedTo: e.target.value })}
              className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
            >
              {Object.entries(employeeNames).map(([id, name]) => (
                <option key={id} value={id}>
                  {name}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                Due Date
              </label>
              <input
                type="date"
                value={form.dueDate || ''}
                onChange={(e) => setForm({ ...form, dueDate: e.target.value })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-foreground-secondary mb-1">
                Due Time
              </label>
              <input
                type="time"
                value={form.dueTime || ''}
                onChange={(e) => setForm({ ...form, dueTime: e.target.value })}
                className="w-full px-3 py-2 bg-background-elevated border border-border rounded-lg text-foreground"
              />
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2.5 border border-border rounded-lg text-foreground hover:bg-background-elevated"
            >
              Cancel
            </button>
            <button type="submit" className="flex-1 btn-primary">
              Create Task
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

interface TaskDetailModalProps {
  task: Task;
  employeeName: string;
  onClose: () => void;
  onApprove: () => void;
  onReject: () => void;
}

function TaskDetailModal({
  task,
  employeeName,
  onClose,
  onApprove,
  onReject,
}: TaskDetailModalProps) {
  const category = TASK_CATEGORIES.find((c) => c.value === task.category);
  const priority = TASK_PRIORITIES.find((p) => p.value === task.priority);
  const status = TASK_STATUSES.find((s) => s.value === task.status);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="fixed inset-0 bg-black/60" onClick={onClose} />
      <div className="relative bg-background-card border border-border rounded-2xl w-full max-w-lg p-6 animate-scale-up max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-lg hover:bg-background-elevated text-foreground-secondary"
        >
          <X size={20} />
        </button>

        <div className="space-y-4">
          {/* Title & Status */}
          <div>
            <div className="flex items-center gap-2 mb-2">
              <span
                className="text-xs px-2 py-1 rounded-full"
                style={{ backgroundColor: `${status?.color}20`, color: status?.color }}
              >
                {status?.label}
              </span>
              <span
                className="text-xs px-2 py-1 rounded-full"
                style={{ backgroundColor: `${priority?.color}20`, color: priority?.color }}
              >
                {priority?.label}
              </span>
            </div>
            <h2 className="text-xl font-bold text-foreground">{task.title}</h2>
          </div>

          {/* Description */}
          {task.description && (
            <p className="text-foreground-secondary">{task.description}</p>
          )}

          {/* Meta Info */}
          <div className="grid grid-cols-2 gap-4 p-4 bg-background-elevated rounded-xl">
            <div>
              <p className="text-xs text-foreground-secondary">Category</p>
              <p className="text-sm text-foreground">
                {category?.icon} {category?.label}
              </p>
            </div>
            <div>
              <p className="text-xs text-foreground-secondary">Assigned To</p>
              <p className="text-sm text-foreground">{employeeName}</p>
            </div>
            <div>
              <p className="text-xs text-foreground-secondary">Due</p>
              <p className="text-sm text-foreground">
                {task.dueDate} {task.dueTime}
              </p>
            </div>
            {task.completedAt && (
              <div>
                <p className="text-xs text-foreground-secondary">Completed</p>
                <p className="text-sm text-success">
                  {new Date(task.completedAt).toLocaleString('de-DE')}
                </p>
              </div>
            )}
          </div>

          {/* Completion Photo */}
          {task.completedPhoto && (
            <div>
              <p className="text-sm font-medium text-foreground mb-2">
                Completion Photo
              </p>
              <img
                src={task.completedPhoto}
                alt="Task completion"
                className="w-full rounded-xl"
              />
            </div>
          )}

          {/* Approval Section (only for completed tasks) */}
          {task.status === 'completed' && (
            <div className="flex gap-3 pt-4 border-t border-border">
              <button
                onClick={onReject}
                className="flex-1 py-2.5 border border-error text-error rounded-lg hover:bg-error/10 flex items-center justify-center gap-2"
              >
                <XCircle size={18} />
                Reject
              </button>
              <button
                onClick={onApprove}
                className="flex-1 py-2.5 bg-success text-white rounded-lg hover:bg-success/90 flex items-center justify-center gap-2"
              >
                <Check size={18} />
                Approve
              </button>
            </div>
          )}

          {/* Approval Info */}
          {task.status === 'approved' && task.approvedAt && (
            <div className="p-3 bg-success/10 rounded-xl text-success text-sm">
              <Check size={16} className="inline mr-2" />
              Approved on {new Date(task.approvedAt).toLocaleString('de-DE')}
            </div>
          )}

          {task.status === 'rejected' && task.rejectionReason && (
            <div className="p-3 bg-error/10 rounded-xl text-error text-sm">
              <XCircle size={16} className="inline mr-2" />
              Rejected: {task.rejectionReason}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
