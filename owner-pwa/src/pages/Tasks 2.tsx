import { useState } from 'react';
import {
  Plus,
  Check,
  Clock,
  X,
  Camera,
  Filter,
  AlertCircle,
  CheckCircle2,
  XCircle,
  PlayCircle,
  Circle,
  User,
  Calendar,
  Trash2,
  Image,
} from 'lucide-react';
import { PhotoUpload } from '../components/PhotoUpload';
import { cn } from '../lib/utils';
import type { Task, TaskStatus, TaskPriority, TaskCategory } from '../types/tasks';
import { TASK_CATEGORIES, TASK_PRIORITIES, TASK_STATUSES } from '../types/tasks';
import { useAuth } from '../contexts/AuthContext';

// Demo employees for assignment dropdown
const DEMO_EMPLOYEES = [
  { id: '1', name: 'Max Müller' },
  { id: '2', name: 'Sarah Schmidt' },
  { id: '3', name: 'Tom Weber' },
  { id: '4', name: 'Lisa Fischer' },
  { id: '5', name: 'Hans Becker' },
];

// Mock tasks for demo
const mockTasks: Task[] = [
  {
    id: '1',
    title: 'Clean bar area',
    description: 'Wipe down bar top, clean beer taps, organize bottles',
    assignedTo: '3',
    assignedBy: '1',
    dueTime: '22:00',
    status: 'pending',
    category: 'cleaning',
    priority: 'high',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    title: 'Restock beer fridge',
    description: 'Check inventory and restock all refrigerated beverages',
    assignedTo: '4',
    assignedBy: '1',
    dueTime: '18:00',
    status: 'in_progress',
    category: 'inventory',
    priority: 'medium',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '3',
    title: 'Prepare garnishes',
    description: 'Cut limes, lemons, prepare mint leaves',
    assignedTo: '3',
    assignedBy: '2',
    dueTime: '17:00',
    status: 'completed',
    category: 'bar',
    priority: 'medium',
    completedAt: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '4',
    title: 'Count cash register',
    description: 'End of night cash count and reconciliation',
    assignedTo: '2',
    assignedBy: '1',
    dueTime: '03:00',
    status: 'pending',
    category: 'closing',
    priority: 'urgent',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '5',
    title: 'Deep clean kitchen',
    description: 'Full kitchen deep clean including hood vents',
    assignedTo: '5',
    assignedBy: '1',
    dueDate: new Date().toISOString().split('T')[0],
    status: 'approved',
    category: 'cleaning',
    priority: 'low',
    completedAt: new Date(Date.now() - 86400000).toISOString(),
    approvedAt: new Date().toISOString(),
    approvedBy: '1',
    createdAt: new Date(Date.now() - 172800000).toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

const getStatusIcon = (status: TaskStatus) => {
  switch (status) {
    case 'pending': return <Circle size={18} />;
    case 'in_progress': return <PlayCircle size={18} />;
    case 'completed': return <CheckCircle2 size={18} />;
    case 'approved': return <Check size={18} />;
    case 'rejected': return <XCircle size={18} />;
  }
};

const getStatusColor = (status: TaskStatus) => {
  return TASK_STATUSES.find(s => s.value === status)?.color || '#6B7280';
};

const getPriorityColor = (priority: TaskPriority) => {
  return TASK_PRIORITIES.find(p => p.value === priority)?.color || '#6B7280';
};

const getCategoryInfo = (category: TaskCategory) => {
  return TASK_CATEGORIES.find(c => c.value === category) || TASK_CATEGORIES[4]; // Default to 'general'
};

export function Tasks() {
  const { user } = useAuth();
  const [tasks, setTasks] = useState<Task[]>(mockTasks);
  const [showAdd, setShowAdd] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [filterStatus, setFilterStatus] = useState<TaskStatus | 'all'>('all');
  const [filterCategory, setFilterCategory] = useState<TaskCategory | 'all'>('all');
  const [showCompleteModal, setShowCompleteModal] = useState(false);
  const [completionPhoto, setCompletionPhoto] = useState<string>('');

  const [newTask, setNewTask] = useState({
    title: '',
    description: '',
    assignedTo: '',
    dueDate: '',
    dueTime: '',
    category: 'general' as TaskCategory,
    priority: 'medium' as TaskPriority,
  });

  // Filter tasks
  const filteredTasks = tasks.filter(task => {
    if (filterStatus !== 'all' && task.status !== filterStatus) return false;
    if (filterCategory !== 'all' && task.category !== filterCategory) return false;
    return true;
  });

  // Group tasks by status
  const pendingTasks = filteredTasks.filter(t => t.status === 'pending');
  const inProgressTasks = filteredTasks.filter(t => t.status === 'in_progress');
  const completedTasks = filteredTasks.filter(t => t.status === 'completed');
  const approvedTasks = filteredTasks.filter(t => t.status === 'approved');
  const rejectedTasks = filteredTasks.filter(t => t.status === 'rejected');

  const getEmployeeName = (id: string) => {
    return DEMO_EMPLOYEES.find(e => e.id === id)?.name || 'Unknown';
  };

  const updateTaskStatus = (taskId: string, newStatus: TaskStatus, photo?: string) => {
    setTasks(tasks.map(t => {
      if (t.id === taskId) {
        const updates: Partial<Task> = { status: newStatus, updatedAt: new Date().toISOString() };
        if (newStatus === 'in_progress') {
          // Task started
        } else if (newStatus === 'completed') {
          updates.completedAt = new Date().toISOString();
          if (photo) {
            updates.completedPhoto = photo;
          }
        } else if (newStatus === 'approved') {
          updates.approvedAt = new Date().toISOString();
          updates.approvedBy = user?.id || '1';
        }
        return { ...t, ...updates };
      }
      return t;
    }));
    setSelectedTask(null);
    setShowCompleteModal(false);
    setCompletionPhoto('');
  };

  // Open completion modal with photo upload
  const openCompleteModal = () => {
    setCompletionPhoto('');
    setShowCompleteModal(true);
  };

  // Complete task with optional photo
  const completeTaskWithPhoto = () => {
    if (selectedTask) {
      updateTaskStatus(selectedTask.id, 'completed', completionPhoto);
    }
  };

  const rejectTask = (taskId: string, reason: string) => {
    setTasks(tasks.map(t => {
      if (t.id === taskId) {
        return {
          ...t,
          status: 'rejected' as TaskStatus,
          rejectionReason: reason,
          updatedAt: new Date().toISOString()
        };
      }
      return t;
    }));
    setSelectedTask(null);
  };

  const deleteTask = (taskId: string) => {
    setTasks(tasks.filter(t => t.id !== taskId));
    setSelectedTask(null);
  };

  const addTask = () => {
    if (!newTask.title.trim()) return;

    const task: Task = {
      id: Date.now().toString(),
      title: newTask.title,
      description: newTask.description,
      assignedTo: newTask.assignedTo || DEMO_EMPLOYEES[0].id,
      assignedBy: user?.id || '1',
      dueDate: newTask.dueDate,
      dueTime: newTask.dueTime,
      status: 'pending',
      category: newTask.category,
      priority: newTask.priority,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    setTasks([task, ...tasks]);
    setNewTask({
      title: '',
      description: '',
      assignedTo: '',
      dueDate: '',
      dueTime: '',
      category: 'general',
      priority: 'medium',
    });
    setShowAdd(false);
  };

  const TaskCard = ({ task }: { task: Task }) => {
    const categoryInfo = getCategoryInfo(task.category);

    return (
      <div
        onClick={() => setSelectedTask(task)}
        className={cn(
          "p-4 glass-card rounded-xl cursor-pointer hover:border-primary-500/50 transition-all",
          task.status === 'approved' && "opacity-60",
          task.status === 'rejected' && "opacity-50 border-error/30"
        )}
      >
        <div className="flex items-start gap-3">
          {/* Status indicator */}
          <div
            className="mt-0.5 flex-shrink-0"
            style={{ color: getStatusColor(task.status) }}
          >
            {getStatusIcon(task.status)}
          </div>

          <div className="flex-1 min-w-0">
            {/* Title and priority */}
            <div className="flex items-center gap-2 mb-1">
              <p className={cn(
                "font-medium text-foreground truncate",
                task.status === 'approved' && "line-through"
              )}>
                {task.title}
              </p>
              <span
                className="px-1.5 py-0.5 text-[10px] font-medium rounded"
                style={{
                  backgroundColor: `${getPriorityColor(task.priority)}20`,
                  color: getPriorityColor(task.priority)
                }}
              >
                {task.priority.toUpperCase()}
              </span>
            </div>

            {/* Category and assignee */}
            <div className="flex items-center gap-3 text-sm text-foreground-muted">
              <span className="flex items-center gap-1">
                <span>{categoryInfo.icon}</span>
                <span>{categoryInfo.label}</span>
              </span>
              <span className="flex items-center gap-1">
                <User size={12} />
                {getEmployeeName(task.assignedTo)}
              </span>
            </div>

            {/* Due time */}
            {(task.dueTime || task.dueDate) && (
              <div className="flex items-center gap-1 mt-2 text-xs text-foreground-dim">
                <Clock size={12} />
                {task.dueDate && <span>{new Date(task.dueDate).toLocaleDateString('de-DE')}</span>}
                {task.dueTime && <span>{task.dueTime}</span>}
              </div>
            )}

            {/* Rejection reason */}
            {task.status === 'rejected' && task.rejectionReason && (
              <div className="mt-2 p-2 bg-error/10 rounded-lg text-xs text-error">
                <strong>Rejected:</strong> {task.rejectionReason}
              </div>
            )}

            {/* Completion photo indicator */}
            {task.completedPhoto && (
              <div className="mt-2 flex items-center gap-1 text-xs text-success">
                <Camera size={12} />
                Photo proof attached
              </div>
            )}
          </div>
        </div>
      </div>
    );
  };

  const TaskSection = ({ title, tasks, color }: { title: string; tasks: Task[]; color: string }) => {
    if (tasks.length === 0) return null;

    return (
      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full" style={{ backgroundColor: color }} />
          <h2 className="text-sm font-medium text-foreground-muted uppercase tracking-wide">
            {title} ({tasks.length})
          </h2>
        </div>
        <div className="space-y-2">
          {tasks.map(task => (
            <TaskCard key={task.id} task={task} />
          ))}
        </div>
      </div>
    );
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6 animate-fade-in pb-20">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-foreground">Tasks</h1>
          <p className="text-foreground-muted">
            {pendingTasks.length + inProgressTasks.length} active, {completedTasks.length} awaiting approval
          </p>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={cn(
              "p-2 rounded-xl transition-all",
              showFilters
                ? "bg-primary-500 text-white"
                : "bg-white/10 text-foreground hover:bg-white/20"
            )}
          >
            <Filter size={20} />
          </button>
          <button
            onClick={() => setShowAdd(true)}
            className="flex items-center gap-2 px-4 py-2 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all shadow-glow-sm"
          >
            <Plus size={18} />
            <span>Add Task</span>
          </button>
        </div>
      </div>

      {/* Filters */}
      {showFilters && (
        <div className="glass-card p-4 rounded-xl space-y-3 animate-scale-in">
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Status</label>
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value as TaskStatus | 'all')}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              >
                <option value="all">All Statuses</option>
                {TASK_STATUSES.map(s => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Category</label>
              <select
                value={filterCategory}
                onChange={(e) => setFilterCategory(e.target.value as TaskCategory | 'all')}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              >
                <option value="all">All Categories</option>
                {TASK_CATEGORIES.map(c => (
                  <option key={c.value} value={c.value}>{c.icon} {c.label}</option>
                ))}
              </select>
            </div>
          </div>
        </div>
      )}

      {/* Add Task Form */}
      {showAdd && (
        <div className="glass-card p-4 rounded-xl space-y-4 animate-scale-in">
          <div className="flex items-center justify-between">
            <h3 className="font-semibold text-foreground">New Task</h3>
            <button
              onClick={() => setShowAdd(false)}
              className="p-1 text-foreground-dim hover:text-foreground"
            >
              <X size={20} />
            </button>
          </div>

          <input
            type="text"
            placeholder="Task title"
            value={newTask.title}
            onChange={(e) => setNewTask({ ...newTask, title: e.target.value })}
            className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500"
            autoFocus
          />

          <textarea
            placeholder="Description (optional)"
            value={newTask.description}
            onChange={(e) => setNewTask({ ...newTask, description: e.target.value })}
            className="w-full px-4 py-3 bg-white/5 border border-border rounded-xl text-foreground placeholder-foreground-dim focus:outline-none focus:border-primary-500 resize-none"
            rows={2}
          />

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Assign to</label>
              <select
                value={newTask.assignedTo}
                onChange={(e) => setNewTask({ ...newTask, assignedTo: e.target.value })}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              >
                <option value="">Select employee...</option>
                {DEMO_EMPLOYEES.map(e => (
                  <option key={e.id} value={e.id}>{e.name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Category</label>
              <select
                value={newTask.category}
                onChange={(e) => setNewTask({ ...newTask, category: e.target.value as TaskCategory })}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              >
                {TASK_CATEGORIES.map(c => (
                  <option key={c.value} value={c.value}>{c.icon} {c.label}</option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-3">
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Priority</label>
              <select
                value={newTask.priority}
                onChange={(e) => setNewTask({ ...newTask, priority: e.target.value as TaskPriority })}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              >
                {TASK_PRIORITIES.map(p => (
                  <option key={p.value} value={p.value}>{p.label}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Due date</label>
              <input
                type="date"
                value={newTask.dueDate}
                onChange={(e) => setNewTask({ ...newTask, dueDate: e.target.value })}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              />
            </div>
            <div>
              <label className="text-xs text-foreground-muted mb-1 block">Due time</label>
              <input
                type="time"
                value={newTask.dueTime}
                onChange={(e) => setNewTask({ ...newTask, dueTime: e.target.value })}
                className="w-full px-3 py-2 bg-white/5 border border-border rounded-xl text-foreground focus:outline-none focus:border-primary-500"
              />
            </div>
          </div>

          <div className="flex gap-2 pt-2">
            <button
              onClick={() => setShowAdd(false)}
              className="flex-1 px-4 py-2.5 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
            >
              Cancel
            </button>
            <button
              onClick={addTask}
              disabled={!newTask.title.trim()}
              className="flex-1 px-4 py-2.5 bg-gradient-primary text-white rounded-xl hover:opacity-90 transition-all disabled:opacity-50"
            >
              Create Task
            </button>
          </div>
        </div>
      )}

      {/* Task Sections */}
      <div className="space-y-6">
        <TaskSection title="Pending" tasks={pendingTasks} color="#6B7280" />
        <TaskSection title="In Progress" tasks={inProgressTasks} color="#3B82F6" />
        <TaskSection title="Awaiting Approval" tasks={completedTasks} color="#10B981" />
        <TaskSection title="Approved" tasks={approvedTasks} color="#8B5CF6" />
        <TaskSection title="Rejected" tasks={rejectedTasks} color="#EF4444" />
      </div>

      {/* Empty State */}
      {filteredTasks.length === 0 && (
        <div className="text-center py-12 text-foreground-dim">
          <CheckCircle2 size={48} className="mx-auto mb-3 opacity-30" />
          <p className="text-lg">No tasks found</p>
          <p className="text-sm mt-1">
            {filterStatus !== 'all' || filterCategory !== 'all'
              ? 'Try adjusting your filters'
              : 'Create your first task to get started'}
          </p>
        </div>
      )}

      {/* Task Detail Modal */}
      {selectedTask && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 animate-fade-in">
          <div className="bg-card w-full max-w-lg rounded-2xl overflow-hidden animate-scale-in">
            {/* Header */}
            <div className="p-4 border-b border-border flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span style={{ color: getStatusColor(selectedTask.status) }}>
                  {getStatusIcon(selectedTask.status)}
                </span>
                <span className="font-semibold text-foreground">Task Details</span>
              </div>
              <button
                onClick={() => setSelectedTask(null)}
                className="p-1 text-foreground-dim hover:text-foreground"
              >
                <X size={20} />
              </button>
            </div>

            {/* Content */}
            <div className="p-4 space-y-4">
              <div>
                <h2 className="text-xl font-bold text-foreground">{selectedTask.title}</h2>
                {selectedTask.description && (
                  <p className="text-foreground-muted mt-1">{selectedTask.description}</p>
                )}
              </div>

              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="p-3 bg-white/5 rounded-xl">
                  <p className="text-foreground-dim text-xs mb-1">Assigned to</p>
                  <p className="text-foreground font-medium">{getEmployeeName(selectedTask.assignedTo)}</p>
                </div>
                <div className="p-3 bg-white/5 rounded-xl">
                  <p className="text-foreground-dim text-xs mb-1">Category</p>
                  <p className="text-foreground font-medium">
                    {getCategoryInfo(selectedTask.category).icon} {getCategoryInfo(selectedTask.category).label}
                  </p>
                </div>
                <div className="p-3 bg-white/5 rounded-xl">
                  <p className="text-foreground-dim text-xs mb-1">Priority</p>
                  <p
                    className="font-medium"
                    style={{ color: getPriorityColor(selectedTask.priority) }}
                  >
                    {selectedTask.priority.charAt(0).toUpperCase() + selectedTask.priority.slice(1)}
                  </p>
                </div>
                <div className="p-3 bg-white/5 rounded-xl">
                  <p className="text-foreground-dim text-xs mb-1">Status</p>
                  <p
                    className="font-medium"
                    style={{ color: getStatusColor(selectedTask.status) }}
                  >
                    {TASK_STATUSES.find(s => s.value === selectedTask.status)?.label}
                  </p>
                </div>
              </div>

              {/* Due date/time */}
              {(selectedTask.dueDate || selectedTask.dueTime) && (
                <div className="flex items-center gap-2 p-3 bg-white/5 rounded-xl">
                  <Calendar size={16} className="text-foreground-muted" />
                  <span className="text-foreground">
                    Due: {selectedTask.dueDate && new Date(selectedTask.dueDate).toLocaleDateString('de-DE')}
                    {selectedTask.dueTime && ` at ${selectedTask.dueTime}`}
                  </span>
                </div>
              )}

              {/* Rejection reason */}
              {selectedTask.status === 'rejected' && selectedTask.rejectionReason && (
                <div className="p-3 bg-error/10 border border-error/30 rounded-xl">
                  <p className="text-xs text-error mb-1 font-medium">Rejection Reason</p>
                  <p className="text-foreground">{selectedTask.rejectionReason}</p>
                </div>
              )}

              {/* Completion details */}
              {selectedTask.completedAt && (
                <div className="p-3 bg-success/10 border border-success/30 rounded-xl">
                  <p className="text-xs text-success mb-1 font-medium">Completed</p>
                  <p className="text-foreground">
                    {new Date(selectedTask.completedAt).toLocaleString('de-DE')}
                  </p>
                </div>
              )}

              {/* Completion Photo */}
              {selectedTask.completedPhoto && (
                <div className="space-y-2">
                  <p className="text-xs text-foreground-muted font-medium flex items-center gap-1">
                    <Image size={14} />
                    Photo Proof
                  </p>
                  <img
                    src={selectedTask.completedPhoto}
                    alt="Completion proof"
                    className="w-full h-48 object-cover rounded-xl border border-border"
                  />
                </div>
              )}
            </div>

            {/* Actions */}
            <div className="p-4 border-t border-border space-y-2">
              {/* Status-specific actions */}
              {selectedTask.status === 'pending' && (
                <button
                  onClick={() => updateTaskStatus(selectedTask.id, 'in_progress')}
                  className="w-full py-3 bg-blue-500 text-white rounded-xl hover:bg-blue-600 transition-all flex items-center justify-center gap-2"
                >
                  <PlayCircle size={18} />
                  Start Task
                </button>
              )}

              {selectedTask.status === 'in_progress' && (
                <button
                  onClick={openCompleteModal}
                  className="w-full py-3 bg-success text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
                >
                  <Camera size={18} />
                  Complete with Photo
                </button>
              )}

              {selectedTask.status === 'completed' && (
                <div className="grid grid-cols-2 gap-2">
                  <button
                    onClick={() => updateTaskStatus(selectedTask.id, 'approved')}
                    className="py-3 bg-primary-500 text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
                  >
                    <Check size={18} />
                    Approve
                  </button>
                  <button
                    onClick={() => {
                      const reason = prompt('Enter rejection reason:');
                      if (reason) rejectTask(selectedTask.id, reason);
                    }}
                    className="py-3 bg-error text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
                  >
                    <XCircle size={18} />
                    Reject
                  </button>
                </div>
              )}

              {selectedTask.status === 'rejected' && (
                <button
                  onClick={() => updateTaskStatus(selectedTask.id, 'pending')}
                  className="w-full py-3 bg-orange-500 text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
                >
                  <AlertCircle size={18} />
                  Reassign Task
                </button>
              )}

              {/* Delete button */}
              <button
                onClick={() => deleteTask(selectedTask.id)}
                className="w-full py-3 bg-white/10 text-error rounded-xl hover:bg-error/20 transition-all flex items-center justify-center gap-2"
              >
                <Trash2 size={18} />
                Delete Task
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Complete Task Modal with Photo Upload */}
      {showCompleteModal && selectedTask && (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/80 animate-fade-in">
          <div className="bg-card w-full max-w-md rounded-2xl overflow-hidden animate-scale-in">
            {/* Header */}
            <div className="p-4 border-b border-border flex items-center justify-between">
              <div className="flex items-center gap-2">
                <CheckCircle2 size={20} className="text-success" />
                <span className="font-semibold text-foreground">Complete Task</span>
              </div>
              <button
                onClick={() => {
                  setShowCompleteModal(false);
                  setCompletionPhoto('');
                }}
                className="p-1 text-foreground-dim hover:text-foreground"
              >
                <X size={20} />
              </button>
            </div>

            {/* Content */}
            <div className="p-4 space-y-4">
              <div className="p-3 bg-white/5 rounded-xl">
                <p className="font-medium text-foreground">{selectedTask.title}</p>
                <p className="text-sm text-foreground-muted mt-1">
                  Assigned to: {getEmployeeName(selectedTask.assignedTo)}
                </p>
              </div>

              {/* Photo Upload */}
              <PhotoUpload
                onPhotoCapture={setCompletionPhoto}
                currentPhoto={completionPhoto}
                label="Completion Photo (Optional)"
              />

              {/* Info text */}
              <p className="text-xs text-foreground-dim text-center">
                Adding a photo helps verify task completion
              </p>
            </div>

            {/* Actions */}
            <div className="p-4 border-t border-border flex gap-3">
              <button
                onClick={() => {
                  setShowCompleteModal(false);
                  setCompletionPhoto('');
                }}
                className="flex-1 py-3 bg-white/10 text-foreground rounded-xl hover:bg-white/20 transition-all"
              >
                Cancel
              </button>
              <button
                onClick={completeTaskWithPhoto}
                className="flex-1 py-3 bg-success text-white rounded-xl hover:opacity-90 transition-all flex items-center justify-center gap-2"
              >
                <Check size={18} />
                {completionPhoto ? 'Complete with Photo' : 'Complete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
